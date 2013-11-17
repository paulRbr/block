define ['jquery', 'backbone'], ($) ->
  class State extends Backbone.Model
    initialize: ->
      @set('state', 0)