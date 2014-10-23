class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}
  validates :category_id, presence: true

  #to assign default category
  after_initialize :init
  def init
    self.category_id ||= 1
  end

  def self.duration()
    Timelog.all.order("time desc").each do |timelog|
      
    end
  end

  #import csv
  def self.import(file)    
    CSV.foreach(file.path, headers: true) do |row|      
      row_hash = row.to_hash

      regex = /(\S+)/
      if row_hash["event"]
        matches = row_hash["event"].match regex
      else
        raise "error on #{row_hash}"
      end
      
      #check the first word
      if matches        
        if matches[1].length <= 3
          #if length is 3, get id by shortcut
          cat = Category.find_by_shortcut(matches[1].downcase)
        else
          #else get id by event itself
          cat = Category.find_by_name(matches[1].downcase)
        end
      end

      #if category is not found, use id 1
      if cat
        id = cat.id
      else
        id = Category.find_by_name("unknown").id
      end

      timelog = Timelog.new(time: row_hash["time"], event: row_hash["event"], category_id: id)
      timelog.save!
    end                
  end

  def self.summarize()
    summary = Hash.new { |k,v| k[v] = Hash.new { |k2,v2| k2[v2] = 0 } }
    @sortedTimelog = Timelog.all.order("time desc")
    @sortedTimelog.each_with_index do |timelog,index|        
      if index != 0
        summary[index][:duration] = (@sortedTimelog[index-1].time - timelog.time).to_i/60
      end
      summary[index][:timelog] = timelog
    end
    summary
  end

end
