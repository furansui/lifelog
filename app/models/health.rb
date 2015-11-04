class Health < ActiveRecord::Base
  def self.weight()
    weight = Hash.new {|h,k| h[k] = 0}
    weightCategory = HealthCategory.find_by name: 'weight'    
    Health.where(health_category_id: weightCategory.id).each do |health|
      weight[health.logged_at] = health.value
    end
    weight
  end
end
