define ['modules/game/map', 'jquery', 'underscore', 'backbone', 'marionette'], (MyMap, $) ->
  GameModule = (Game, App, Backbone, Marionette, $) ->

    Game.startWithParent = false

    Game.addInitializer (options) =>
      @newGame(options)

    # CST Number of players
    @players = 2

    # Turn number
    @turn = -1

    Game.newGame = (options) =>
      @m = new MyMap()
      @m.init {size: options.size, el: options.game_el, game: @}
      @m.render()
      @el = $(options.game_el) if options && options.game_el
      @render()

    Game.clicked = (here) =>
      space = $(here.target).data("space")
      me = @turn%@players+1
      if space && space.get('state') == 0 && me > 0
        space.set('state', me)
        @incrTurn()

    # Is it to the next player to play?
    Game.changeTurn = (sure) =>
      @incrTurn() if sure

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