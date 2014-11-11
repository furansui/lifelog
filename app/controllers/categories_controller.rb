class CategoriesController < ApplicationController
  def index
    @categories = Category.all    
  end
  def new
    @category = Category.new
  end
  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to @category
    else
      render 'new'
    end
  end
  def show
    @category = Category.find(params[:id])
    @timelogs = Timelog.where(category_id: params[:id])
  end
  def edit
    @category = Category.find(params[:id])
  end
  def update
    @category = Category.find(params[:id])
    if @category.update(category_params)
      redirect_to @category
    else
      render 'edit'
    end
  end
  def destroy
    @category = Category.find(params[:id])
    @category.destroy
    redirect_to categories_path
  end
  def import
    Category.import(params[:file])
    redirect_to categories_path, notice: "Categories imported."
  end

  private
  def category_params
    params.require(:category).permit(:name, :notes, :shortcut, :color, :category_id)
  end

end
