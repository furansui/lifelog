class ClothesController < ApplicationController
  def index
    @clothes = Clothe.all.order("name")
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

  private
  def clothe_params
    params.require(:clothe).permit(:name, :brand, :bought)
  end
end
