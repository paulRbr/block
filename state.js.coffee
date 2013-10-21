class block.State
	# {Integer} 0: empty, any integer: player number
	state: 0
	
	set: (i)->
		if @state == 0 && i > 0
			@state = i
			return true
		else
			return false