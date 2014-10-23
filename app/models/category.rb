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
    summary = Hash.new { |k,v| k[v] = Hash.new { |k2,v2| k2[v2] = 0 } }
    #Category.all.each do |category|      
      @sortedTimelog = Timelog.all.order("time desc")
      @sortedTimelog.each_with_index do |timelog,index|        
        #if timelog.category_id == category.id
          if index != 0
            summary[index][:duration] = (@sortedTimelog[index-1].time - timelog.time).to_i/60
          end
          summary[index][:timelog] = timelog
        #end
      end
    #end
    summary
  end
end
