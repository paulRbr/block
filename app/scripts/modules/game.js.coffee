define ['modules/game/map', 'jquery', 'underscore', 'backbone', 'marionette'], (MyMap, $) ->
  GameModule = (Game, App, Backbone, Marionette, $) ->

    Game.startWithParent = false

    Game.addInitializer (options) =>
      @newGame(options)

    # CST Number of players
    @players = 2

    # Turn number
    @turn = -1

    @me = -> @turn%@players+1

    Game.on 'stop', =>
      @el.empty()

    Game.newGame = (options) =>
      @m = new MyMap size: options.size, el: options.game_el, game: @
      @m.render()
      @el = $(options.game_el) if options && options.game_el
      if options.other_player && App.game_channel
        @him = options.other_player
        App.game_channel.bind 'play', (data) =>
          @receive(data)
      @render()

    Game.clicked = (here) =>
      space = $(here.target).data("space")
      if space && space.get('state') == 0 && @me() > 0
        if @me() != @him
          if @him
            @publish(space)
          else
            @play(space)

    Game.receive = (here) =>
      console.debug "Je reçois ça : #{here}"
      @play(here)

    Game.publish = (here) =>
      position = "1,2"
      App.game_channel.trigger('play', position)
      console.debug "Je publie ça : #{position}"

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