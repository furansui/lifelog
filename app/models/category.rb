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
      category = Category.new(name: row_hash["name"], shortcut: row_hash["shortcut"], notes: row_hash["notes"])
      if category.save
      else
        raise "error on #{category.name} #{category.shortcut}"
      end
    end                
  end

  def self.summarize()
    summary = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = Hash.new { |h3,k3| h3[k3]=0 } } }

    #get total days observed
    summary[:total][:total][:day] = 1
    curday = Timelog.first.time.midnight
    Timelog.all.each do |timelog|
      logday = timelog.time.midnight
      if logday != curday
        curday = logday
        summary[:total][:total][:day] += 1
      end
    end
      
    summary[:total][:total][:hour] = 0
    Category.all.each do |category|      
      summary[:row][category.id][:duration] = 0

      @sortedTimelog = Timelog.all.order("time desc")
      @sortedTimelog.each_with_index do |timelog,index|            
        if timelog.category_id == category.id
          if index == 0
            summary[:row][category.id][:duration] += (Time.now - timelog.time).to_i/60
          else
            summary[:row][category.id][:duration] += (@sortedTimelog[index-1].time - timelog.time).to_i/60
          end
        end
      end
      summary[:total][:total][:hour] += summary[:row][category.id][:duration]          
    end
    summary
  end

end
