class HealthCategoriesController < ApplicationController
  def index
    @health_categories = HealthCategory.all    
    respond_to do |format|
      format.html
      format.csv { send_data @health_categories.to_csv}
    end
  end
  def new
    @health_category = HealthCategory.new
  end
  def create
    @health_category = HealthCategory.new(health_category_params)
    if @health_category.save
      redirect_to @health_category
    else
      render 'new'
    end
  end

  private
  def health_category_params
    params.require(:health_category).permit(:name, :unit)
  end

end
