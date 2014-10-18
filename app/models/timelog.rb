class Timelog < ActiveRecord::Base
  belongs_to :category
  validates :event, presence: true, length: {minimum: 3}

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      Timelog.create!(row.to_hash)
    end                
  end
end
