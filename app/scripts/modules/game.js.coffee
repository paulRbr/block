define ['modules/game/map', 'jquery', 'underscore', 'backbone', 'marionette'], (MyMap, $) ->
  GameModule = (Game, App, Backbone, Marionette, $) ->

    Game.startWithParent = false

    Game.addInitializer (options) =>
      @initialize(options)
      @newGame(options)

    Game.initialize = (options) =>
      # {Number} CST Number of players
      @players = 2
      # {Number} Turn number
      @turn = -1
      # {Number} Player to play
      @me = -> @turn%@players+1
      # {Number} Other player's number if playing online
      @him = null
      @el = $(options.game_el) if options.game_el
      if options.other_player && options.game_channel
        @him = options.other_player
        @game_channel = options.game_channel

    Game.newGame = (options) =>
      @m = new MyMap size: options.size, el: options.game_el, game: @
      @m.render()
      @render()
      if @game_channel
        @game_channel.bind 'play', (data) =>
          @receive(data)

    Game.clicked = (there) =>
      space = $(there.target).data("space")
      if space && space.get('state') == 0 && @me() > 0
        if @me() != @him
          if @him
            @publish(space)
          else
            @play(space)

    Game.receive = (here) =>
      space = @m.states.findWhere(here)
      @play(space)

    Game.publish = (here) =>
      position = {x: here.get('x'), y: here.get('y')}
      @game_channel.trigger 'play', position

    Game.play = (space) =>
        space.set('state', @me())
        @incrTurn()

    Game.incrTurn = () =>
      @turn++;
      next = @turn%@players+1
      if @hasWinner()
        @info.text("Player #{(@turn-1)%@players+1} won!")
        @info.removeClass().addClass "p#{(@turn-1)%@players+1}"
        @el.find(".space").off('click')
      else
        @info.find("#turn").text("Player #{next}")
        @info.find("#turn").removeClass().addClass "p#{next}"

    Game.hasWinner = () =>
      @m.hasWinner()

    Game.render = () =>
      @info = $ '<div id="info">'
      @info.text("'s turn")
      @info.prepend $('<span id="turn">')
      @el.prepend @info
      @incrTurn()