define ['jquery', 'modules/game/state', 'modules/game/winner'], ($, State, Winner) ->
  class MyMap
    # The Map constructor returns the map
    constructor: (options) ->
      @me = []
      @size = options.size if options.size
      @el = $(options.el) if options.el
      @game = options.game if options.game
      @map = $("<div id='map'></div>").appendTo @el
      @winner = new Winner {game: @me}
      @build(2*@size+1) if @size

    hasWinner: () ->
      @winner.exists()

    build: (n) ->
      if n > 0
        a = []
        if n%2!=@size%2
          lim = @size
        else
          lim = @size-1
        while lim>0
          a.push(new State())
          lim--
        @me.push(a)
        @build(n-1) if n > 1
      else
        console.warn("You're trying to build a #{n} size map.. Are you sure?")

    render: () ->
      row_num = 0
      for row in @me
        r = $ '<div/>'
        r.addClass 'row'
        if row_num%2
          r.addClass 'odd'
        else
          r.addClass 'even'
        for space in row
          i = $ '<div/>'
          i.addClass 'inner'
          s = $ '<div/>'
          s.addClass 'space'
          # Interaction
          if row_num>0 and row_num<@me.length-1
            s.click (here) =>
              @game.clicked(here, true)
            space.on 'change:state', (new_state)->
              new_state.get('el').addClass "state#{new_state.get('state')}"
            s.data "space", space
            space.set 'el', s
          s.append i
          r.append s
        @map.append r
        row_num++