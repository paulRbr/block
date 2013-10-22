class block.State

  init: (options) ->
    @el = $(options.el) if options && options.el
    @state = 0

  setEl: (elt) ->
    @el ||= $(elt)

  set: (i)->
    if @state == 0 && i > 0
      @state = i
      @el.addClass "state#{i}"
      return true
    else
      return false