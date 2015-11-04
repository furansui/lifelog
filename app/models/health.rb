class Health < ActiveRecord::Base
  def self.by_category(categoryName)
    dateStart = Health.order("logged_at").first.logged_at
    dateEnd = Health.order("logged_at").last.logged_at

    # create a hash for each date
    cat = (dateStart.to_date..dateEnd.to_date).each_with_object({}) do |date,hash|
    hash[date] = 0
    end

    # cat = Hash.new { |h,k| h[k] = 0}  
    
    catid = HealthCategory.find_by(name: categoryName).id
    Health.where(health_category_id: catid).each do |health|
      cat[health.logged_at.to_date] = health.value
    end
    cat
  end
end
