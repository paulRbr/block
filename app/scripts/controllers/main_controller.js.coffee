define ['jquery', 'underscore', 'backbone', 'marionette'], ($) ->
  class MainController extends Marionette.Controller

    welcome: (options) ->
      console.log("Welcome!")


