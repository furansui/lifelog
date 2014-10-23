class TimeController < ApplicationController
  respond_to :html

  def categories
    @summary = Category.summarize()
    respond_with @summary
  end
  def timelogs
    @summary = Timelog.summarize()
    respond_with @summary
  end

end
