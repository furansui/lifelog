class ClothesController < ApplicationController
  def index
    @clothes = Clothe.all.order("name")
  end
  
  def new
    msg = nil
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
      msg = @clothe.errors.full_messages
      render :new
    end
  end

  private
  def clothe_params
    params.require(:clothe).permit(:name, :brand)
  end
end
