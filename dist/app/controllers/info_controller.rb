class InfoController < ApplicationController

  # GET /connection_params
  # Gives the connection parameters of the WebSockets app server
  # @return {.json} Object containing the host and the port
  def connection_params
    render json: {host: request.host, port: Rails.application.config.openshift ? 8000 : request.port}
  end

  # GET random_game[?uuid=]
  # Generates/Retrieves a game
  # HTTP param uuid for the given player if uuid is provided
  def random_game
    if params[:uuid]
      p = Player.where(token: params[:uuid].html_safe).first_or_create
      g = p.playing.first if p.is_playing?
    end
    g = Game.create if g.nil?
    g.player1 = p unless p.nil?

    render_game g
  end

  # GET join_game/[:id][?uuid=]
  # Retrieves the game if the given player is able to join
  # HTTP param uuid of the player joining the game
  def join_game
    if params[:id]
      g = Game.find_by_token(params[:id])
    else
      g = Game.any_available
    end
    if params[:uuid] && !g.nil? && (g.player1.nil? || g.player2.nil?)
      p = Player.where(token: params[:uuid]).first_or_create
      g.player2 = p if g.player2.nil? && g.player1 != p
      g.player1 = p if g.player1.nil? && g.player2 != p

      if p.playing.first == g
        render_game g
      else
        render json: {error: 'Impossible to join any game, are you already playing?'}, status: 404
      end
    else
      render json: {error: 'Please provide a game token and a player uuid to join a game'}, status: 404
    end
  end

  private

  # @return {.json} Object containing the game_token or an error message if no game
  def render_game(g)
    if !g.nil? && g.save
      render json: g.to_json(include: {player1: {only: :token}}, only: :token)
    else
      render json: {error: "Can not create game #{g}.. Try again later"}, status: 404
    end
  end
end