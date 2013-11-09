define ['map', 'jquery', 'underscore', 'backbone', 'marionette'], (MyMap, $) ->
  class MainController extends Marionette.Controller

    initialize: (options) ->
      @newGame(options)

    # CST Number of players
    players: 2

    # Turn number
    turn: -1

    newGame: (options) ->
      @m = new MyMap()
      @m.init {size: options.size, el: options.el, app: @}
      @m.render()
      @el = $(options.el) if options && options.el
      @render()

    # Is it to the next player to play?
    changeTurn: (sure) ->
      @incrTurn() if sure

    incrTurn: () ->
      @turn++;
      next = @turn%@players+1
      if @hasWinner()
        @info.text("Player #{(@turn-1)%@players+1} won!")
        @info.removeClass().addClass "p#{(@turn-1)%@players+1}"
        @el.find(".space").off('click')
      else
        @info.find("#turn").text("Player #{next}")
        @info.find("#turn").removeClass().addClass "p#{next}"

    hasWinner: () ->
      @m.hasWinner()

    render: () ->
      @info = $ '<div id="info">'
      @info.text("'s turn")
      @info.prepend $('<span id="turn">')
      @el.prepend @info
      @incrTurn()