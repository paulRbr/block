class EmptyController < ApplicationController

  # GET /
  def index
    respond_to do |format|
      format.html { render :index } # index.html
    end
  end

end