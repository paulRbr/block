define ['jquery'], ($) ->
  class MainController

    reload: ->
      App.stopGame()
      $('#waiting-indicator').hide()
      @_setActiveTab('home')
      App.gameRegion.show(new Backbone.Marionette.ItemView(template: templates._welcome))

    playWithAnyone: (options) ->
      App.stopGame()
      $('#loading-indicator').show()
      console.debug("Go online with anyone!")
      $.get('join_game.json', uuid: App.uuid, (response) ->
        # connect to server via websocket
        App.game_channel = App.dispatcher.subscribe response.token
        if (response.player1 && response.player1.token == App.uuid)
          other = 2
          $('#waiting-indicator').hide()
          App.startGame {other_player: other}
        else
          other = 1
          $('#waiting-indicator .info').html('You will play as Player 1.. Please wait for player 2')
          App.game_channel.bind 'ready', ->
            App.startGame {other_player: other}
            $('#waiting-indicator').hide()
        App.game_channel.bind 'finished', (data) ->
          App.stopGame()
        $('#waiting-indicator').show()
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
