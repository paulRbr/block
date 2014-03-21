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
      @_joinGame {}
      @_setActiveTab('online')

    # Launch a game
    playWithFriend: (queryParams) ->
      params = @_parseQueryParams queryParams || window.location.search
      console.debug("Go online with a friend!")
      @_joinGame(game: params.join_game)
      @_setActiveTab('online')

    goOffline: ->
      console.debug("Go offline!")
      App.startGame()
      @_setActiveTab('offline')

    ##### Private Methods ########

    _joinGame: (opts) ->
      if opts.game
        game = "/#{opts.game}"
      else
        game = ""
      $.get("join_game#{game}.json", uuid: App.uuid, (response) ->
        # connect to server via websocket
        App.game_channel = App.dispatcher.subscribe response.token
        if (response.player1 && response.player1.token == App.uuid)
          other = 2
          $('#waiting-indicator').hide()
          App.startGame(other_player: other)
        else
          other = 1
          game_url = "#{location.protocol}//#{window.location.host}/join_game/#{response.token}"
          App.gameRegion.show(new Backbone.Marionette.ItemView(
            template: templates._game_link
            model: new Backbone.Model({game_url: game_url})
          ))
          $('#waiting-indicator .info').html('You will play as Player 1.. Please wait for player 2')
          App.game_channel.bind 'ready', ->
            $('#waiting-indicator').hide()
            App.startGame(other_player: other)
        App.game_channel.bind 'finished', (data) ->
          App.stopGame()
        $('#waiting-indicator').show()
      ).fail( (e)->
        console.debug "Impossible to join a game. Server answered: #{e.responseText.error}"
      ).always( ->
        $('#loading-indicator').hide()
      )

    _setActiveTab: (tab) ->
      $("#main-menu .tab").removeClass 'active'
      $("##{tab}").addClass 'active'

    _parseQueryParams: (queryString) ->
      return {} unless _.isString(queryString)
      queryString = queryString.substring( queryString.indexOf('?') + 1 )
      params = {}
      queryParts = decodeURI(queryString).split /&/g
      _.each(queryParts, (val) ->
        parts = val.split '='
        if (parts.length >= 1)
          val = undefined
          val = parts[1] if parts.length == 2
          params[parts[0]] = val
      )
      params
