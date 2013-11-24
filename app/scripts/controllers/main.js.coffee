define [], () ->
  class MainController

    goOnline: (options) ->
      console.debug("Go online!")
      App.startGame()

    goOffline: ->
      console.debug("Go offline!")
      App.startGame()
      button = $('#online.btn')
      button.unbind 'click'
      button.addClass 'active btn-brown'
      $("#welcome").hide()
