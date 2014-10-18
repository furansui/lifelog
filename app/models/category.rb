class Category < ActiveRecord::Base
  has_many :timelogs, dependent: :destroy
end
