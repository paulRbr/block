define ['jquery'], ($) ->
  class MainController

    reload: ->
      console.debug("Restarting")
      App.startGame()

    playWithAnyone: (options) ->
      $('#loading-indicator').show()
      console.debug("Go online with anyone!")
      $.get('join_game.json', uuid: App.uuid, (response) ->
        # connect to server via websocket
        App.game_channel = App.dispatcher.subscribe response.token
        if (response.player1 && response.player1.token == App.uuid)
          other = 2
        else
          other = 1
        App.game_channel.bind 'ready', ->
          App.startGame {other_player: other}
        App.game_channel.bind 'finished', (data) ->
          App.stopGame()

        if response.player1
          App.game_channel.trigger 'ready'
      ).fail( (e)->
        console.debug "Impossible to join a game. Server answered: #{e.responseText.error}"
      ).always( ->
        $('#loading-indicator').hide()
      )
      @_setActiveTab('online')

    # Launch a game
    playWithFriend: (id) ->
      console.debug("Go online with a friend!")
      App.startGame()
      @_setActiveTab('online')

    goOffline: ->
      console.debug("Go offline!")
      App.startGame()
      @_setActiveTab('offline')

    _setActiveTab: (tab) ->
      $("#main-menu .tab").removeClass 'active'
      $("##{tab}").addClass 'active'
