class block.MyMap
  # The Map constructor returns the map
  init: (options) ->
    @me = []
    @size = options.size if options.size
    @el = document.getElementById(options.el) if options.el
    @build(2*@size-1) if @size

  build: (n) ->
    if n > 0
      a = []
      if n%2==@size%2
        lim = @size
      else
        lim = @size-1
      while lim>0
        a.push(0)
        lim--
      @me.push(a)
      @build(n-1) if n > 1
    else
      console.warn("You're trying to build a #{n} size map.. Are you sure?")

  render: () ->
    # Empty