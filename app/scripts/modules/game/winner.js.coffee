define [], () ->
  class Winner
    constructor: (options) ->
      @current = options.game if options && options.game

    getMap: (player) ->
      if player == 2
        @verticalMap()
      else
        @horizontalMap()

    exists: () ->
      @hasVerticalWin() || @hasHorizontalWin()

    # private

    hasVerticalWin: () ->
      @winner(2)

    hasHorizontalWin: () ->
      @winner(1)

    winner: (player) ->
      start = []
      for i in [0..@current[1].length-1]
        start.push(player)
      _.compact(@nextTouch(start, @getMap(player), player)).length>0

    verticalMap: () ->
      @current.slice().map(@format(2))

    horizontalMap: () ->
      @rotate(@current.slice().map(@format(1)))

    rotate: (board) ->
      rot = []
      for i in [0..(board.length-3)]
        rot[i] = []
        for j in [0..board[1+i].length-1]
          rot[i].push(board[i%2+1+2*j][Math.floor(i/2)])
      rot.unshift(board[0])
      rot.push(board.slice(-1)[0])
      rot


    format: (player) ->
      (row) ->
        row.map (l) ->
          if (l.get('state')==player)
            player
          else
            0

    nextTouch: (currentVertical, remains, player) ->
      if remains[1]
        # Rec
        potentials = currentVertical.slice()
        inter = remains[0]

        search = potentials.slice()
        already = 0
        next = _.indexOf(search, player)
        while(next >= 0)
          already += next
          i=1
          while inter[already-i] == player && i<inter.length
            potentials[already-i] = player
            potentials[already-i+1] = player
            i++
          i=0
          while inter[already+i] == player && i<inter.length
            potentials[already+i] = player
            potentials[already+i+1] = player
            i++
          # Loop forward
          already++
          next = _.indexOf(search.slice(already, Number.MAX_VALUE), player)

        for el, i in remains[1]
          if el == potentials[i] && el == player
            potentials[i] = player
          else
            potentials[i] = 0

        @nextTouch(potentials, remains.slice(2,Number.MAX_VALUE), player)

      else
        # End rec
        currentVertical


