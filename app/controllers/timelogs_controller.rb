class TimelogsController < ApplicationController

  def index
    @timelogs = Timelog.all.order("time desc")
    unless request.format.csv?
      @timelogs = @timelogs.paginate(:page => params[:page], :per_page => 25)
    end
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
    @timelog.update_duration
    if @timelog.save      
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
    pr = @timelog.prev
    pr.update_duration
    pr.save
    ne = @timelog.next
    ne.update_duration
    ne.save
    @timelog.destroy
    #Timelog.duration()
    redirect_to timelogs_path
  end
  def delete_multiple
    @timelogs = Timelog.find(params[:timelog_ids])
    @timelogs.each do | timelog|
      pr = timelog.prev
      pr.update_duration
      pr.save
      ne = timelog.next
      ne.update_duration
      ne.save
      timelog.destroy
    end
    #Timelog.duration()
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

