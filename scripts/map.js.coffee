class block.MyMap
  # The Map constructor returns the map
  init: (options) ->
    @me = []
    @size = options.size if options.size
    @el = $(options.el) if options.el
    @map = $("<div id='map'></div>").appendTo @el
    @build(2*@size-1) if @size

  build: (n) ->
    if n > 0
      a = []
      if n%2==@size%2
        lim = @size
      else
        lim = @size-1
      while lim>0
        s = new block.State()
        s.init()
        a.push(s)
        lim--
      @me.push(a)
      @build(n-1) if n > 1
    else
      console.warn("You're trying to build a #{n} size map.. Are you sure?")

  render: () ->
    row_num = 0
    for row in @me
      row_num++
      r = $ '<div/>'
      r.addClass 'row'
      if row_num%2
        r.addClass 'odd'
      else
        r.addClass 'even'
      for space in row
        s = $ '<div/>'
        s.addClass 'space'
        s.click (e)->
          block.changeTurn($(e.target).data("space").set(block.turn%block.players+1))
        s.data("space", space)
        space.setEl(s)
        r.append s
      @map.append r
			
    