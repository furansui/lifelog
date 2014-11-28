class Api::V1::TimelogsController < ApplicationController
  respond_to :json, :xml
  protect_from_forgery with: :null_session
  skip_before_filter :authenticate #, :only => :show

  def create
    message = params[:event]
    if params[:event].blank? 
      status = 302
      message = {:message => 'Please specify event'}
    else
      begin        
        if m=/^(today|yesterday|[0-9]{2,4}(\.|-)[0-9]+(\.|-)[0-9]+)*\s*([0-9]{1,2}:[0-9]{2}(am)*)(.*)/.match(params[:event])
          if m[1].blank?
            params[:time] = Time.zone.parse(m[4])
          else
            params[:time] = Time.zone.parse(m[1]+" "+m[4])
          end
          params[:event] = m[6]
        else
          params[:time] = Time.zone.now
        end

        timelog = Timelog.parse(time: params[:time], event: params[:event])
        Timelog.duration()
        message = {:message => timelog}
      rescue Exception
        message = {:message => 'Error in saving'}
      end
    end
    respond_to do |format|
      format.json { render(:json => message) and return}
      format.xml { render(:xml => message) and return}
    end
  end
end
