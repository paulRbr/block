# Main namespace
# Make it publicly available
window.block = {}
b = window.block

# Number of players
b.players = 2

# Turn number
b.turn = 0

# Is it to the next player to play?
b.changeTurn = (sure) ->	
	b.turn++ if sure
		

b.start = (options) ->
	m = new b.MyMap()
	m.init({size: options.size, el: options.el})
	m.render()