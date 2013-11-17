class GameController < WebsocketRails::BaseController

  def client_connected
    new_player = Player.where(token: params[:uuid]).first_or_create
    p "Hello M. #{new_player.token}"
  end

  def client_disconnected
    old_player = Player.where(token: params[:uuid]).destroy_all
    p "Goodbye M. #{old_player.first.token}"
  end
end