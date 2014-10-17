class TimelogsController < ApplicationController
  def index
    @timelogs = Timelog.all
  end
  def new
  end
  def create
    @timelog = Timelog.new(timelog_params)
    @timelog.save
    redirect_to @timelog
  end
  def show
    @timelog = Timelog.find(params[:id])
  end

  private
  def timelog_params
    params.require(:timelog).permit(:time, :event)
  end

end

