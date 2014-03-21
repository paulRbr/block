define [
  'controllers/main', 'modules/game', 'jquery', 'mustache',
  't', 'websocket_rails', 'underscore', 'backbone', 'marionette', 'cryptojs.sha1'
], (MainController, GameModule, $, Mustache) ->
  #Override Marionette template renderer
  Backbone.Marionette.Renderer.render = (template, data) ->
    Mustache.to_html(template, data)
  #Override Marionette view opener to remove wrapping <DIV>
  Backbone.Marionette.Region.prototype.open = (view) ->
    @.$el.hide()
    @.$el.html view.$el.children()
    @.$el.fadeToggle "fast"
  # Create the App
  App = window.App || new Backbone.Marionette.Application()
  # Export the app globally
  window.App = App

  # Helpers to stop/start a game
  App.stopGame = ()->
    App.GameModule.stop()
    $('#game').empty()

  App.startGame = (options)->
    App.stopGame()
    other = options.other_player if options && options.other_player
    App.GameModule.start({size: 5, game_el: '#game', other_player: other, game_channel: App.game_channel})

  # Eendering regions initializer
  App.addInitializer ->
    App.addRegions {
      mainMenuRegion: "#main-menu"
      gameRegion: "#game"
      popupRegion: "#modalContainer"
    }
    App.mainMenuRegion.show(new Backbone.Marionette.ItemView(template: templates._main_menu))
    App.popupRegion.show(new Backbone.Marionette.ItemView(template: templates._online))
    App.gameRegion.show(new Backbone.Marionette.ItemView(template: templates._welcome))

  # Initialize WebSocket - HandShaker with the server
  App.addInitializer ->
    # Get websocket connection info
    App.uuid = CryptoJS.SHA1(navigator.userAgent + new Date().getTime()).toString()
    connection_params = {}
    $.get('ws/', (connection_params) ->
      # connect to server via websocket
      App.dispatcher = new WebSocketRails "#{connection_params.host}:#{connection_params.port}/websocket?uuid=#{App.uuid}"
    ).fail( ->
      console.debug 'No websocket server available'
      App.router.navigate 'offline', trigger: true
    ).always( ->

    )

  # Prevent default clicks on links for a pushState ready app
  App.addInitializer () ->
    $(document).on 'click', 'a:not([data-bypass])', (evt) ->
      href = $(@).attr('href')
      protocol = @.protocol + '//'
      if (href && href.slice(protocol.length) != protocol)
        evt.preventDefault()
        Backbone.history.navigate(href, true)

  # Add Game module to the app
  App.addInitializer ->
    App.module "GameModule", GameModule

  # Create main router and start history
  App.addInitializer (options) ->
    mainController = new MainController options
    App.router = new Backbone.Marionette.AppRouter(
      controller: mainController
      appRoutes:
        "home": "reload"
        "online": "playWithAnyone"
        "create_game": "playWithFriend"
        "join_game*queryparams": "playWithFriend"
        "offline": "goOffline"
    )
    $("#new_game").click ->
      App.router.navigate 'create_game', trigger: true
    $("#random_game").click ->
      App.router.navigate 'online', trigger: true
    Backbone.history.start({pushState: true}) if Backbone.history

  return App