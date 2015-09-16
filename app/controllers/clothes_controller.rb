class ClothesController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  def index
    if sort_column == "times"
      @clothes = Clothe.all.sort_by{|c| c.times}
    else
      if sort_column == "lastWorn"
        @clothes = Clothe.all.sort_by{|c| DateTime.parse(c.lastWorn)}        
      else 
        @clothes = Clothe.order(sort_column + ' asc').all
      end
    end
    if sort_direction == "desc"
      @clothes.reverse!
    end
    @clothesPerDay = Clothe.getPerDay
  end
  
  def new
    @clothe = Clothe.new
  end

  def show
    @clothe = Clothe.find(params[:id])
  end
  
  def create
    @clothe = Clothe.new(clothe_params)
    if @clothe.save
      redirect_to action: "index"
    else
      render :new
    end
  end
  def edit
    @clothe = Clothe.find(params[:id])
  end

  def update
    @clothe = Clothe.find(params[:id])
    if @clothe.update(clothe_params)
      redirect_to action: "index"
    else
      render 'edit'
    end
  end

  def wear_today
    @clothe = Clothe.find(params[:format])
    @clothe.wear << Date.today.strftime("%d %b %Y")
    @clothe.save
    flash[:notice] = "#{@clothe.name} is worn today."
    redirect_to clothes_path
  end
  
  private
  def clothe_params
    params.require(:clothe).permit(:name, :brand, :bought, :worn) 
  end

  # default sorting value
  def sort_column
    params[:sort] || "name"
  end
  
  def sort_direction
    params[:direction] || "asc"
  end
end
