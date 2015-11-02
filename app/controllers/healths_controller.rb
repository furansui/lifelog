class HealthsController < ApplicationController
  def index
    @healths = Health.all    
    respond_to do |format|
      format.html
      format.csv { send_data @healths.to_csv}
    end
  end
  def new
    @health = Health.new
  end
  def create
    @health = Health.new(health_params)
    if @health.save
      redirect_to @health
    else
      render 'new'
    end
  end

  private
  def health_params
    params.require(:health).permit(:logged_at, :value, :health_category_id, :notes)
  end

end
