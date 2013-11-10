require.config({
    paths: {
        jquery: '../bower_components/jquery/jquery',
        requirejs: '../bower_components/requirejs/require',
        backbone: '../bower_components/backbone/backbone',
        marionette: '../bower_components/marionette/lib/backbone.marionette',
        underscore: '../bower_components/underscore/underscore',
        handlebars: '../bower_components/handlebars/handlebars',
        'handlebars.runtime': '../bower_components/handlebars/handlebars.runtime'
    }
});

require(['app'], function(App) {
    'use strict';
    App.start({size: 5, el: '#container'});
});
