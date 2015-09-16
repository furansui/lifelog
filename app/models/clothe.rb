class Clothe < ActiveRecord::Base
  serialize :wear, Array
  validates :name, presence: true, uniqueness: {message: "should have unique name"}
  
  # Getter
  def worn
    Date.today.strftime("%d %b %Y")
  end

  # Setter
  def worn=(date)    
    wear << date
  end

  def lastWorn
    wear.sort_by{|date| DateTime.parse(date)}.last
  end
  
  def times
    wear.size
  end

  def self.getPerDay
    # get clothes id per day recorded
    clothesPerDay= Hash.new { |h,k| h[k] = [] }
    Clothe.all.each do |clothe|
      clothe.wear.sort_by{|date| DateTime.parse(date)}.each do |date|
        clothesPerDay[date] << clothe.id
      end
    end
    clothesPerDay
  end
  
end
