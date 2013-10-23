# Waiting for requirejs expose jquery
window.$ = jQuery

# Main namespace
# Make it publicly available
window.block = {}
b = window.block

# Number of players
b.players = 2

# Turn number
b.turn = -1

# Is it to the next player to play?
b.changeTurn = (sure) ->	
  b.incrTurn() if sure

b.incrTurn = () ->
  b.turn++
  next = b.turn%b.players+1
  b.info.find("#turn").text("Player #{next}")
  b.info.find("#turn").removeClass().addClass "p#{next}"

b.render = () ->
  b.info = $ '<div id="info">'
  b.info.text("'s turn")
  b.info.prepend $('<span id="turn">')
  b.el.prepend b.info
  b.incrTurn()

b.start = (options) ->
  m = new b.MyMap()
  m.init({size: options.size, el: options.el})
  m.render()
  b.el = $(options.el) if options && options.el
  b.render()