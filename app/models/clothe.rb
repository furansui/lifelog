class Clothe < ActiveRecord::Base
  serialize :wear, Array
  validates :name, presence: true, uniqueness: {message: "should have unique name"}
  #c.wear << "8 Jun 2011"

  # Getter
  def worn
    Date.today.strftime("%d %b %Y")
  end

  # Setter
  def worn=(date)    
    wear << date
  end
end
