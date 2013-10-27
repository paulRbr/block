require.config({
  shim: {

  },
  paths: {
    backbone: "../../bower_components/backbone/backbone",
    jquery: "../../bower_components/jquery/jquery",
    marionette: "../../bower_components/marionette/lib/backbone.marionette",
    requirejs: "../../bower_components/requirejs/require",
    underscore: "../../bower_components/underscore/underscore",
    handlebars: "../../bower_components/handlebars/handlebars",
    "handlebars.runtime": "../../bower_components/handlebars/handlebars.runtime"
  }
});

require(['app', 'jquery', 'underscore', 'backbone', 'marionette'], function(App) {
  App.start({size: 5, el: '#container'})
});