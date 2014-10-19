class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}
  validates :category_id, presence: true

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|      
      Timelog.create!(row.to_hash)
    end                
  end
end
