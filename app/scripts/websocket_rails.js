/*
WebsocketRails JavaScript Client

Setting up the dispatcher:
  var dispatcher = new WebSocketRails('localhost:3000/websocket');
  dispatcher.on_open = function() {
    // trigger a server event immediately after opening connection
    dispatcher.trigger('new_user',{user_name: 'guest'});
  })

Triggering a new event on the server
  dispatcherer.trigger('event_name',object_to_be_serialized_to_json);

Listening for new events from the server
  dispatcher.bind('event_name', function(data) {
    console.log(data.user_name);
  });
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  this.WebSocketRails = (function() {
    function WebSocketRails(url, use_websockets) {
      this.url = url;
      this.use_websockets = use_websockets != null ? use_websockets : true;
      this.connection_stale = __bind(this.connection_stale, this);
      this.pong = __bind(this.pong, this);
      this.supports_websockets = __bind(this.supports_websockets, this);
      this.dispatch_channel = __bind(this.dispatch_channel, this);
      this.unsubscribe = __bind(this.unsubscribe, this);
      this.subscribe_private = __bind(this.subscribe_private, this);
      this.subscribe = __bind(this.subscribe, this);
      this.dispatch = __bind(this.dispatch, this);
      this.trigger_event = __bind(this.trigger_event, this);
      this.trigger = __bind(this.trigger, this);
      this.bind = __bind(this.bind, this);
      this.connection_established = __bind(this.connection_established, this);
      this.new_message = __bind(this.new_message, this);
      this.state = 'connecting';
      this.callbacks = {};
      this.channels = {};
      this.queue = {};
      if (!(this.supports_websockets() && this.use_websockets)) {
        this._conn = new WebSocketRails.HttpConnection(url, this);
      } else {
        this._conn = new WebSocketRails.WebSocketConnection(url, this);
      }
      this._conn.new_message = this.new_message;
    }

    WebSocketRails.prototype.new_message = function(data) {
      var event, socket_message, _i, _len, _ref, _results;
      _results = [];
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        socket_message = data[_i];
        event = new WebSocketRails.Event(socket_message);
        if (event.is_result()) {
          if ((_ref = this.queue[event.id]) != null) {
            _ref.run_callbacks(event.success, event.data);
          }
          this.queue[event.id] = null;
        } else if (event.is_channel()) {
          this.dispatch_channel(event);
        } else if (event.is_ping()) {
          this.pong();
        } else {
          this.dispatch(event);
        }
        if (this.state === 'connecting' && event.name === 'client_connected') {
          _results.push(this.connection_established(event.data));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    WebSocketRails.prototype.connection_established = function(data) {
      this.state = 'connected';
      this.connection_id = data.connection_id;
      this._conn.flush_queue(data.connection_id);
      if (this.on_open != null) {
        return this.on_open(data);
      }
    };

    WebSocketRails.prototype.bind = function(event_name, callback) {
      var _base;
      if ((_base = this.callbacks)[event_name] == null) {
        _base[event_name] = [];
      }
      return this.callbacks[event_name].push(callback);
    };

    WebSocketRails.prototype.trigger = function(event_name, data, success_callback, failure_callback) {
      var event;
      event = new WebSocketRails.Event([event_name, data, this.connection_id], success_callback, failure_callback);
      this.queue[event.id] = event;
      return this._conn.trigger(event);
    };

    WebSocketRails.prototype.trigger_event = function(event) {
      var _base, _name;
      if ((_base = this.queue)[_name = event.id] == null) {
        _base[_name] = event;
      }
      return this._conn.trigger(event);
    };

    WebSocketRails.prototype.dispatch = function(event) {
      var callback, _i, _len, _ref, _results;
      if (this.callbacks[event.name] == null) {
        return;
      }
      _ref = this.callbacks[event.name];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback(event.data));
      }
      return _results;
    };

    WebSocketRails.prototype.subscribe = function(channel_name) {
      var channel;
      if (this.channels[channel_name] == null) {
        channel = new WebSocketRails.Channel(channel_name, this);
        this.channels[channel_name] = channel;
        return channel;
      } else {
        return this.channels[channel_name];
      }
    };

    WebSocketRails.prototype.subscribe_private = function(channel_name) {
      var channel;
      if (this.channels[channel_name] == null) {
        channel = new WebSocketRails.Channel(channel_name, this, true);
        this.channels[channel_name] = channel;
        return channel;
      } else {
        return this.channels[channel_name];
      }
    };

    WebSocketRails.prototype.unsubscribe = function(channel_name) {
      if (this.channels[channel_name] == null) {
        return;
      }
      this.channels[channel_name].destroy();
      return delete this.channels[channel_name];
    };

    WebSocketRails.prototype.dispatch_channel = function(event) {
      if (this.channels[event.channel] == null) {
        return;
      }
      return this.channels[event.channel].dispatch(event.name, event.data);
    };

    WebSocketRails.prototype.supports_websockets = function() {
      return typeof WebSocket === "function" || typeof WebSocket === "object";
    };

    WebSocketRails.prototype.pong = function() {
      var pong;
      pong = new WebSocketRails.Event(['websocket_rails.pong', {}, this.connection_id]);
      return this._conn.trigger(pong);
    };

    WebSocketRails.prototype.connection_stale = function() {
      return this.state !== 'connected';
    };

    return WebSocketRails;

  })();

}).call(this);
/*
The Event object stores all the relevant event information.
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebSocketRails.Event = (function() {
    function Event(data, success_callback, failure_callback) {
      var attr;
      this.success_callback = success_callback;
      this.failure_callback = failure_callback;
      this.run_callbacks = __bind(this.run_callbacks, this);
      this.attributes = __bind(this.attributes, this);
      this.serialize = __bind(this.serialize, this);
      this.is_ping = __bind(this.is_ping, this);
      this.is_result = __bind(this.is_result, this);
      this.is_channel = __bind(this.is_channel, this);
      this.name = data[0];
      attr = data[1];
      if (attr != null) {
        this.id = attr['id'] != null ? attr['id'] : ((1 + Math.random()) * 0x10000) | 0;
        this.channel = attr.channel != null ? attr.channel : void 0;
        this.data = attr.data != null ? attr.data : attr;
        this.connection_id = data[2];
        if (attr.success != null) {
          this.result = true;
          this.success = attr.success;
        }
      }
    }

    Event.prototype.is_channel = function() {
      return this.channel != null;
    };

    Event.prototype.is_result = function() {
      return this.result === true;
    };

    Event.prototype.is_ping = function() {
      return this.name === 'websocket_rails.ping';
    };

    Event.prototype.serialize = function() {
      return JSON.stringify([this.name, this.attributes()]);
    };

    Event.prototype.attributes = function() {
      return {
        id: this.id,
        channel: this.channel,
        data: this.data
      };
    };

    Event.prototype.run_callbacks = function(success, data) {
      if (success === true) {
        return typeof this.success_callback === "function" ? this.success_callback(data) : void 0;
      } else {
        return typeof this.failure_callback === "function" ? this.failure_callback(data) : void 0;
      }
    };

    return Event;

  })();

}).call(this);
/*
 HTTP Interface for the WebSocketRails client.
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebSocketRails.HttpConnection = (function() {
    HttpConnection.prototype.httpFactories = function() {
      return [
        function() {
          return new XMLHttpRequest();
        }, function() {
          return new ActiveXObject("Msxml2.XMLHTTP");
        }, function() {
          return new ActiveXObject("Msxml3.XMLHTTP");
        }, function() {
          return new ActiveXObject("Microsoft.XMLHTTP");
        }
      ];
    };

    HttpConnection.prototype.createXMLHttpObject = function() {
      var e, factories, factory, xmlhttp, _i, _len;
      xmlhttp = false;
      factories = this.httpFactories();
      for (_i = 0, _len = factories.length; _i < _len; _i++) {
        factory = factories[_i];
        try {
          xmlhttp = factory();
        } catch (_error) {
          e = _error;
          continue;
        }
        break;
      }
      return xmlhttp;
    };

    function HttpConnection(url, dispatcher) {
      this.url = url;
      this.dispatcher = dispatcher;
      this.connectionClosed = __bind(this.connectionClosed, this);
      this.flush_queue = __bind(this.flush_queue, this);
      this.trigger = __bind(this.trigger, this);
      this.parse_stream = __bind(this.parse_stream, this);
      this.createXMLHttpObject = __bind(this.createXMLHttpObject, this);
      this._url = this.url;
      this._conn = this.createXMLHttpObject();
      this.last_pos = 0;
      this.message_queue = [];
      this._conn.onreadystatechange = this.parse_stream;
      this._conn.addEventListener("load", this.connectionClosed, false);
      this._conn.open("GET", this._url, true);
      this._conn.send();
    }

    HttpConnection.prototype.parse_stream = function() {
      var data, decoded_data;
      if (this._conn.readyState === 3) {
        data = this._conn.responseText.substring(this.last_pos);
        this.last_pos = this._conn.responseText.length;
        data = data.replace(/\]\]\[\[/g, "],[");
        decoded_data = JSON.parse(data);
        return this.dispatcher.new_message(decoded_data);
      }
    };

    HttpConnection.prototype.trigger = function(event) {
      if (this.dispatcher.state !== 'connected') {
        return this.message_queue.push(event);
      } else {
        return this.post_data(this.dispatcher.connection_id, event.serialize());
      }
    };

    HttpConnection.prototype.post_data = function(connection_id, payload) {
      return $.ajax(this._url, {
        type: 'POST',
        data: {
          client_id: connection_id,
          data: payload
        },
        success: function() {}
      });
    };

    HttpConnection.prototype.flush_queue = function(connection_id) {
      var event, _i, _len, _ref;
      _ref = this.message_queue;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        if (connection_id != null) {
          event.connection_id = this.dispatcher.connection_id;
        }
        this.trigger(event);
      }
      return this.message_queue = [];
    };

    HttpConnection.prototype.connectionClosed = function(event) {
      var close_event;
      close_event = new WebSocketRails.Event(['connection_closed', event]);
      this.dispatcher.state = 'disconnected';
      return this.dispatcher.dispatch(close_event);
    };

    return HttpConnection;

  })();

}).call(this);
/*
WebSocket Interface for the WebSocketRails client.
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebSocketRails.WebSocketConnection = (function() {
    function WebSocketConnection(url, dispatcher) {
      this.url = url;
      this.dispatcher = dispatcher;
      this.flush_queue = __bind(this.flush_queue, this);
      this.on_error = __bind(this.on_error, this);
      this.on_close = __bind(this.on_close, this);
      this.on_message = __bind(this.on_message, this);
      this.trigger = __bind(this.trigger, this);
      if (this.url.match(/^wss?:\/\//)) {
        console.log("WARNING: Using connection urls with protocol specified is depricated");
      } else if (window.location.protocol === 'http:') {
        this.url = "ws://" + this.url;
      } else {
        this.url = "wss://" + this.url;
      }
      this.message_queue = [];
      this._conn = new WebSocket(this.url);
      this._conn.onmessage = this.on_message;
      this._conn.onclose = this.on_close;
      this._conn.onerror = this.on_error;
    }

    WebSocketConnection.prototype.trigger = function(event) {
      if (this.dispatcher.state !== 'connected') {
        return this.message_queue.push(event);
      } else {
        return this._conn.send(event.serialize());
      }
    };

    WebSocketConnection.prototype.on_message = function(event) {
      var data;
      data = JSON.parse(event.data);
      return this.dispatcher.new_message(data);
    };

    WebSocketConnection.prototype.on_close = function(event) {
      var close_event;
      close_event = new WebSocketRails.Event(['connection_closed', event]);
      this.dispatcher.state = 'disconnected';
      return this.dispatcher.dispatch(close_event);
    };

    WebSocketConnection.prototype.on_error = function(event) {
      var error_event;
      error_event = new WebSocketRails.Event(['connection_error', event]);
      this.dispatcher.state = 'disconnected';
      return this.dispatcher.dispatch(error_event);
    };

    WebSocketConnection.prototype.flush_queue = function() {
      var event, _i, _len, _ref;
      _ref = this.message_queue;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        this._conn.send(event.serialize());
      }
      return this.message_queue = [];
    };

    return WebSocketConnection;

  })();

}).call(this);
/*
The channel object is returned when you subscribe to a channel.

For instance:
  var dispatcher = new WebSocketRails('localhost:3000/websocket');
  var awesome_channel = dispatcher.subscribe('awesome_channel');
  awesome_channel.bind('event', function(data) { console.log('channel event!'); });
  awesome_channel.trigger('awesome_event', awesome_object);
*/


