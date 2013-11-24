define ['jquery', 'underscore', 'backbone', 'marionette'], ($) ->
  class MainView extends Backbone.Marionette.ItemView
    template: templates.main