define ['controllers/main_controller', 'modules/game', 'jquery', 'websocket_rails', 'underscore', 'backbone', 'marionette', 'cryptojs.sha1'], (MainController, GameModule, $) ->
  # Create the single page application
  App = window.Block || new Backbone.Marionette.Application()
  # Export the app globally
  window.Block = App

  App.addInitializer ->
    # Get websocket connection info
    App.uuid = CryptoJS.SHA1(navigator.userAgent + new Date().getTime()).toString()
    connection_params = {}
    $.get('ws/', (connection_params) ->
      # connect to server via websocket
      App.dispatcher = new WebSocketRails "#{connection_params.host}:#{connection_params.port}/websocket?uuid=#{App.uuid}"
    ).fail ->
      console.error 'No websocket server available'

# Prevent default clicks on links for a pushState ready app
  App.addInitializer () ->
    $(document).on 'click', 'a:not([data-bypass])', (evt) ->
      href = $(@).attr('href')
      protocol = @.protocol + '//'
      if (href && href.slice(protocol.length) != protocol)
        evt.preventDefault()
        Backbone.history.navigate(href, true)

  App.addInitializer ->
    App.module "GameModule", GameModule
    App.GameModule.start({size: 5, game_el: '#game'})

# Create main router and start history
  App.addInitializer (options) ->
    mainController = new MainController options
    new Marionette.AppRouter(
      controller: mainController
      appRoutes:
        "index": 'welcome'
    )
    Backbone.history.start({pushState: true}) if Backbone.history

  return App