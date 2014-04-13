var Bloom, BloomInstance, Comments, frameAutoHeight;

frameAutoHeight = (function(_this) {
  return function(frame) {
    var checkLoaded, lastHeight, loaded, set;
    lastHeight = 0;
    loaded = false;
    set = function() {
      var height;
      height = frame.contentWindow.$('.bloom-comments').height();
      if (height !== lastHeight) {
        $(frame).height(height);
      }
      lastHeight = height;
      return setTimeout(set, 32);
    };
    checkLoaded = function() {
      loaded = frame.contentWindow.$ != null;
      if (loaded) {
        return set();
      } else {
        return setTimeout(checkLoaded, 32);
      }
    };
    return checkLoaded();
  };
})(this);

Comments = (function() {
  Comments.prototype.template = function(id) {
    return "<iframe seamless src=\"/jsapi/frame/template.html#id=" + id + "\"></iframe>";
  };

  function Comments(id, el) {
    this.id = id;
    this.el = el;
    this.render();
  }

  Comments.prototype.render = function() {
    this.$el = $(this.el);
    this.$el.html(this.template(this.id));
    this.frame = this.$el.find('iframe')[0];
    return frameAutoHeight(this.frame);
  };

  Comments.prototype.toFrame = function(action, params) {
    var message;
    message = JSON.stringify({
      action: action,
      params: params
    });
    return this.$el.find('iframe')[0].contentWindow.postMessage(message, '*');
  };

  return Comments;

})();

BloomInstance = (function() {
  function BloomInstance(options) {
    this.apiKey = options.apiKey;
  }

  return BloomInstance;

})();

Bloom = {
  configure: function(options) {
    this.getUsers = options.getUsers;
    return window.BloomInternalConfiguration = options;
  },
  installComments: function(options) {
    var comments;
    comments = new Comments(options.id, options.el);
    return window["BloomComments" + options.id] = {
      getUsers: this.getUsers
    };
  }
};
