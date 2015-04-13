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
      system('/home/pi/./upsql.sh&')
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
    pr1 = @timelog.previous.first
    ne1 = @timelog.next.first
    if @timelog.update(timelog_params)
      pr2 = @timelog.previous.first
      ne2 = @timelog.next.first

      if pr1
        pr1.update_duration
        pr1.save
      end
      if ne1
        ne1.update_duration
        ne1.save
      end
      if pr2
        pr2.update_duration
        pr2.save
      end
      if ne2
        ne2.update_duration
        ne2.save
      end
      
      system('/home/pi/./upsql.sh&')

      redirect_to @timelog
    else
      render 'edit'
    end
  end
  def destroy
    @timelog = Timelog.find(params[:id])
    pr = @timelog.previous.first
    if pr
      pr.update_duration
      pr.save
    end
    ne = @timelog.next.first
    if ne
      ne.update_duration
      ne.save
    end
    @timelog.destroy
    #Timelog.duration()
    redirect_to timelogs_path
  end
  def delete_multiple
    @timelogs = Timelog.find(params[:timelog_ids])
    @timelogs.each do | timelog|
      pr = timelog.previous.first
      if pr
        pr.update_duration
        pr.save
      end
      ne = timelog.next.first
      if ne
        ne.update_duration
        ne.save
      end
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