(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  WebSocketRails.Channel = (function() {
    function Channel(name, _dispatcher, is_private) {
      var event, event_name;
      this.name = name;
      this._dispatcher = _dispatcher;
      this.is_private = is_private;
      this._failure_launcher = __bind(this._failure_launcher, this);
      this._success_launcher = __bind(this._success_launcher, this);
      this.dispatch = __bind(this.dispatch, this);
      this.trigger = __bind(this.trigger, this);
      this.bind = __bind(this.bind, this);
      this.destroy = __bind(this.destroy, this);
      if (this.is_private) {
        event_name = 'websocket_rails.subscribe_private';
      } else {
        event_name = 'websocket_rails.subscribe';
      }
      event = new WebSocketRails.Event([
        event_name, {
          data: {
            channel: this.name
          }
        }, this._dispatcher.connection_id
      ], this._success_launcher, this._failure_launcher);
      this._dispatcher.trigger_event(event);
      this._callbacks = {};
    }

    Channel.prototype.destroy = function() {
      var event, event_name;
      event_name = 'websocket_rails.unsubscribe';
      event = new WebSocketRails.Event([
        event_name, {
          data: {
            channel: this.name
          }
        }, this._dispatcher.connection_id
      ]);
      this._dispatcher.trigger_event(event);
      return this._callbacks = {};
    };

    Channel.prototype.bind = function(event_name, callback) {
      var _base;
      if ((_base = this._callbacks)[event_name] == null) {
        _base[event_name] = [];
      }
      return this._callbacks[event_name].push(callback);
    };

    Channel.prototype.trigger = function(event_name, message) {
      var event;
      event = new WebSocketRails.Event([
        event_name, {
          channel: this.name,
          data: message
        }, this._dispatcher.connection_id
      ]);
      return this._dispatcher.trigger_event(event);
    };

    Channel.prototype.dispatch = function(event_name, message) {
      var callback, _i, _len, _ref, _results;
      if (this._callbacks[event_name] == null) {
        return;
      }
      _ref = this._callbacks[event_name];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        callback = _ref[_i];
        _results.push(callback(message));
      }
      return _results;
    };

    Channel.prototype._success_launcher = function(data) {
      if (this.on_success != null) {
        return this.on_success(data);
      }
    };

    Channel.prototype._failure_launcher = function(data) {
      if (this.on_failure != null) {
        return this.on_failure(data);
      }
    };

    return Channel;

  })();

}).call(this);





// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//


;
