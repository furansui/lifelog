class TimeController < ApplicationController
  respond_to :html

  def index
    @summary = Category.summarize()
    respond_with @summary
  end
end
