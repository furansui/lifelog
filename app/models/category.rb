class Category < ActiveRecord::Base
  has_many :timelogs
  validates :name, uniqueness: true, format: {without: /\s/}
  validates :shortcut, format: {without: /\s/}
  validates_uniqueness_of :shortcut, allow_blank: true

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
        end
        if Category.find_by_name(row_hash["parent"].downcase)
          id = Category.find_by_name(row_hash["parent"].downcase).id
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

  def self.summarize(options)
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3]=0 } } }
    @sortedTimelog = Timelog.where(:time => options[:range]).order("time desc")

    summary[:head][:range][:start] = options[:range].begin
    summary[:head][:range][:end] = options[:range].end

    if !@sortedTimelog.empty?      

    #get total days observed
    summary[:total][:total][:day] = 1
    curday = @sortedTimelog.first.time.midnight
    @sortedTimelog.each do |timelog|
      logday = timelog.time.midnight
      if logday != curday
        curday = logday
        summary[:total][:total][:day] += 1
      end
    end
      
    summary[:total][:total][:hour] = 0
    Category.all.each do |category|      
      summary[:row][category.id][:duration] = 0

      @sortedTimelog.each_with_index do |timelog,index|            
        if timelog.category_id == category.id
          #first timelog
          if index == 0
            if @sortedTimelog.first == Timelog.all.order("time desc").first
              summary[:row][category.id][:duration] += (Time.now - timelog.time).to_i/60
            else
              summary[:row][category.id][:duration] += ((timelog.time + 1.day).midnight - timelog.time).to_i/60
            end
          else
            summary[:row][category.id][:duration] += (@sortedTimelog[index-1].time - timelog.time).to_i/60
          end
        end
      end
      summary[:total][:total][:hour] += summary[:row][category.id][:duration]          
    end
    end #if not empty
    summary
  end

end
