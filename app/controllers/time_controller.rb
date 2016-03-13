# -*- coding: utf-8 -*-
class TimeController < ApplicationController
  respond_to :html

  def categories
    if(params.has_key?(:time))
      params[:begin] = params["time"]["begin(1i)"]+params["time"]["begin(2i)"].to_s.rjust(2, '0')+params["time"]["begin(3i)"].to_s.rjust(2, '0')+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"].to_s.rjust(2, '0')+params["time"]["end(3i)"].to_s.rjust(2, '0')+" 23:59"
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
      params[:begin] = params["time"]["begin(1i)"]+params["time"]["begin(2i)"].to_s.rjust(2, '0')+params["time"]["begin(3i)"].to_s.rjust(2, '0')+" 00:00"
      params[:end] = params["time"]["end(1i)"]+params["time"]["end(2i)"].to_s.rjust(2, '0')+params["time"]["end(3i)"].to_s.rjust(2, '0')+" 23:59"
    end
    params[:begin] ||= (Time.zone.now-1.week).strftime('%Y-%m-%d 00:00')
    params[:end] ||= Time.zone.now.strftime('%Y-%m-%d 23:59')

    #Rails.logger.debug("My object params end: #{params[:end]}")
    
    @summary_begin = Time.zone.parse(params[:begin])
    @summary_end = Time.zone.parse(params[:end])
    
    @summary = Timelog.summarize(:begin => @summary_begin, :end => @summary_end)    
    respond_with @summary
  end

  def list
    data = [
            {
              "letter" => "A",
              "frequency" => ".08167"
            },
            {
              "letter" => "B",
              "frequency" => ".01492"
            },
            {
              "letter" => "Z",
              "frequency" => ".00074"
            }
           ]
    render :json => data
  end

end
