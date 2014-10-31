class TimeController < ApplicationController
  respond_to :html

  def categories
    if(params.has_key?(:time))
      params[:begin] = params["time"]["begin(1i)"]+params["time"]["begin(2i)"]+params["time"]["begin(3i)"]+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"]+params["time"]["end(3i)"]+" 23:59"
    end
    params[:begin] ||= (Time.zone.now-1.week).strftime('%Y-%m-%d 00:00')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d 23:59')

    @summary_begin = Time.zone.parse(params[:begin])
    @summary_end = Time.zone.parse(params[:end])
    @summary = Category.summarize(:begin => @summary_begin, :end => @summary_end)    
    respond_with @summary
  end
  def timelogs
    if(params.has_key?(:time))
      params[:begin] = params["time"]["begin(1i)"]+params["time"]["begin(2i)"]+params["time"]["begin(3i)"]+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"]+params["time"]["end(3i)"]+" 23:59"
    end
    params[:begin] ||= (Time.zone.now-1.week).strftime('%Y-%m-%d 00:00')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d 23:59')

    @summary_begin = Time.zone.parse(params[:begin])
    @summary_end = Time.zone.parse(params[:end])
    range = @summary_begin..@summary_end
    @summary = Timelog.summarize(:range => range)
    respond_with @summary
  end

end
