class TimelogsController < ApplicationController
  def index
    @timelogs = Timelog.all
  end
  def new
    @timelog = Timelog.new
  end
  def create
    @timelog = Timelog.new(timelog_params)
    if @timelog.save
      redirect_to @timelog
    else
      render 'new'
    end
  end
  def show
    @timelog = Timelog.find(params[:id])
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

  private
  def timelog_params
    params.require(:timelog).permit(:time, :event)
  end

end

