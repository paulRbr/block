class GameController < WebsocketRails::BaseController

  def client_connected
    Player.where(token: params[:uuid]).first_or_create
  end

  def client_disconnected
    Player.where(token: params[:uuid]).destroy_all
  end

  def broadcast_players_online
    number_players_online = Player.all.count
    broadcast_message :number_online, number_players_online, namespace: 'info'
  end
end