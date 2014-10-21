class Category < ActiveRecord::Base
  has_many :timelogs
  validates :name, uniqueness: true, format: {without: /\s/}
  validates :shortcut, uniqueness: true, format: {without: /\s/}

  before_save do
    self.name = self.name.downcase
    self.shortcut = self.shortcut.downcase
  end
end
