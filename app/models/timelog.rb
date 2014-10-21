class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}
  validates :category_id, presence: true

  #to assign default category
  after_initialize :init
  def init
    self.category_id ||= 1
  end

  #import csv
  def self.import(file)    
    CSV.foreach(file.path, headers: true) do |row|      
      row_hash = row.to_hash

      regex = /(\S+)/
      matches = row_hash["event"].match regex
      
      #check the first word
      if matches
        if matches[1].length == 3
          #if length is 3, get id by shortcut
          cat = Category.find_by_shortcut(matches[1].downcase)
        else
          #else get id by event itself
          cat = Category.find_by_name(matches[1].downcase)
        end
      end

      #if category is not found, use id 0
      id = 0
      if cat
        id = cat.id
      end

      timelog = Timelog.new(time: row_hash["time"], event: row_hash["event"], category_id: id)
      timelog.save!
    end                
  end
end
