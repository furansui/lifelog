class Category < ActiveRecord::Base
  has_many :timelogs
  validates :name, uniqueness: true
  validates :shortcut, uniqueness: true
end
