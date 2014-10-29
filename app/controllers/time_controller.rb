class TimeController < ApplicationController
  respond_to :html

  def categories
    if(params.has_key?(:time))
      params[:start] = params["time"]["start(1i)"]+params["time"]["start(2i)"]+params["time"]["start(3i)"]+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"]+params["time"]["end(3i)"]+" 23:59"
    end
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d 00:00')
    params[:start] ||= (Time.zone.now-1.week).strftime('%Y-%m-%d 23:59')

    @summary_start = Time.zone.parse(params[:start])
    @summary_end = Time.zone.parse(params[:end])
    range = @summary_start..@summary_end
    @summary = Category.summarize(:range => range)
    respond_with @summary
  end
  def timelogs
    if(params.has_key?(:time))
      params[:start] = params["time"]["start(1i)"]+params["time"]["start(2i)"]+params["time"]["start(3i)"]+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"]+params["time"]["end(3i)"]+" 23:59"
    end
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d 00:00')
    params[:start] ||= (Time.zone.now-1.week).strftime('%Y-%m-%d 23:59')

    @summary_start = Time.zone.parse(params[:start])
    @summary_end = Time.zone.parse(params[:end])
    range = @summary_start..@summary_end
    @summary = Timelog.summarize(:range => range)
    respond_with @summary
  end

end
