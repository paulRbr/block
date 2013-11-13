define ['controllers/main_controller', 'jquery', 'websocket_rails', 'underscore', 'backbone', 'marionette'], (MainController, $) ->
  # Create the single page application
  App = new Backbone.Marionette.Application();

  App.addInitializer ->
    # connect to server like normal
    dispatcher = new WebSocketRails('localhost:3000/websocket')
    # subscribe to the channel
    channel = dispatcher.subscribe('my_game');
    channel.bind 'server_msg', (data) ->
      console.log data

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