class Api::V2::TimelogsController < ApplicationController
  respond_to :json, :xml
  protect_from_forgery with: :null_session
  skip_before_filter :authenticate #, :only => :show

  def create
    if params[:categories][0].blank? 
      status = 302
      message = {:message => 'Please specify event (categories)'}
    else
       begin
         timelog = Timelog.parse(time: Time.zone.parse(params[:title]), event: params[:categories][0])
         timelog.update_duration
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
