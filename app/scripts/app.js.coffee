define [
  'controllers/main', 'views/main', 'modules/game', 'jquery', 'mustache',
  't', 'websocket_rails', 'underscore', 'backbone', 'marionette', 'cryptojs.sha1'
], (MainController, MainView, GameModule, $, Mustache) ->
  #Override Marionette template renderer
  Backbone.Marionette.Renderer.render = (template, data) ->
    Mustache.to_html(template, data)
  # Create the single page application
  App = window.Block || new Backbone.Marionette.Application()
  # Export the app globally
  window.App = App

  App.addInitializer ->
    App.addRegions {
      mainRegion: "#welcome"
      gameRegion: "#game"
      popupRegion: "#modalContainer"
    }
    App.mainRegion.show(new MainView())
    PasswordModalView = Backbone.Marionette.ItemView.extend({
      template: templates._password
    });
    App.popupRegion.show(new PasswordModalView())

  App.addInitializer ->
    # Get websocket connection info
    App.token = CryptoJS.SHA1(navigator.userAgent + new Date().getTime()).toString()
    connection_params = {}
    $.get('ws/', (connection_params) ->
      # connect to server via websocket
      App.dispatcher = new WebSocketRails "#{connection_params.host}:#{connection_params.port}/websocket?uuid=#{App.token}"
    ).fail( ->
      console.debug 'No websocket server available'
      App.router.navigate('offline', {trigger: true});
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

# Create main router and start history
  App.addInitializer (options) ->
    mainController = new MainController options
    App.router = new Marionette.AppRouter(
      controller: mainController
      appRoutes:
        "online": "goOnline"
        "offline": "goOffline"
    )
    Backbone.history.start({pushState: true}) if Backbone.history

  App.startGame = ->
    App.module "GameModule", GameModule
    App.GameModule.start({size: 5, game_el: '#game', other_player: App.online})

  return App