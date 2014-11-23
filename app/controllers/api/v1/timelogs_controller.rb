class Api::V1::TimelogsController < ApplicationController
  respond_to :json, :xml
  protect_from_forgery with: :null_session
  def create
    message = params[:event]
    if params[:event].blank? 
      status = 302
      message = {:message => 'Please specify event'}
    else
      begin
        timelog = Timelog.parse(time: DateTime.now, event: params[:event])
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
