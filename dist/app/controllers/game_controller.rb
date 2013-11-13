class GameController < ApplicationController
  def send_msg
    WebsocketRails[:my_game].trigger(:server_msg, "Hello from server!")
    render json: "Done"
  end
end