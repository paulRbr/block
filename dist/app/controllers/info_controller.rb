class InfoController < ApplicationController

  def connection_params
    render json: {host: request.host, port: Rails.application.config.openshift ? 8000 : request.port}
  end

end