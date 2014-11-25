class TimelogsController < ApplicationController
  def index
    @timelogs = Timelog.all
    respond_to do |format|
      format.html
      format.csv { send_data @timelogs.to_csv}
    end
  end
  def new
    @timelog = Timelog.new
  end
  def create
    @category = Category.find(params[:timelog][:category_id])
    @timelog = @category.timelogs.create(timelog_params)
    if @timelog.save
      Timelog.duration()
      redirect_to @timelog
    else
      render 'new'
    end
  end
  def show
    @timelog = Timelog.find(params[:id])
    @category = Category.find_by_id(@timelog.category_id)
  end
  def edit
    @timelog = Timelog.find(params[:id])
  end
  def update
    @timelog = Timelog.find(params[:id])
    if @timelog.update(timelog_params)
      redirect_to @timelog
    else
      render 'edit'
    end
  end
  def destroy
    @timelog = Timelog.find(params[:id])
    @timelog.destroy
    Timelog.duration()
    redirect_to timelogs_path
  end
  def import
    Timelog.import(params[:file])
    redirect_to timelogs_path, notice: "Timelogs imported."
  end

  private
  def timelog_params
    params.require(:timelog).permit(:time, :event, :category_id)
  end

end

