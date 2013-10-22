class block.State

  init: (options) ->
    @state = 0

  set: (i)->
    if @state == 0 && i > 0
      @state = i
      return true
    else
      return false