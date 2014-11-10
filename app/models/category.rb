class Category < ActiveRecord::Base
  has_many :timelogs
  validates :name, uniqueness: true, format: {without: /\s/}
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
      category = Category.new(name: row_hash["name"], shortcut: row_hash["shortcut"], notes: row_hash["notes"], parent_id: id)
      if category.save
      else
        raise "error on #{category.name} #{category.shortcut}"
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
    logs = Timelog.where("category_id IN (?) AND time >= ? AND time <= ? ", catid, options[:begin], options[:end])
    if logs
      seconds = logs.pluck(:duration).sum
      summed[:duration] = seconds
    end
    summed
  end

  #time view
  def self.summarize(options)
    #Category.rebuild_dotted_ids!

    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| } } }
    summary[:head][:range][:begin] = options[:begin]
    summary[:head][:range][:end] = options[:end]
    summary[:head][:prev][:remaining] = 0
    summary[:head][:total][:inseconds] = 0

    Category.where(parent_id: nil).each do |category|
      summary[:category][category.id][:name] = category.name      
      summary[:category][category.id][:summary] = category.sum_up(options)
      category.all_children.each do |childcategory|
        summary[:category][category.id][childcategory.id] = childcategory.sum_up(options)
      end
      summary[:head][:total][:inseconds] += summary[:category][category.id][:summary][:duration]
    end
      
#    @sortedTimelog = Timelog.where(time: options[:begin]..options[:end]).order("time desc")
#
#    if !@sortedTimelog.empty?            
#      Category.where(parent_id: nil).each do |category|      
#        summary[:row][category.id][:duration] = 0       
#        summary[:row][category.id][:parent] = category.id.to_s #category.all_children #category.all_children.length #category.self_and_ancestors     
#
#        category.all_children.each do |childcategory| 
#          summary[:row][category.id][:parent] += childcategory.id.to_s
#          summary[:row][category.id][childcategory.id] = 0
#          @sortedTimelog.each_with_index do |timelog,index|            
#            if timelog.category_id == childcategory.id
#              #most recent timelog, cut off at midnight
#              if index==0
#                summary[:row][category.id][:duration] += (timelog.time + 1.day).midnight-timelog.time
#              else
#                summary[:row][category.id][:duration] += timelog.duration
#                summary[:row][category.id][childcategory.id] += timelog.duration
#              end
#            end
#          end
#        end
#        summary[:head][:total][:inseconds] += summary[:row][category.id][:duration]          
#      end
#
#      summary[:head][:prev][:remaining] = @sortedTimelog.last.time - @sortedTimelog.last.time.midnight
#      if summary[:head][:prev][:remaining] > 0
#        @prevDayTimelog = Timelog.where('time < ?', options[:begin]).order("time desc")
#        if !@prevDayTimelog.empty? 
#          summary[:head][:prev][:time] = @prevDayTimelog.first.time 
#          summary[:head][:prev][:cat] = @prevDayTimelog.first.category_id    
#          #summary[:row][summary[:head][:prev][:cat]][:duration] ||= 0          
#          #summary[:row][summary[:head][:prev][:cat]][:duration] += summary[:head][:prev][:remaining]
#          summary[:head][:total][:inseconds] += summary[:head][:prev][:remaining]
#        end
#      end
#
#    end

    summary[:head][:total][:days] = summary[:head][:total][:inseconds] / 86400
    summary[:head][:total][:hours] = (summary[:head][:total][:inseconds] - 86400*summary[:head][:total][:days]) / 3600
    summary[:head][:total][:minutes] = (summary[:head][:total][:inseconds] - 86400*summary[:head][:total][:days] - 3600*summary[:head][:total][:hours]) / 60    
    summary
  end
  
end
