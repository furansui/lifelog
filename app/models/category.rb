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
    summary = Hash.new { |h,k| h[k] = 0 }
    category = Category.find_by_id(1)
    summary[:name] += category.id
    summary
  end

end
