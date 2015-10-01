class Category < ActiveRecord::Base
  has_many :timelogs
  validates :name, uniqueness: true, format: {without: /\s/}, presence: true
  validates :shortcut, format: {without: /\s/}
  validates_uniqueness_of :shortcut, allow_blank: true
  belongs_to :parent, class_name: 'Category'

  acts_as_tree_with_dotted_ids

  before_save do
    self.name = self.name.downcase
    if !self.shortcut.blank?
      self.shortcut = self.shortcut.downcase
    end
  end

  def self.to_csv(options = {}) 
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |category|
        csv << category.attributes.values_at(*column_names)
      end
    end
  end
  
  #import csv
  def self.import(file)    
    CSV.foreach(file.path, headers: true) do |row|      
      row_hash = row.to_hash
      id = ""
      if row_hash["parent"]        
        if Category.find_by_shortcut(row_hash["parent"].downcase)
          id = Category.find_by_shortcut(row_hash["parent"].downcase).id
        else 
          if Category.find_by_name(row_hash["parent"].downcase)
            id = Category.find_by_name(row_hash["parent"].downcase).id
          end
        end
        if id.blank?
          raise "parent #{row_hash["parent"]} name #{row_hash["name"]}"
        end
      end
      category = Category.new(name: row_hash["name"], shortcut: row_hash["shortcut"], notes: row_hash["notes"], color: row_hash["color"], parent_id: id)
      if category.save
      else
        raise "error on #{category.name} #{category.shortcut}"
      end
    end                
  end
   
  def self.parentNameToNote 
    all.each do |category|
      unless category.parent_id.nil?        
        category.notes = Category.find_by_id(category.parent_id).name
        category.save
      end
    end
  end
    
  def self.fix0parentId
    all.each do |category|
      if category.parent_id == 0
        category.parent_id = nil
        category.save
      end    
    end
  end
      
  def self.secondsToString(t)
    mm, ss = t.divmod(60)   
    hh, mm = mm.divmod(60)  
    dd, hh = hh.divmod(24)
    if dd > 0
      return "%d days %02d:%02d" % [dd,hh,mm]
    else
      return "%02d:%02d" % [hh,mm]
    end
  end

  def sum_up(options)
    summed = Hash.new { |h,k| h[k] = 0}  
    summed[:name] = self_and_ancestors.reverse.map{ |c| c.name }.join(' - ').html_safe    
    unless all_children.empty?
      catid = all_children.map{|i| i[:id]}.push(id)
    else
      catid = id
    end
    summed[:cat] = catid
    summed[:color] = root.color
    logs = Timelog.where(time: options[:begin]..options[:end]).order("time desc").where("category_id IN (?)",catid)
    summed[:logs] = logs
    if logs
      seconds = logs.pluck(:duration).sum
      summed[:duration] = seconds
    end
    summed
  end

  #time view, sumarize by root category
  def self.summarize(options)
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| } }

    Category.where(parent_id: [nil,0]).each do |category|
      summary[:category][category.id] = 0
      summary[:timelog][category.id] = []
    end

    summary[:range][:begin] = options[:begin]
    summary[:range][:end] = options[:end]
     
    summary[:excess][:prev] = Timelog.where("time < ?",options[:begin]).order("time desc").first

    timelogRange = Timelog.where("time >= ? AND time <= ? AND duration > 0", options[:begin],options[:end]).order("time")
    
    timelogRange.each do |timelog|
      category = Category.find_by_id(timelog.category_id)
      summary[:category][category.root.id] += timelog.duration
      summary[:timelog][category.root.id] << timelog
    end

    #plus first timelog's excess duration
    summary[:category][Category.find_by_id(summary[:excess][:prev].category_id).root.id] += timelogRange.first.time-summary[:range][:begin].midnight
    summary[:timelog][Category.find_by_id(summary[:excess][:prev].category_id).root.id] << summary[:excess][:prev]
    
    #minus last timelog's excess duration
    summary[:category][Category.find_by_id(timelogRange.last.category_id).root.id] -= timelogRange.last.duration
    endtime = summary[:range][:end]
    if(Time.zone.now < endtime)
      endtime = Time.zone.now
    end
    summary[:category][Category.find_by_id(timelogRange.last.category_id).root.id] += endtime-timelogRange.last.time+60

    summary[:total][:category] = 0
    summary[:category].each do |category,duration|
      summary[:total][:category] += duration
    end
    
    summary

  end
    
##     #Category.rebuild_dotted_ids!
## 
## 
## 
##     
##     summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| } } }
##     summary[:head][:range][:begin] = options[:begin]
##     summary[:head][:range][:end] = options[:end]
##     summary[:head][:prev][:remaining] = 0
##     summary[:head][:total][:inseconds] = 0
## 
##     summary[:head][:prev][:timelog] = Timelog.where("time < ?",options[:begin]).order("time desc").first
##     summary[:head][:last][:timelog] = Timelog.where("time < ?",options[:end]).order("time desc").first
##     summary[:head][:first][:timelog] = Timelog.where("time >= ?",options[:begin]).order("time").first
##     if !summary[:head][:first][:timelog].nil?
##       summary[:head][:prev][:duration] = summary[:head][:first][:timelog].time-summary[:head][:first][:timelog].time.beginning_of_day
##     end
## 
## 
##     Category.where(parent_id: nil).each do |category|
##       if category.self_and_all_children #avoid nil for unknown category       
##         category.self_and_all_children.each do |childcategory|
##           summary[:category][category.id][childcategory.id] = childcategory.sum_up(options)
##         end
##         summary[:head][:total][:inseconds] += summary[:category][category.id][category.id][:duration]
##       end
##     end
## 
##     if summary[:head][:prev][:duration] && !summary[:head][:prev][:timelog].nil?
##       Category.find_by_id(summary[:head][:prev][:timelog].category_id).self_and_ancestors.each do |ancestor|
##         #logger.debug "Logger ancestor : #{ancestor.name}"
##         #logger.debug "Logger ancestor root id: #{ancestor.root.id}"
##         #logger.debug "Logger ancestor id : #{summary[:category][ancestor.root.id][ancestor.id]}"
##         summary[:category][ancestor.root.id][ancestor.id][:duration] ||= 0
##         summary[:category][ancestor.root.id][ancestor.id][:duration] += summary[:head][:prev][:duration]
##       end
##       summary[:head][:total][:inseconds] += summary[:head][:prev][:duration]
##     end        
## 
##     if summary[:head][:last][:timelog]
##       summary[:head][:last][:endtime] = (summary[:head][:last][:timelog].time + summary[:head][:last][:timelog].duration.seconds) 
##       if summary[:head][:last][:endtime] > options[:end]
##         summary[:head][:last][:duration]  = summary[:head][:last][:endtime] - options[:end]
##         Category.find_by_id(summary[:head][:last][:timelog].category_id).self_and_ancestors.each do |ancestor|
##           summary[:category][ancestor.root.id][ancestor.id][:duration] -= summary[:head][:last][:duration]
##         end
##         summary[:head][:total][:inseconds] -= summary[:head][:last][:duration]
##       end
##     end        
##       
##     summary[:head][:total][:days] = summary[:head][:total][:inseconds] / 86400
##     summary[:head][:total][:hours] = (summary[:head][:total][:inseconds] - 86400*summary[:head][:total][:days]) / 3600
##     summary[:head][:total][:minutes] = (summary[:head][:total][:inseconds] - 86400*summary[:head][:total][:days] - 3600*summary[:head][:total][:hours]) / 60    
  
end
