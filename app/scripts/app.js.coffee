define ['controllers/main_controller', 'jquery', 'websocket_rails', 'underscore', 'backbone', 'marionette'], (MainController, $) ->
  # Create the single page application
  App = new Backbone.Marionette.Application();

  App.addInitializer ->
    # Get websocket connection info
    connection_params = {}
    $.get('ws/', (connection_params) ->
      # connect to server like normal
      dispatcher = new WebSocketRails "#{connection_params.host}:#{connection_params.port}/websocket"
      # subscribe to the channel
      channel = dispatcher.subscribe 'my_game'
      channel.bind 'server_msg', (data) ->
        console.log data
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

# Create main router and start history
  App.addInitializer (options) ->
    mainController = new MainController options
    new Marionette.AppRouter(
      controller: mainController
      appRoutes:
        new: 'newGame'
    )
    Backbone.history.start({pushState: true}) if Backbone.history

  return App