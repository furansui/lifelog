class Timelog < ActiveRecord::Base
  validates :event, presence: true, length: {minimum: 3}
end
