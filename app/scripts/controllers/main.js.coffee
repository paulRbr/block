define [], () ->
  class MainController

    reload: ->
      console.debug("Restarting")
      App.startGame()

    playWithAnyone: (options) ->
      $('#loading-indicator').show()
      console.debug("Go online with anyone!")
      App.startGame()
      setTimeout ->
        $('#loading-indicator').hide()
      , 2000


    # Launch a game
    playWithFriend: (id) ->
      console.debug("Go online with a friend!")
      App.startGame()

    goOffline: ->
      console.debug("Go offline!")
      App.startGame()
      $('#offline').addClass 'active'
