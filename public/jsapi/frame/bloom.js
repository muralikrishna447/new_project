(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
require('./modules/libs/ng-animate');

require('./modules/libs/ui-router');

require('./modules/libs/angular-strap');

require('./modules/libs/angular-strap.tpl');

require('./modules/settings/module')();

require('./modules/session/module')();

require('./modules/filters')();

require('./modules/ago/module')();

require('./components/input/module')();

require('./components/users/module')();

require('./components/comments/module')();

require('./components/ask/module')();

require('./components/forum/module')();

require('./components/notifs/module')();

require('./components/dashboard/module')();


},{"./components/ask/module":4,"./components/comments/module":19,"./components/dashboard/module":23,"./components/forum/module":31,"./components/input/module":54,"./components/notifs/module":59,"./components/users/module":67,"./modules/ago/module":69,"./modules/filters":71,"./modules/libs/angular-strap":72,"./modules/libs/angular-strap.tpl":73,"./modules/libs/ng-animate":74,"./modules/libs/ui-router":75,"./modules/session/module":76,"./modules/settings/module":77}],2:[function(require,module,exports){
var _this = this;

module.exports = function($compile, $rootScope) {
  return {
    restrict: 'A',
    scope: {
      askQuery: '=',
      asked: '=',
      position: '@'
    },
    link: function(scope, element) {
      var drop, openParams;
      scope.position || (scope.position = 'bottom left');
      /* switch scope.position
        when 'bottom right' then offset = '0px -21px'
        when 'bottom left' then offset = '0px 21px'
        else offset = '0 0'
      */

      drop = new Drop({
        target: element[0],
        content: $compile("<div class=\"holder\"><ask-panel asked=\"asked\" ask-query=\"askQuery\"></ask-panel></div>")(scope)[0],
        position: scope.position || "bottom left",
        classes: 'ask-drop drop-theme-arrows',
        openOn: 'click'
      });
      openParams = {
        type: scope.askType,
        typeId: scope.askTypeId
      };
      drop.on('open', function() {
        $rootScope.$broadcast('askOpened', openParams);
        return $rootScope.$apply();
      });
      return drop.on('close', function() {
        $rootScope.$broadcast('askClosed');
        return $rootScope.$apply();
      });
    }
  };
};


},{}],3:[function(require,module,exports){
var Evented, MIRROR_ATTACH, addClass, allDrops, clickEvents, createContext, extend, hasClass, removeClass, sortAttach, touchDevice, _ref,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

_ref = Tether.Utils, extend = _ref.extend, addClass = _ref.addClass, removeClass = _ref.removeClass, hasClass = _ref.hasClass, Evented = _ref.Evented;

touchDevice = 'ontouchstart' in document.documentElement;

clickEvents = ['click'];

if (touchDevice) {
  clickEvents.push('touchstart');
}

sortAttach = function(str) {
  var first, second, _ref1, _ref2;
  _ref1 = str.split(' '), first = _ref1[0], second = _ref1[1];
  if (first === 'left' || first === 'right') {
    _ref2 = [second, first], first = _ref2[0], second = _ref2[1];
  }
  return [first, second].join(' ');
};

MIRROR_ATTACH = {
  left: 'right',
  right: 'left',
  top: 'bottom',
  bottom: 'top',
  middle: 'middle',
  center: 'center'
};

allDrops = {};

createContext = function(options) {
  var DropInstance, defaultOptions, drop, _name;
  if (options == null) {
    options = {};
  }
  drop = function() {
    return (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return Object(result) === result ? result : child;
    })(DropInstance, arguments, function(){});
  };
  extend(drop, {
    createContext: createContext,
    drops: [],
    defaults: {}
  });
  defaultOptions = {
    classPrefix: 'drop',
    defaults: {
      position: 'bottom left',
      openOn: 'click',
      constrainToScrollParent: true,
      constrainToWindow: true,
      classes: '',
      tetherOptions: {},
      inDelay: 0
    }
  };
  extend(drop, defaultOptions, options);
  extend(drop.defaults, defaultOptions.defaults, options.defaults);
  if (allDrops[_name = drop.classPrefix] == null) {
    allDrops[_name] = [];
  }
  drop.updateBodyClasses = function() {
    var anyOpen, _drop, _i, _len, _ref1;
    anyOpen = false;
    _ref1 = allDrops[drop.classPrefix];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      _drop = _ref1[_i];
      if (!(_drop.isOpened())) {
        continue;
      }
      anyOpen = true;
      break;
    }
    if (anyOpen) {
      return addClass(document.body, "" + drop.classPrefix + "-open");
    } else {
      return removeClass(document.body, "" + drop.classPrefix + "-open");
    }
  };
  DropInstance = (function(_super) {
    __extends(DropInstance, _super);

    function DropInstance(options) {
      this.options = options;
      this.options = extend({}, drop.defaults, this.options);
      this.mouseoverClear = -1;
      this.target = this.options.target;
      if (this.target == null) {
        throw new Error('Drop Error: You must provide a target.');
      }
      if (this.options.classes) {
        addClass(this.target, this.options.classes);
      }
      drop.drops.push(this);
      allDrops[drop.classPrefix].push(this);
      this.setupElements();
      this.setupEvents();
      this.setupTether();
    }

    DropInstance.prototype.setupElements = function() {
      this.drop = document.createElement('div');
      addClass(this.drop, drop.classPrefix);
      if (this.options.classes) {
        addClass(this.drop, this.options.classes);
      }
      this.dropContent = document.createElement('div');
      addClass(this.dropContent, "" + drop.classPrefix + "-content");
      if (typeof this.options.content === 'object') {
        this.dropContent.appendChild(this.options.content);
      } else {
        this.dropContent.innerHTML = this.options.content;
      }
      return this.drop.appendChild(this.dropContent);
    };

    DropInstance.prototype.setupTether = function() {
      var constraints, dropAttach;
      dropAttach = this.options.position.split(' ');
      dropAttach[0] = MIRROR_ATTACH[dropAttach[0]];
      dropAttach = dropAttach.join(' ');
      constraints = [];
      if (this.options.constrainToScrollParent) {
        constraints.push({
          to: 'scrollParent',
          pin: 'top, bottom',
          attachment: 'together none'
        });
      } else {
        constraints.push({
          to: 'scrollParent'
        });
      }
      if (this.options.constrainToWindow !== false) {
        constraints.push({
          to: 'window',
          pin: true,
          attachment: 'together'
        });
      } else {
        constraints.push({
          to: 'window'
        });
      }
      options = {
        element: this.drop,
        target: this.target,
        attachment: sortAttach(dropAttach),
        targetAttachment: sortAttach(this.options.position),
        classPrefix: drop.classPrefix,
        offset: '0 0',
        targetOffset: '0 0',
        enabled: false,
        constraints: constraints
      };
      if (this.options.tetherOptions !== false) {
        return this.tether = new Tether(extend({}, options, this.options.tetherOptions));
      }
    };

    DropInstance.prototype.setupEvents = function() {
      var clickEvent, closeHandler, events, onUs, openHandler, out, outTimeout, over, overDrop, _i, _len,
        _this = this;
      if (!this.options.openOn) {
        return;
      }
      events = this.options.openOn.split(' ');
      if (__indexOf.call(events, 'click') >= 0 || __indexOf.call(events, 'hover') >= 0) {
        openHandler = function(event) {
          _this.toggle();
          return event.preventDefault();
        };
        closeHandler = function(event) {
          if (!_this.isOpened()) {
            return;
          }
          if (event.target === _this.drop || _this.drop.contains(event.target)) {
            return;
          }
          if (event.target === _this.target || _this.target.contains(event.target)) {
            return;
          }
          return _this.close();
        };
        for (_i = 0, _len = clickEvents.length; _i < _len; _i++) {
          clickEvent = clickEvents[_i];
          this.target.addEventListener(clickEvent, openHandler);
          document.addEventListener(clickEvent, closeHandler);
        }
      }
      if (__indexOf.call(events, 'hover') >= 0) {
        onUs = false;
        overDrop = function() {
          onUs = true;
          return _this.open();
        };
        over = function() {
          return _this.mouseoverClear = setTimeout(function() {
            onUs = true;
            return _this.open();
          }, _this.options.inDelay);
        };
        outTimeout = null;
        out = function() {
          onUs = false;
          clearTimeout(_this.mouseoverClear);
          if (outTimeout != null) {
            clearTimeout(outTimeout);
          }
          return outTimeout = setTimeout(function() {
            if (!onUs) {
              _this.close();
            }
            return outTimeout = null;
          }, 300);
        };
        this.target.addEventListener('mouseover', over);
        this.drop.addEventListener('mouseover', overDrop);
        this.target.addEventListener('mouseout', out);
        return this.drop.addEventListener('mouseout', out);
      }
    };

    DropInstance.prototype.isOpened = function() {
      return hasClass(this.drop, "" + drop.classPrefix + "-open");
    };

    DropInstance.prototype.toggle = function() {
      if (this.isOpened()) {
        return this.close();
      } else {
        return this.open();
      }
    };

    DropInstance.prototype.open = function() {
      var _ref1,
        _this = this;
      if (!this.drop.parentNode) {
        document.body.appendChild(this.drop);
      }
      if ((_ref1 = this.tether) != null) {
        _ref1.enable();
      }
      addClass(this.drop, "" + drop.classPrefix + "-open");
      addClass(this.drop, "" + drop.classPrefix + "-open-transitionend");
      setTimeout(function() {
        return addClass(_this.drop, "" + drop.classPrefix + "-after-open");
      });
      this.tether.position();
      this.trigger('open');
      return drop.updateBodyClasses();
    };

    DropInstance.prototype.close = function() {
      var _ref1,
        _this = this;
      removeClass(this.drop, "" + drop.classPrefix + "-open");
      removeClass(this.drop, "" + drop.classPrefix + "-after-open");
      this.drop.addEventListener('transitionend', function() {
        if (!hasClass(_this.drop, "" + drop.classPrefix + "-open")) {
          return removeClass(_this.drop, "" + drop.classPrefix + "-open-transitionend");
        }
      });
      this.trigger('close');
      if ((_ref1 = this.tether) != null) {
        _ref1.disable();
      }
      return drop.updateBodyClasses();
    };

    return DropInstance;

  })(Evented);
  return drop;
};

window.Drop = createContext();

document.addEventListener('DOMContentLoaded', function() {
  return Drop.updateBodyClasses();
});


},{}],4:[function(require,module,exports){
var _this = this;

module.exports = function() {
  require('./tether');
  require('./drop');
  return angular.module('bloom.ask', ['bloom.session']).service('Ask', require('./service')).directive('ask', require('./directive')).controller('AskPanelCtrl', require('./panel/controller')).directive('askPanel', require('./panel/directive'));
};


},{"./directive":2,"./drop":3,"./panel/controller":5,"./panel/directive":6,"./service":8,"./tether":9}],5:[function(require,module,exports){
var _this = this,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function($scope, $timeout, $rootScope, Ask, Session, Users) {
  _this.active = false;
  _this.confirmingUser = false;
  _this.confirmingEmail = false;
  _this.asked = [];
  _this.isEmail = function(to) {
    return __indexOf.call(to, '@') >= 0;
  };
  _this.maybeAskUser = function() {
    if (!$scope.opened) {
      return _this.addUser();
    }
  };
  _this.addUser = function() {
    _this.confirmingUser = true;
    _this.username = 'x' + $scope.newUser.split(' ')[0].toLowerCase();
    _this.asked.push({
      to: $scope.newUser,
      _id: _this.username,
      createdAt: Date.now()
    });
    $timeout(function() {
      return _this.confirmingUser = false;
    }, 500);
    return $scope.$emit('emptyUser');
  };
  _this.refresh = function() {
    return Ask.get($scope.askQuery).then(function(asked) {
      $scope.asked = asked;
      _this.confirmingUser = false;
      return _this.confirmingEmail = false;
    });
  };
  _this.addEmail = function() {
    _this.confirmingEmail = true;
    _this.asked.push({
      to: _this.newEmail,
      createdAt: Date.now()
    });
    _this.newEmail = '';
    return $timeout(function() {
      return _this.confirmingEmail = false;
    }, 500);
  };
  $scope.$on('askOpened', function(options, params) {
    return _this.active = true;
  });
  $scope.$on('askClosed', function() {
    return _this.active = false;
  });
  return _this;
};


},{}],6:[function(require,module,exports){
var names, namesWithIds,
  _this = this;

names = ['Nick Cammarata', 'Andrew Hsu', 'Chris Young', 'Grant Crilly'];

namesWithIds = [
  {
    name: 'Nick Cammarata',
    id: 'xnick'
  }, {
    name: 'Andrew Hsu',
    id: 'xandrew'
  }, {
    name: 'Gene Linetsky',
    id: 'xgene'
  }, {
    name: 'Gregor Freund',
    id: 'xgregor'
  }, {
    name: 'Dylan Pyle',
    id: 'xdylan'
  }
];

module.exports = function($rootScope) {
  return {
    restrict: 'E',
    scope: {
      askQuery: '=',
      asked: '='
    },
    template: require('./template.jade'),
    controller: 'AskPanelCtrl',
    controllerAs: 'panel',
    link: function(scope, element) {
      var askUserInput, myNames, selected;
      scope.opened = false;
      askUserInput = element.find('.ask-user-input');
      $rootScope.$on('emptyUser', function() {
        return askUserInput.val('');
      });
      return;
      askUserInput.bind('typeahead:opened', function() {
        var _this = this;
        return scope.$apply(function() {
          return scope.opened = true;
        });
      });
      askUserInput.bind('typeahead:closed', function() {
        var _this = this;
        return scope.$apply(function() {
          return scope.opened = false;
        });
      });
      selected = function(event, person) {
        var _this = this;
        return scope.$apply(function() {
          return scope.newUser = person.name;
        });
      };
      askUserInput.bind('typeahead:autocompleted', selected);
      askUserInput.bind('typeahead:selected', selected);
      myNames = new Bloodhound({
        datumTokenizer: function(d) {
          return Bloodhound.tokenizers.whitespace(d.name);
        },
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        local: namesWithIds
      });
      myNames.initialize();
      return askUserInput.typeahead(null, {
        displayKey: 'name',
        source: myNames.ttAdapter(),
        templates: {
          suggestion: function(obj) {
            return "<img src=\"/images/users/" + obj.id + ".png\"> " + obj.name;
          }
        }
      });
    }
  };
};


},{"./template.jade":7}],7:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"ask-answer-wrapper\"><div class=\"ask-user\"><input type=\"text\" maxlength=\"40\" on-enter=\"panel.maybeAskUser()\" placeholder=\"Type user name, or...\" class=\"ask-user-input\"/><button ng-click=\"panel.addUser()\" ng-class=\"{'confirm': panel.confirmingUser}\" class=\"ask-answer-button\"><span ng-show=\"!panel.confirmingUser\">Ask</span><i ng-show=\"panel.confirmingUser\" ng-cloak=\"ng-cloak\" class=\"fa fa-refresh fa-spin\"></i></button></div><div class=\"ask-email\"><input type=\"text\" ng-model=\"panel.newEmail\" on-enter=\"panel.addEmail()\" maxlength=\"40\" placeholder=\"Ask via email here.\"/><button ng-click=\"panel.addEmail()\" ng-class=\"{confirm: panel.confirmingEmail}\" class=\"ask-answer-button\"><span ng-hide=\"panel.confirmingEmail\" ng-cloak=\"ng-cloak\">Ask</span><i ng-show=\"panel.confirmingEmail\" ng-cloak=\"ng-cloak\" class=\"fa fa-refresh fa-spin\"></i></button></div><div ng-show=\"panel.asked.length &gt; 0\" class=\"ask-answer-list\"><h4>Already asked ({{panel.asked.length}}):</h4><ul><li ng-repeat=\"invite in panel.asked | orderBy:'createdAt':true\"><div ng-if=\"!panel.isEmail(invite.to)\" class=\"user\"><div class=\"user-avatar\"><img width=\"35\" height=\"35\" ng-src=\"/images/users/{{invite._id}}.png\"/></div><span class=\"user-name\"><span>{{invite.to}}</span></span><span class=\"bull\">&bull;</span><span class=\"time\">{{invite.createdAt | ago}}</span></div><div ng-if=\"panel.isEmail(invite.to)\" class=\"email\"><a href=\"#\">{{invite.to}}</a><span class=\"bull\">&bull;</span><span class=\"time\">{{invite.createdAt | ago}}</span></div></li></ul></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],8:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return _this;
};


},{}],9:[function(require,module,exports){
/*! tether 0.5.2 */
(function() {
  var Evented, addClass, defer, deferred, extend, flush, getBounds, getOffsetParent, getOrigin, getScrollParent, hasClass, node, removeClass, uniqueId, updateClasses, zeroPosCache,
    __hasProp = {}.hasOwnProperty,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __slice = [].slice;

  if (window.Tether == null) {
    window.Tether = {};
  }

  getScrollParent = function(el) {
    var parent, position, scrollParent, style, _ref;
    position = getComputedStyle(el).position;
    if (position === 'fixed') {
      return el;
    }
    scrollParent = void 0;
    parent = el;
    while (parent = parent.parentNode) {
      try {
        style = getComputedStyle(parent);
      } catch (_error) {}
      if (style == null) {
        return parent;
      }
      if (/(auto|scroll)/.test(style['overflow'] + style['overflow-y'] + style['overflow-x'])) {
        if (position !== 'absolute' || ((_ref = style['position']) === 'relative' || _ref === 'absolute' || _ref === 'fixed')) {
          return parent;
        }
      }
    }
    return document.body;
  };

  uniqueId = (function() {
    var id;
    id = 0;
    return function() {
      return id++;
    };
  })();

  zeroPosCache = {};

  getOrigin = function(doc) {
    var id, k, node, v, _ref;
    node = doc._tetherZeroElement;
    if (node == null) {
      node = doc.createElement('div');
      node.setAttribute('data-tether-id', uniqueId());
      extend(node.style, {
        top: 0,
        left: 0,
        position: 'absolute'
      });
      doc.body.appendChild(node);
      doc._tetherZeroElement = node;
    }
    id = node.getAttribute('data-tether-id');
    if (zeroPosCache[id] == null) {
      zeroPosCache[id] = {};
      _ref = node.getBoundingClientRect();
      for (k in _ref) {
        v = _ref[k];
        zeroPosCache[id][k] = v;
      }
      defer(function() {
        return zeroPosCache[id] = void 0;
      });
    }
    return zeroPosCache[id];
  };

  node = null;

  getBounds = function(el) {
    var box, doc, docEl, k, origin, v, _ref;
    if (el === document) {
      doc = document;
      el = document.documentElement;
    } else {
      doc = el.ownerDocument;
    }
    docEl = doc.documentElement;
    box = {};
    _ref = el.getBoundingClientRect();
    for (k in _ref) {
      v = _ref[k];
      box[k] = v;
    }
    origin = getOrigin(doc);
    box.top -= origin.top;
    box.left -= origin.left;
    if (box.width == null) {
      box.width = document.body.scrollWidth - box.left - box.right;
    }
    if (box.height == null) {
      box.height = document.body.scrollHeight - box.top - box.bottom;
    }
    box.top = box.top - docEl.clientTop;
    box.left = box.left - docEl.clientLeft;
    box.right = doc.body.clientWidth - box.width - box.left;
    box.bottom = doc.body.clientHeight - box.height - box.top;
    return box;
  };

  getOffsetParent = function(el) {
    return el.offsetParent || document.documentElement;
  };

  extend = function(out) {
    var args, key, obj, val, _i, _len, _ref;
    if (out == null) {
      out = {};
    }
    args = [];
    Array.prototype.push.apply(args, arguments);
    _ref = args.slice(1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      obj = _ref[_i];
      if (obj) {
        for (key in obj) {
          if (!__hasProp.call(obj, key)) continue;
          val = obj[key];
          out[key] = val;
        }
      }
    }
    return out;
  };

  removeClass = function(el, name) {
    var cls, _i, _len, _ref, _results;
    if (el.classList != null) {
      _ref = name.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cls = _ref[_i];
        _results.push(el.classList.remove(cls));
      }
      return _results;
    } else {
      return el.className = el.className.replace(new RegExp("(^| )" + (name.split(' ').join('|')) + "( |$)", 'gi'), ' ');
    }
  };

  addClass = function(el, name) {
    var cls, _i, _len, _ref, _results;
    if (el.classList != null) {
      _ref = name.split(' ');
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cls = _ref[_i];
        _results.push(el.classList.add(cls));
      }
      return _results;
    } else {
      removeClass(el, name);
      return el.className += " " + name;
    }
  };

  hasClass = function(el, name) {
    if (el.classList != null) {
      return el.classList.contains(name);
    } else {
      return new RegExp("(^| )" + name + "( |$)", 'gi').test(el.className);
    }
  };

  updateClasses = function(el, add, all) {
    var cls, _i, _j, _len, _len1, _results;
    for (_i = 0, _len = all.length; _i < _len; _i++) {
      cls = all[_i];
      if (__indexOf.call(add, cls) < 0) {
        if (hasClass(el, cls)) {
          removeClass(el, cls);
        }
      }
    }
    _results = [];
    for (_j = 0, _len1 = add.length; _j < _len1; _j++) {
      cls = add[_j];
      if (!hasClass(el, cls)) {
        _results.push(addClass(el, cls));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  deferred = [];

  defer = function(fn) {
    return deferred.push(fn);
  };

  flush = function() {
    var fn, _results;
    _results = [];
    while (fn = deferred.pop()) {
      _results.push(fn());
    }
    return _results;
  };

  Evented = (function() {
    function Evented() {}

    Evented.prototype.on = function(event, handler, ctx, once) {
      var _base;
      if (once == null) {
        once = false;
      }
      if (this.bindings == null) {
        this.bindings = {};
      }
      if ((_base = this.bindings)[event] == null) {
        _base[event] = [];
      }
      return this.bindings[event].push({
        handler: handler,
        ctx: ctx,
        once: once
      });
    };

    Evented.prototype.once = function(event, handler, ctx) {
      return this.on(event, handler, ctx, true);
    };

    Evented.prototype.off = function(event, handler) {
      var i, _ref, _results;
      if (((_ref = this.bindings) != null ? _ref[event] : void 0) == null) {
        return;
      }
      if (handler == null) {
        return delete this.bindings[event];
      } else {
        i = 0;
        _results = [];
        while (i < this.bindings[event].length) {
          if (this.bindings[event][i].handler === handler) {
            _results.push(this.bindings[event].splice(i, 1));
          } else {
            _results.push(i++);
          }
        }
        return _results;
      }
    };

    Evented.prototype.trigger = function() {
      var args, ctx, event, handler, i, once, _ref, _ref1, _results;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      if ((_ref = this.bindings) != null ? _ref[event] : void 0) {
        i = 0;
        _results = [];
        while (i < this.bindings[event].length) {
          _ref1 = this.bindings[event][i], handler = _ref1.handler, ctx = _ref1.ctx, once = _ref1.once;
          handler.apply(ctx != null ? ctx : this, args);
          if (once) {
            _results.push(this.bindings[event].splice(i, 1));
          } else {
            _results.push(i++);
          }
        }
        return _results;
      }
    };

    return Evented;

  })();

  Tether.Utils = {
    getScrollParent: getScrollParent,
    getBounds: getBounds,
    getOffsetParent: getOffsetParent,
    extend: extend,
    addClass: addClass,
    removeClass: removeClass,
    hasClass: hasClass,
    updateClasses: updateClasses,
    defer: defer,
    flush: flush,
    uniqueId: uniqueId,
    Evented: Evented
  };

}).call(this);

(function() {
  var MIRROR_LR, MIRROR_TB, OFFSET_MAP, addClass, addOffset, attachmentToOffset, autoToFixedAttachment, defer, extend, flush, getBounds, getOffsetParent, getOuterSize, getScrollParent, getSize, now, offsetToPx, parseAttachment, parseOffset, position, removeClass, tethers, transformKey, updateClasses, within, _Tether, _ref,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  if (typeof Tether === "undefined" || Tether === null) {
    throw new Error("You must include the utils.js file before tether.js");
  }

  _ref = Tether.Utils, getScrollParent = _ref.getScrollParent, getSize = _ref.getSize, getOuterSize = _ref.getOuterSize, getBounds = _ref.getBounds, getOffsetParent = _ref.getOffsetParent, extend = _ref.extend, addClass = _ref.addClass, removeClass = _ref.removeClass, updateClasses = _ref.updateClasses, defer = _ref.defer, flush = _ref.flush;

  within = function(a, b, diff) {
    if (diff == null) {
      diff = 1;
    }
    return (a + diff >= b && b >= a - diff);
  };

  transformKey = (function() {
    var el, key, _i, _len, _ref1;
    el = document.createElement('div');
    _ref1 = ['transform', 'webkitTransform', 'OTransform', 'MozTransform', 'msTransform'];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      key = _ref1[_i];
      if (el.style[key] !== void 0) {
        return key;
      }
    }
  })();

  tethers = [];

  position = function() {
    var tether, _i, _len;
    for (_i = 0, _len = tethers.length; _i < _len; _i++) {
      tether = tethers[_i];
      tether.position(false);
    }
    return flush();
  };

  now = function() {
    var _ref1;
    return (_ref1 = typeof performance !== "undefined" && performance !== null ? typeof performance.now === "function" ? performance.now() : void 0 : void 0) != null ? _ref1 : +(new Date);
  };

  (function() {
    var event, lastCall, lastDuration, pendingTimeout, tick, _i, _len, _ref1, _results;
    lastCall = null;
    lastDuration = null;
    pendingTimeout = null;
    tick = function() {
      if ((lastDuration != null) && lastDuration > 16) {
        lastDuration = Math.min(lastDuration - 16, 250);
        pendingTimeout = setTimeout(tick, 250);
        return;
      }
      if ((lastCall != null) && (now() - lastCall) < 10) {
        return;
      }
      if (pendingTimeout != null) {
        clearTimeout(pendingTimeout);
        pendingTimeout = null;
      }
      lastCall = now();
      position();
      return lastDuration = now() - lastCall;
    };
    _ref1 = ['resize', 'scroll', 'touchmove'];
    _results = [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      event = _ref1[_i];
      _results.push(window.addEventListener(event, tick));
    }
    return _results;
  })();

  MIRROR_LR = {
    center: 'center',
    left: 'right',
    right: 'left'
  };

  MIRROR_TB = {
    middle: 'middle',
    top: 'bottom',
    bottom: 'top'
  };

  OFFSET_MAP = {
    top: 0,
    left: 0,
    middle: '50%',
    center: '50%',
    bottom: '100%',
    right: '100%'
  };

  autoToFixedAttachment = function(attachment, relativeToAttachment) {
    var left, top;
    left = attachment.left, top = attachment.top;
    if (left === 'auto') {
      left = MIRROR_LR[relativeToAttachment.left];
    }
    if (top === 'auto') {
      top = MIRROR_TB[relativeToAttachment.top];
    }
    return {
      left: left,
      top: top
    };
  };

  attachmentToOffset = function(attachment) {
    var _ref1, _ref2;
    return {
      left: (_ref1 = OFFSET_MAP[attachment.left]) != null ? _ref1 : attachment.left,
      top: (_ref2 = OFFSET_MAP[attachment.top]) != null ? _ref2 : attachment.top
    };
  };

  addOffset = function() {
    var left, offsets, out, top, _i, _len, _ref1;
    offsets = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    out = {
      top: 0,
      left: 0
    };
    for (_i = 0, _len = offsets.length; _i < _len; _i++) {
      _ref1 = offsets[_i], top = _ref1.top, left = _ref1.left;
      if (typeof top === 'string') {
        top = parseFloat(top, 10);
      }
      if (typeof left === 'string') {
        left = parseFloat(left, 10);
      }
      out.top += top;
      out.left += left;
    }
    return out;
  };

  offsetToPx = function(offset, size) {
    if (typeof offset.left === 'string' && offset.left.indexOf('%') !== -1) {
      offset.left = parseFloat(offset.left, 10) / 100 * size.width;
    }
    if (typeof offset.top === 'string' && offset.top.indexOf('%') !== -1) {
      offset.top = parseFloat(offset.top, 10) / 100 * size.height;
    }
    return offset;
  };

  parseAttachment = parseOffset = function(value) {
    var left, top, _ref1;
    _ref1 = value.split(' '), top = _ref1[0], left = _ref1[1];
    return {
      top: top,
      left: left
    };
  };

  _Tether = (function() {
    _Tether.modules = [];

    function _Tether(options) {
      this.position = __bind(this.position, this);
      var module, _i, _len, _ref1, _ref2;
      tethers.push(this);
      this.history = [];
      this.setOptions(options, false);
      _ref1 = Tether.modules;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        module = _ref1[_i];
        if ((_ref2 = module.initialize) != null) {
          _ref2.call(this);
        }
      }
      this.position();
    }

    _Tether.prototype.getClass = function(key) {
      var _ref1, _ref2;
      if ((_ref1 = this.options.classes) != null ? _ref1[key] : void 0) {
        return this.options.classes[key];
      } else if (((_ref2 = this.options.classes) != null ? _ref2[key] : void 0) !== false) {
        if (this.options.classPrefix) {
          return "" + this.options.classPrefix + "-" + key;
        } else {
          return key;
        }
      } else {
        return '';
      }
    };

    _Tether.prototype.setOptions = function(options, position) {
      var defaults, key, _i, _len, _ref1, _ref2;
      this.options = options;
      if (position == null) {
        position = true;
      }
      defaults = {
        offset: '0 0',
        targetOffset: '0 0',
        targetAttachment: 'auto auto',
        classPrefix: 'tether'
      };
      this.options = extend(defaults, this.options);
      _ref1 = this.options, this.element = _ref1.element, this.target = _ref1.target, this.targetModifier = _ref1.targetModifier;
      if (this.target === 'viewport') {
        this.target = document.body;
        this.targetModifier = 'visible';
      } else if (this.target === 'scroll-handle') {
        this.target = document.body;
        this.targetModifier = 'scroll-handle';
      }
      _ref2 = ['element', 'target'];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        key = _ref2[_i];
        if (this[key] == null) {
          throw new Error("Tether Error: Both element and target must be defined");
        }
        if (this[key].jquery != null) {
          this[key] = this[key][0];
        } else if (typeof this[key] === 'string') {
          this[key] = document.querySelector(this[key]);
        }
      }
      addClass(this.element, this.getClass('element'));
      addClass(this.target, this.getClass('target'));
      if (!this.options.attachment) {
        throw new Error("Tether Error: You must provide an attachment");
      }
      this.targetAttachment = parseAttachment(this.options.targetAttachment);
      this.attachment = parseAttachment(this.options.attachment);
      this.offset = parseOffset(this.options.offset);
      this.targetOffset = parseOffset(this.options.targetOffset);
      if (this.scrollParent != null) {
        this.disable();
      }
      if (this.targetModifier === 'scroll-handle') {
        this.scrollParent = this.target;
      } else {
        this.scrollParent = getScrollParent(this.target);
      }
      if (this.options.enabled !== false) {
        return this.enable(position);
      }
    };

    _Tether.prototype.getTargetBounds = function() {
      var bounds, fitAdj, hasBottomScroll, height, out, scrollBottom, scrollPercentage, style, target;
      if (this.targetModifier != null) {
        switch (this.targetModifier) {
          case 'visible':
            if (this.target === document.body) {
              return {
                top: pageYOffset,
                left: pageXOffset,
                height: innerHeight,
                width: innerWidth
              };
            } else {
              bounds = getBounds(this.target);
              out = {
                height: bounds.height,
                width: bounds.width,
                top: bounds.top,
                left: bounds.left
              };
              out.height = Math.min(out.height, bounds.height - (pageYOffset - bounds.top));
              out.height = Math.min(out.height, bounds.height - ((bounds.top + bounds.height) - (pageYOffset + innerHeight)));
              out.height = Math.min(innerHeight, out.height);
              out.height -= 2;
              out.width = Math.min(out.width, bounds.width - (pageXOffset - bounds.left));
              out.width = Math.min(out.width, bounds.width - ((bounds.left + bounds.width) - (pageXOffset + innerWidth)));
              out.width = Math.min(innerWidth, out.width);
              out.width -= 2;
              if (out.top < pageYOffset) {
                out.top = pageYOffset;
              }
              if (out.left < pageXOffset) {
                out.left = pageXOffset;
              }
              return out;
            }
            break;
          case 'scroll-handle':
            target = this.target;
            if (target === document.body) {
              target = document.documentElement;
              bounds = {
                left: pageXOffset,
                top: pageYOffset,
                height: innerHeight,
                width: innerWidth
              };
            } else {
              bounds = getBounds(target);
            }
            style = getComputedStyle(target);
            hasBottomScroll = target.scrollWidth > target.clientWidth || 'scroll' === [style.overflow, style.overflowX] || this.target !== document.body;
            scrollBottom = 0;
            if (hasBottomScroll) {
              scrollBottom = 15;
            }
            height = bounds.height - parseFloat(style.borderTopWidth) - parseFloat(style.borderBottomWidth) - scrollBottom;
            out = {
              width: 15,
              height: height * 0.975 * (height / target.scrollHeight),
              left: bounds.left + bounds.width - parseFloat(style.borderLeftWidth) - 15
            };
            fitAdj = 0;
            if (height < 408 && this.target === document.body) {
              fitAdj = -0.00011 * Math.pow(height, 2) - 0.00727 * height + 22.58;
            }
            if (this.target !== document.body) {
              out.height = Math.max(out.height, 24);
            }
            scrollPercentage = this.target.scrollTop / (target.scrollHeight - height);
            out.top = scrollPercentage * (height - out.height - fitAdj) + bounds.top + parseFloat(style.borderTopWidth);
            if (this.target === document.body) {
              out.height = Math.max(out.height, 24);
            }
            return out;
        }
      } else {
        return getBounds(this.target);
      }
    };

    _Tether.prototype.clearCache = function() {
      return this._cache = {};
    };

    _Tether.prototype.cache = function(k, getter) {
      if (this._cache == null) {
        this._cache = {};
      }
      if (this._cache[k] == null) {
        this._cache[k] = getter.call(this);
      }
      return this._cache[k];
    };

    _Tether.prototype.enable = function(position) {
      if (position == null) {
        position = true;
      }
      addClass(this.target, this.getClass('enabled'));
      addClass(this.element, this.getClass('enabled'));
      this.enabled = true;
      if (this.scrollParent !== document) {
        this.scrollParent.addEventListener('scroll', this.position);
      }
      if (position) {
        return this.position();
      }
    };

    _Tether.prototype.disable = function() {
      removeClass(this.target, this.getClass('enabled'));
      removeClass(this.element, this.getClass('enabled'));
      this.enabled = false;
      if (this.scrollParent != null) {
        return this.scrollParent.removeEventListener('scroll', this.position);
      }
    };

    _Tether.prototype.destroy = function() {
      var i, tether, _i, _len, _results;
      this.disable();
      _results = [];
      for (i = _i = 0, _len = tethers.length; _i < _len; i = ++_i) {
        tether = tethers[i];
        if (tether === this) {
          tethers.splice(i, 1);
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    _Tether.prototype.updateAttachClasses = function(elementAttach, targetAttach) {
      var add, all, side, sides, _i, _j, _len, _len1, _ref1,
        _this = this;
      if (elementAttach == null) {
        elementAttach = this.attachment;
      }
      if (targetAttach == null) {
        targetAttach = this.targetAttachment;
      }
      sides = ['left', 'top', 'bottom', 'right', 'middle', 'center'];
      if ((_ref1 = this._addAttachClasses) != null ? _ref1.length : void 0) {
        this._addAttachClasses.splice(0, this._addAttachClasses.length);
      }
      add = this._addAttachClasses != null ? this._addAttachClasses : this._addAttachClasses = [];
      if (elementAttach.top) {
        add.push("" + (this.getClass('element-attached')) + "-" + elementAttach.top);
      }
      if (elementAttach.left) {
        add.push("" + (this.getClass('element-attached')) + "-" + elementAttach.left);
      }
      if (targetAttach.top) {
        add.push("" + (this.getClass('target-attached')) + "-" + targetAttach.top);
      }
      if (targetAttach.left) {
        add.push("" + (this.getClass('target-attached')) + "-" + targetAttach.left);
      }
      all = [];
      for (_i = 0, _len = sides.length; _i < _len; _i++) {
        side = sides[_i];
        all.push("" + (this.getClass('element-attached')) + "-" + side);
      }
      for (_j = 0, _len1 = sides.length; _j < _len1; _j++) {
        side = sides[_j];
        all.push("" + (this.getClass('target-attached')) + "-" + side);
      }
      return defer(function() {
        if (_this._addAttachClasses == null) {
          return;
        }
        updateClasses(_this.element, _this._addAttachClasses, all);
        updateClasses(_this.target, _this._addAttachClasses, all);
        return _this._addAttachClasses = void 0;
      });
    };

    _Tether.prototype.position = function(flushChanges) {
      var elementPos, elementStyle, height, left, manualOffset, manualTargetOffset, module, next, offset, offsetBorder, offsetParent, offsetParentSize, offsetParentStyle, offsetPosition, ret, scrollLeft, scrollTop, side, targetAttachment, targetOffset, targetPos, targetSize, top, width, _i, _j, _len, _len1, _ref1, _ref2, _ref3, _ref4,
        _this = this;
      if (flushChanges == null) {
        flushChanges = true;
      }
      if (!this.enabled) {
        return;
      }
      this.clearCache();
      targetAttachment = autoToFixedAttachment(this.targetAttachment, this.attachment);
      this.updateAttachClasses(this.attachment, targetAttachment);
      elementPos = this.cache('element-bounds', function() {
        return getBounds(_this.element);
      });
      width = elementPos.width, height = elementPos.height;
      if (width === 0 && height === 0 && (this.lastSize != null)) {
        _ref1 = this.lastSize, width = _ref1.width, height = _ref1.height;
      } else {
        this.lastSize = {
          width: width,
          height: height
        };
      }
      targetSize = targetPos = this.cache('target-bounds', function() {
        return _this.getTargetBounds();
      });
      offset = offsetToPx(attachmentToOffset(this.attachment), {
        width: width,
        height: height
      });
      targetOffset = offsetToPx(attachmentToOffset(targetAttachment), targetSize);
      manualOffset = offsetToPx(this.offset, {
        width: width,
        height: height
      });
      manualTargetOffset = offsetToPx(this.targetOffset, targetSize);
      offset = addOffset(offset, manualOffset);
      targetOffset = addOffset(targetOffset, manualTargetOffset);
      left = targetPos.left + targetOffset.left - offset.left;
      top = targetPos.top + targetOffset.top - offset.top;
      _ref2 = Tether.modules;
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        module = _ref2[_i];
        ret = module.position.call(this, {
          left: left,
          top: top,
          targetAttachment: targetAttachment,
          targetPos: targetPos,
          attachment: this.attachment,
          elementPos: elementPos,
          offset: offset,
          targetOffset: targetOffset,
          manualOffset: manualOffset,
          manualTargetOffset: manualTargetOffset
        });
        if ((ret == null) || typeof ret !== 'object') {
          continue;
        } else if (ret === false) {
          return false;
        } else {
          top = ret.top, left = ret.left;
        }
      }
      next = {
        page: {
          top: top,
          bottom: document.body.scrollHeight - top - height,
          left: left,
          right: document.body.scrollWidth - left - width
        },
        viewport: {
          top: top - pageYOffset,
          bottom: pageYOffset - top - height + innerHeight,
          left: left - pageXOffset,
          right: pageXOffset - left - width + innerWidth
        }
      };
      if (((_ref3 = this.options.optimizations) != null ? _ref3.moveElement : void 0) !== false && (this.targetModifier == null)) {
        offsetParent = this.cache('target-offsetparent', function() {
          return getOffsetParent(_this.target);
        });
        offsetPosition = this.cache('target-offsetparent-bounds', function() {
          return getBounds(offsetParent);
        });
        offsetParentStyle = getComputedStyle(offsetParent);
        elementStyle = getComputedStyle(this.element);
        offsetParentSize = offsetPosition;
        offsetBorder = {};
        _ref4 = ['Top', 'Left', 'Bottom', 'Right'];
        for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
          side = _ref4[_j];
          offsetBorder[side.toLowerCase()] = parseFloat(offsetParentStyle["border" + side + "Width"]);
        }
        offsetPosition.right = document.body.scrollWidth - offsetPosition.left - offsetParentSize.width + offsetBorder.right;
        offsetPosition.bottom = document.body.scrollHeight - offsetPosition.top - offsetParentSize.height + offsetBorder.bottom;
        if (next.page.top >= (offsetPosition.top + offsetBorder.top) && next.page.bottom >= offsetPosition.bottom) {
          if (next.page.left >= (offsetPosition.left + offsetBorder.left) && next.page.right >= offsetPosition.right) {
            scrollTop = offsetParent.scrollTop;
            scrollLeft = offsetParent.scrollLeft;
            next.offset = {
              top: next.page.top - offsetPosition.top + scrollTop - offsetBorder.top,
              left: next.page.left - offsetPosition.left + scrollLeft - offsetBorder.left
            };
          }
        }
      }
      this.move(next);
      this.history.unshift(next);
      if (this.history.length > 3) {
        this.history.pop();
      }
      if (flushChanges) {
        flush();
      }
      return true;
    };

    _Tether.prototype.move = function(position) {
      var css, elVal, found, key, moved, offsetParent, point, same, transcribe, type, val, write, writeCSS, _i, _len, _ref1, _ref2,
        _this = this;
      if (this.element.parentNode == null) {
        return;
      }
      same = {};
      for (type in position) {
        same[type] = {};
        for (key in position[type]) {
          found = false;
          _ref1 = this.history;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            point = _ref1[_i];
            if (!within((_ref2 = point[type]) != null ? _ref2[key] : void 0, position[type][key])) {
              found = true;
              break;
            }
          }
          if (!found) {
            same[type][key] = true;
          }
        }
      }
      css = {
        top: '',
        left: '',
        right: '',
        bottom: ''
      };
      transcribe = function(same, pos) {
        var xPos, yPos, _ref3;
        if (((_ref3 = _this.options.optimizations) != null ? _ref3.gpu : void 0) !== false) {
          if (same.top) {
            css.top = 0;
            yPos = pos.top;
          } else {
            css.bottom = 0;
            yPos = -pos.bottom;
          }
          if (same.left) {
            css.left = 0;
            xPos = pos.left;
          } else {
            css.right = 0;
            xPos = -pos.right;
          }
          css[transformKey] = "translateX(" + (Math.round(xPos)) + "px) translateY(" + (Math.round(yPos)) + "px)";
          if (transformKey !== 'msTransform') {
            return css[transformKey] += " translateZ(0)";
          }
        } else {
          if (same.top) {
            css.top = "" + pos.top + "px";
          } else {
            css.bottom = "" + pos.bottom + "px";
          }
          if (same.left) {
            return css.left = "" + pos.left + "px";
          } else {
            return css.right = "" + pos.right + "px";
          }
        }
      };
      moved = false;
      if ((same.page.top || same.page.bottom) && (same.page.left || same.page.right)) {
        css.position = 'absolute';
        transcribe(same.page, position.page);
      } else if ((same.viewport.top || same.viewport.bottom) && (same.viewport.left || same.viewport.right)) {
        css.position = 'fixed';
        transcribe(same.viewport, position.viewport);
      } else if ((same.offset != null) && same.offset.top && same.offset.left) {
        css.position = 'absolute';
        offsetParent = this.cache('target-offsetparent', function() {
          return getOffsetParent(_this.target);
        });
        if (getOffsetParent(this.element) !== offsetParent) {
          defer(function() {
            _this.element.parentNode.removeChild(_this.element);
            return offsetParent.appendChild(_this.element);
          });
        }
        transcribe(same.offset, position.offset);
        moved = true;
      } else {
        css.position = 'absolute';
        transcribe({
          top: true,
          left: true
        }, position.page);
      }
      if (!moved && this.element.parentNode.tagName !== 'BODY') {
        this.element.parentNode.removeChild(this.element);
        document.body.appendChild(this.element);
      }
      writeCSS = {};
      write = false;
      for (key in css) {
        val = css[key];
        elVal = this.element.style[key];
        if (elVal !== '' && val !== '' && (key === 'top' || key === 'left' || key === 'bottom' || key === 'right')) {
          elVal = parseFloat(elVal);
          val = parseFloat(val);
        }
        if (elVal !== val) {
          write = true;
          writeCSS[key] = css[key];
        }
      }
      if (write) {
        return defer(function() {
          return extend(_this.element.style, writeCSS);
        });
      }
    };

    return _Tether;

  })();

  Tether.position = position;

  window.Tether = extend(_Tether, Tether);

}).call(this);

(function() {
  var BOUNDS_FORMAT, MIRROR_ATTACH, defer, extend, getBoundingRect, getBounds, getOuterSize, getSize, updateClasses, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  _ref = Tether.Utils, getOuterSize = _ref.getOuterSize, getBounds = _ref.getBounds, getSize = _ref.getSize, extend = _ref.extend, updateClasses = _ref.updateClasses, defer = _ref.defer;

  MIRROR_ATTACH = {
    left: 'right',
    right: 'left',
    top: 'bottom',
    bottom: 'top',
    middle: 'middle'
  };

  BOUNDS_FORMAT = ['left', 'top', 'right', 'bottom'];

  getBoundingRect = function(tether, to) {
    var i, pos, side, size, style, _i, _len;
    if (to === 'scrollParent') {
      to = tether.scrollParent;
    } else if (to === 'window') {
      to = [pageXOffset, pageYOffset, innerWidth + pageXOffset, innerHeight + pageYOffset];
    }
    if (to === document) {
      to = to.documentElement;
    }
    if (to.nodeType != null) {
      pos = size = getBounds(to);
      style = getComputedStyle(to);
      to = [pos.left, pos.top, size.width + pos.left, size.height + pos.top];
      for (i = _i = 0, _len = BOUNDS_FORMAT.length; _i < _len; i = ++_i) {
        side = BOUNDS_FORMAT[i];
        side = side[0].toUpperCase() + side.substr(1);
        if (side === 'Top' || side === 'Left') {
          to[i] += parseFloat(style["border" + side + "Width"]);
        } else {
          to[i] -= parseFloat(style["border" + side + "Width"]);
        }
      }
    }
    return to;
  };

  Tether.modules.push({
    position: function(_arg) {
      var addClasses, allClasses, attachment, bounds, changeAttachX, changeAttachY, cls, constraint, eAttachment, height, left, oob, oobClass, p, pin, pinned, pinnedClass, removeClass, side, tAttachment, targetAttachment, targetHeight, targetSize, targetWidth, to, top, width, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
        _this = this;
      top = _arg.top, left = _arg.left, targetAttachment = _arg.targetAttachment;
      if (!this.options.constraints) {
        return true;
      }
      removeClass = function(prefix) {
        var side, _i, _len, _results;
        _this.removeClass(prefix);
        _results = [];
        for (_i = 0, _len = BOUNDS_FORMAT.length; _i < _len; _i++) {
          side = BOUNDS_FORMAT[_i];
          _results.push(_this.removeClass("" + prefix + "-" + side));
        }
        return _results;
      };
      _ref1 = this.cache('element-bounds', function() {
        return getBounds(_this.element);
      }), height = _ref1.height, width = _ref1.width;
      if (width === 0 && height === 0 && (this.lastSize != null)) {
        _ref2 = this.lastSize, width = _ref2.width, height = _ref2.height;
      }
      targetSize = this.cache('target-bounds', function() {
        return _this.getTargetBounds();
      });
      targetHeight = targetSize.height;
      targetWidth = targetSize.width;
      tAttachment = {};
      eAttachment = {};
      allClasses = [this.getClass('pinned'), this.getClass('out-of-bounds')];
      _ref3 = this.options.constraints;
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        constraint = _ref3[_i];
        if (constraint.outOfBoundsClass) {
          allClasses.push(constraint.outOfBoundsClass);
        }
        if (constraint.pinnedClass) {
          allClasses.push(constraint.pinnedClass);
        }
      }
      for (_j = 0, _len1 = allClasses.length; _j < _len1; _j++) {
        cls = allClasses[_j];
        _ref4 = ['left', 'top', 'right', 'bottom'];
        for (_k = 0, _len2 = _ref4.length; _k < _len2; _k++) {
          side = _ref4[_k];
          allClasses.push("" + cls + "-" + side);
        }
      }
      addClasses = [];
      tAttachment = extend({}, targetAttachment);
      eAttachment = extend({}, this.attachment);
      _ref5 = this.options.constraints;
      for (_l = 0, _len3 = _ref5.length; _l < _len3; _l++) {
        constraint = _ref5[_l];
        to = constraint.to, attachment = constraint.attachment, pin = constraint.pin;
        if (attachment == null) {
          attachment = '';
        }
        if (__indexOf.call(attachment, ' ') >= 0) {
          _ref6 = attachment.split(' '), changeAttachY = _ref6[0], changeAttachX = _ref6[1];
        } else {
          changeAttachX = changeAttachY = attachment;
        }
        bounds = getBoundingRect(this, to);
        if (changeAttachY === 'target' || changeAttachY === 'both') {
          if (top < bounds[1] && tAttachment.top === 'top') {
            top += targetHeight;
            tAttachment.top = 'bottom';
          }
          if (top + height > bounds[3] && tAttachment.top === 'bottom') {
            top -= targetHeight;
            tAttachment.top = 'top';
          }
        }
        if (changeAttachY === 'together') {
          if (top < bounds[1] && tAttachment.top === 'top') {
            if (eAttachment.top === 'bottom') {
              top += targetHeight;
              tAttachment.top = 'bottom';
              top += height;
              eAttachment.top = 'top';
            } else if (eAttachment.top === 'top') {
              top += targetHeight;
              tAttachment.top = 'bottom';
              top -= height;
              eAttachment.top = 'bottom';
            }
          }
          if (top + height > bounds[3] && tAttachment.top === 'bottom') {
            if (eAttachment.top === 'top') {
              top -= targetHeight;
              tAttachment.top = 'top';
              top -= height;
              eAttachment.top = 'bottom';
            } else if (eAttachment.top === 'bottom') {
              top -= targetHeight;
              tAttachment.top = 'top';
              top += height;
              eAttachment.top = 'top';
            }
          }
        }
        if (changeAttachX === 'target' || changeAttachX === 'both') {
          if (left < bounds[0] && tAttachment.left === 'left') {
            left += targetWidth;
            tAttachment.left = 'right';
          }
          if (left + width > bounds[2] && tAttachment.left === 'right') {
            left -= targetWidth;
            tAttachment.left = 'left';
          }
        }
        if (changeAttachX === 'together') {
          if (left < bounds[0] && tAttachment.left === 'left') {
            if (eAttachment.left === 'right') {
              left += targetWidth;
              tAttachment.left = 'right';
              left += width;
              eAttachment.left = 'left';
            } else if (eAttachment.left === 'left') {
              left += targetWidth;
              tAttachment.left = 'right';
              left -= width;
              eAttachment.left = 'right';
            }
          } else if (left + width > bounds[2] && tAttachment.left === 'right') {
            if (eAttachment.left === 'left') {
              left -= targetWidth;
              tAttachment.left = 'left';
              left -= width;
              eAttachment.left = 'right';
            } else if (eAttachment.left === 'right') {
              left -= targetWidth;
              tAttachment.left = 'left';
              left += width;
              eAttachment.left = 'left';
            }
          }
        }
        if (changeAttachY === 'element' || changeAttachY === 'both') {
          if (top < bounds[1] && eAttachment.top === 'bottom') {
            top += height;
            eAttachment.top = 'top';
          }
          if (top + height > bounds[3] && eAttachment.top === 'top') {
            top -= height;
            eAttachment.top = 'bottom';
          }
        }
        if (changeAttachX === 'element' || changeAttachX === 'both') {
          if (left < bounds[0] && eAttachment.left === 'right') {
            left += width;
            eAttachment.left = 'left';
          }
          if (left + width > bounds[2] && eAttachment.left === 'left') {
            left -= width;
            eAttachment.left = 'right';
          }
        }
        if (typeof pin === 'string') {
          pin = (function() {
            var _len4, _m, _ref7, _results;
            _ref7 = pin.split(',');
            _results = [];
            for (_m = 0, _len4 = _ref7.length; _m < _len4; _m++) {
              p = _ref7[_m];
              _results.push(p.trim());
            }
            return _results;
          })();
        } else if (pin === true) {
          pin = ['top', 'left', 'right', 'bottom'];
        }
        pin || (pin = []);
        pinned = [];
        oob = [];
        if (top < bounds[1]) {
          if (__indexOf.call(pin, 'top') >= 0) {
            top = bounds[1];
            pinned.push('top');
          } else {
            oob.push('top');
          }
        }
        if (top + height > bounds[3]) {
          if (__indexOf.call(pin, 'bottom') >= 0) {
            top = bounds[3] - height;
            pinned.push('bottom');
          } else {
            oob.push('bottom');
          }
        }
        if (left < bounds[0]) {
          if (__indexOf.call(pin, 'left') >= 0) {
            left = bounds[0];
            pinned.push('left');
          } else {
            oob.push('left');
          }
        }
        if (left + width > bounds[2]) {
          if (__indexOf.call(pin, 'right') >= 0) {
            left = bounds[2] - width;
            pinned.push('right');
          } else {
            oob.push('right');
          }
        }
        if (pinned.length) {
          pinnedClass = (_ref7 = this.options.pinnedClass) != null ? _ref7 : this.getClass('pinned');
          addClasses.push(pinnedClass);
          for (_m = 0, _len4 = pinned.length; _m < _len4; _m++) {
            side = pinned[_m];
            addClasses.push("" + pinnedClass + "-" + side);
          }
        }
        if (oob.length) {
          oobClass = (_ref8 = this.options.outOfBoundsClass) != null ? _ref8 : this.getClass('out-of-bounds');
          addClasses.push(oobClass);
          for (_n = 0, _len5 = oob.length; _n < _len5; _n++) {
            side = oob[_n];
            addClasses.push("" + oobClass + "-" + side);
          }
        }
        if (__indexOf.call(pinned, 'left') >= 0 || __indexOf.call(pinned, 'right') >= 0) {
          eAttachment.left = tAttachment.left = false;
        }
        if (__indexOf.call(pinned, 'top') >= 0 || __indexOf.call(pinned, 'bottom') >= 0) {
          eAttachment.top = tAttachment.top = false;
        }
        if (tAttachment.top !== targetAttachment.top || tAttachment.left !== targetAttachment.left || eAttachment.top !== this.attachment.top || eAttachment.left !== this.attachment.left) {
          this.updateAttachClasses(eAttachment, tAttachment);
        }
      }
      defer(function() {
        updateClasses(_this.target, addClasses, allClasses);
        return updateClasses(_this.element, addClasses, allClasses);
      });
      return {
        top: top,
        left: left
      };
    }
  });

}).call(this);

(function() {
  var defer, getBounds, updateClasses, _ref;

  _ref = Tether.Utils, getBounds = _ref.getBounds, updateClasses = _ref.updateClasses, defer = _ref.defer;

  Tether.modules.push({
    position: function(_arg) {
      var abutted, addClasses, allClasses, bottom, height, left, right, side, sides, targetPos, top, width, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref1, _ref2, _ref3, _ref4, _ref5,
        _this = this;
      top = _arg.top, left = _arg.left;
      _ref1 = this.cache('element-bounds', function() {
        return getBounds(_this.element);
      }), height = _ref1.height, width = _ref1.width;
      targetPos = this.getTargetBounds();
      bottom = top + height;
      right = left + width;
      abutted = [];
      if (top <= targetPos.bottom && bottom >= targetPos.top) {
        _ref2 = ['left', 'right'];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          side = _ref2[_i];
          if ((_ref3 = targetPos[side]) === left || _ref3 === right) {
            abutted.push(side);
          }
        }
      }
      if (left <= targetPos.right && right >= targetPos.left) {
        _ref4 = ['top', 'bottom'];
        for (_j = 0, _len1 = _ref4.length; _j < _len1; _j++) {
          side = _ref4[_j];
          if ((_ref5 = targetPos[side]) === top || _ref5 === bottom) {
            abutted.push(side);
          }
        }
      }
      allClasses = [];
      addClasses = [];
      sides = ['left', 'top', 'right', 'bottom'];
      allClasses.push(this.getClass('abutted'));
      for (_k = 0, _len2 = sides.length; _k < _len2; _k++) {
        side = sides[_k];
        allClasses.push("" + (this.getClass('abutted')) + "-" + side);
      }
      if (abutted.length) {
        addClasses.push(this.getClass('abutted'));
      }
      for (_l = 0, _len3 = abutted.length; _l < _len3; _l++) {
        side = abutted[_l];
        addClasses.push("" + (this.getClass('abutted')) + "-" + side);
      }
      defer(function() {
        updateClasses(_this.target, addClasses, allClasses);
        return updateClasses(_this.element, addClasses, allClasses);
      });
      return true;
    }
  });

}).call(this);

(function() {
  Tether.modules.push({
    position: function(_arg) {
      var left, result, shift, shiftLeft, shiftTop, top, _ref;
      top = _arg.top, left = _arg.left;
      if (!this.options.shift) {
        return;
      }
      result = function(val) {
        if (typeof val === 'function') {
          return val.call(this, {
            top: top,
            left: left
          });
        } else {
          return val;
        }
      };
      shift = result(this.options.shift);
      if (typeof shift === 'string') {
        shift = shift.split(' ');
        shift[1] || (shift[1] = shift[0]);
        shiftTop = shift[0], shiftLeft = shift[1];
        shiftTop = parseFloat(shiftTop, 10);
        shiftLeft = parseFloat(shiftLeft, 10);
      } else {
        _ref = [shift.top, shift.left], shiftTop = _ref[0], shiftLeft = _ref[1];
      }
      top += shiftTop;
      left += shiftLeft;
      return {
        top: top,
        left: left
      };
    }
  });

}).call(this);
},{}],10:[function(require,module,exports){
/**
  * x is a value between 0 and 1, indicating where in the animation you are.
  */
var duScrollDefaultEasing = function (x) {
  if(x < 0.5) {
    return Math.pow(x*2, 2)/2;
  }
  return 1-Math.pow((1-x)*2, 2)/2;
};

angular.module('duScroll', ['duScroll.scroller', 'duScroll.scrollPosition', 'duScroll.scrollspy', 'duScroll.requestAnimation', 'duScroll.smoothScroll']).value('duScrollDuration', 1000).value('duScrollEasing', duScrollDefaultEasing);

angular.module('duScroll.requestAnimation', []).
factory('requestAnimation', function($window, $timeout) {
  return $window.requestAnimationFrame  ||
    $window.webkitRequestAnimationFrame ||
    $window.mozRequestAnimationFrame    ||
    $window.oRequestAnimationFrame      ||
    $window.msRequestAnimationFrame     ||
    function fallback( callback ){
      $timeout(callback, 1000 / 60);
    };
});

angular.module('duScroll.scrollPosition', ['duScroll.requestAnimation']).
factory('scrollPosition',
  function($document, $rootScope, $timeout, requestAnimation) {
    scrollDiv = $('.comments-scroll')[0];
    if (scrollDiv == undefined) { return false; }
    var getScrollY = function() {
      return scrollDiv.scrollY || document.documentElement.scrollTop || document.body.scrollTop;
    };

    var getScrollX = function() {
      return scrollDiv.scrollX || document.documentElement.scrollLeft || document.body.scrollLeft;
    };

    var observers = [];
    var lastScrollY;
    var currentScrollY;
    
    var executeCallbacks = function(){
      currentScrollY = lastScrollY;
      $rootScope.$emit('$duScrollChanged', currentScrollY);
      for(var i = 0; i < observers.length; i++){
        observers[i](currentScrollY);
      }
    };

    var onScroll = function(){
      lastScrollY = getScrollY();

      if(lastScrollY !== currentScrollY){
        requestAnimation(executeCallbacks);
      }
    };

    angular.element($document).on('scroll', onScroll).triggerHandler('scroll');

    var deprecationWarned = false;
    return {
      observe : function(cb){
        if(!deprecationWarned && console && console.warn) {
          console.warn('scrollPosition.observe is deprecated, use $rootScope.$on(\'$duScrollChanged\') instead');
          deprecationWarned = true;
        }
        observers.push(cb);
      }, 
      x: getScrollX, 
      y: getScrollY
    };
  }
);

angular.module('duScroll.scroller', ['duScroll.requestAnimation']).
factory('scroller',
  function(requestAnimation, $window, scrollPosition, duScrollEasing) {
    scrollDiv = $('.comments-scroll')[0]
    function scrollTo(x, y, duration){
      if(!duration) {
        scrollDiv.scrollTop = y;
        return;
      }
      var start = {
        y: scrollPosition.y(),
        x: scrollPosition.x()
      };
      var delta = {
        y: Math.round(y - start.y),
        x: Math.round(x - start.x)
      };
      if(!delta.x && !delta.y) return;

      var frame = 0;
      var frames = Math.ceil(duration/60);
      var animate = function() {
        frame++;
        var percent = (frame === frames ? 1 : duScrollEasing(frame/frames));

        scrollDiv.scrollTop = start.y + Math.ceil(delta.y * percent);
        if(frame<frames) {
          requestAnimation(animate);
        }
      };
      animate();
    }
    
    function scrollDelta(x, y, duration){
      scrollTo(scrollPosition.x() + (x || 0), scrollPosition.y() + (y || 0), duration);
    }

    function scrollToElement(element, offset, duration){
      if(!angular.isElement(element)) { return; }
      //Remove jQuery wrapper (if any)
      element = element[0] || element;
      if(!element.getBoundingClientRect) return;

      var pos = element.getBoundingClientRect();

      scrollDelta(0, pos.top + (!offset || isNaN(offset) ? 0 : -offset), duration);
    }

    return {
      scrollTo:         scrollTo,
      scrollToElement:  scrollToElement,
      scrollDelta:      scrollDelta
    };
  }
);


angular.module('duScroll.smoothScroll', ['duScroll.scroller']).
directive('duSmoothScroll', function(scroller, duScrollDuration){

  return {
    link : function($scope, $element, $attr){
      var element = angular.element($element[0]);
      element.on('click', function(e){
        if(!$attr.href || $attr.href.indexOf('#') === -1) return;
        var elem = document.getElementById($attr.href.replace(/.*(?=#[^\s]+$)/, '').substring(1));
        if(!elem || !elem.getBoundingClientRect) return;
        
        if (e.stopPropagation) e.stopPropagation();
        if (e.preventDefault) e.preventDefault();

        var offset = -($attr.offset ? parseInt($attr.offset, 10) : 0);
        var duration = $attr.duration ? parseInt($attr.duration, 10) : duScrollDuration;
        var pos = elem.getBoundingClientRect();

        scroller.scrollDelta(0, pos.top + (isNaN(offset) ? 0 : offset), duration);
      });
    }
  };
});


angular.module('duScroll.scrollspy', ['duScroll.scrollPosition']).
factory('duSpyAPI', function($rootScope, scrollPosition) {
  var contexts = {};
  var isObserving = false;

  var createContext = function($scope) {
    var id = $scope.$id;
    contexts[id] = {
      spies: []
    };
    return id;
  };
  var defaultContextId = createContext($rootScope);

  var gotScroll = function($event, scrollY) {
    var i, id, context, currentlyActive, toBeActive, spies, spy, pos;

    for(id in contexts) {
      context = contexts[id];
      spies = context.spies;
      currentlyActive = context.currentlyActive;
      toBeActive = undefined;

      for(i = 0; i < spies.length; i++) {
        spy = spies[i];
        pos = spy.getTargetPosition();
        if (!pos) continue;

        if(pos.top + spy.offset < 20 && pos.top*-1 < pos.height) {
          if(!toBeActive || toBeActive.top < pos.top) {
            toBeActive = {
              top: pos.top,
              spy: spy
            };
          }
        }
      }
      if(toBeActive) {
        toBeActive = toBeActive.spy;
      }
      if(currentlyActive === toBeActive) continue;
      if(currentlyActive) {
        currentlyActive.$element.removeClass('active');
        $rootScope.$broadcast('duScrollspy:becameInactive', currentlyActive.$element);
      }
      if(toBeActive) {
        toBeActive.$element.addClass('active');
        $rootScope.$broadcast('duScrollspy:becameActive', toBeActive.$element);
      }
      context.currentlyActive = toBeActive;
    }
  };

  var getContextForScope = function(scope) {
    if(contexts[scope.$id]) {
      return contexts[scope.$id];
    }
    if(scope.$parent) {
      return getContextForScope(scope.$parent);
    }
    return contexts[defaultContextId];
  };

  var getContextForSpy = function(spy) {
    return getContextForScope(spy.$element.scope());
  };

  var addSpy = function(spy) {
    if(!isObserving) {
      $rootScope.$on('$duScrollChanged', gotScroll);
      isObserving = true;
    }
    getContextForSpy(spy).spies.push(spy);
  };

  var removeSpy = function(spy) {
    var context = getContextForSpy(spy);
    if(spy === context.currentlyActive) {
      context.currentlyActive = null;
    }
    var i = context.spies.indexOf(spy);
    if(i !== -1) {
      context.spies.splice(i, 1);
    }
  };

  return {
    addSpy: addSpy,
    removeSpy: removeSpy, 
    createContext: createContext
  };
}).
directive('duSpyContext', function(duSpyAPI) {
  return {
    restrict: 'A',
    scope: true,
    compile: function compile(tElement, tAttrs, transclude) {
      return {
        pre: function preLink($scope, iElement, iAttrs, controller) {
          duSpyAPI.createContext($scope);
        }
      };
    }
  };
}).
directive('duScrollspy', function(duSpyAPI) {
  var Spy = function(targetElementOrId, $element, offset) {
    if(angular.isElement(targetElementOrId)) {
      this.target = targetElementOrId;
    } else if(angular.isString(targetElementOrId)) {
      this.targetId = targetElementOrId;
    }
    this.$element = $element;
    this.offset = offset;
  };

  Spy.prototype.getTargetElement = function() {
    if (!this.target && this.targetId) {
      this.target = document.getElementById(this.targetId);
    }
    return this.target;
  };

  Spy.prototype.getTargetPosition = function() {
    var target = this.getTargetElement();
    if(target) {
      return target.getBoundingClientRect();
    }
  };

  Spy.prototype.flushTargetCache = function() {
    if(this.targetId) {
      this.target = undefined;
    }
  };

  return {
    link: function ($scope, $element, $attr) {
      var href = $attr.ngHref || $attr.href;
      var targetId;

      if (href && href.indexOf('#') !== -1) {
        targetId = href.replace(/.*(?=#[^\s]+$)/, '').substring(1);
      } else if($attr.duScrollspy) {
        targetId = $attr.duScrollspy;
      }
      if(!targetId) return;

      var spy = new Spy(targetId, $element, -($attr.offset ? parseInt($attr.offset, 10) : 0));
      duSpyAPI.addSpy(spy);

      $scope.$on('$destroy', function() {
        duSpyAPI.removeSpy(spy);
      });
      $scope.$on('$locationChangeSuccess', spy.flushTargetCache.bind(spy));
    }
  };
});

},{}],11:[function(require,module,exports){
var _this = this;

module.exports = function($scope, $timeout, Users, BloomSettings, Session, Comments) {
  var ctrl, setUpvoteTooltip;
  ctrl = {};
  ctrl.depth = +$scope.depth;
  ctrl.db = $scope.db;
  ctrl.dbParams = $scope.dbParams;
  ctrl.bloomSettings = BloomSettings;
  ctrl.showLikes = false;
  ctrl.owner = Session.me === ctrl.db.author;
  setUpvoteTooltip = function() {
    return Users.getList(_.pluck(ctrl.db.upvotes, 'author')).then(function(users) {
      var tooltipNames;
      tooltipNames = _.pluck(users, 'name');
      ctrl.likeTooltip = tooltipNames.join('<br/>');
      return ctrl.tooltip = {
        title: ctrl.likeTooltip
      };
    });
  };
  setUpvoteTooltip();
  ctrl.collapsed = false;
  ctrl.tooDeep = ctrl.depth <= ctrl.maxDepth;
  ctrl.replying = false;
  ctrl.toolsOpen = false;
  Users.get(ctrl.db.author).then(function(user) {
    return ctrl.user = user;
  });
  ctrl.newContent = '';
  ctrl.upvoted = _.contains(_.pluck(ctrl.db.upvotes, 'author'), Session.me);
  ctrl.askQuery = {
    index: 'bloom',
    type: 'comment',
    id: ctrl.db._id
  };
  ctrl.editing = false;
  ctrl.tryLogin = function() {
    return $scope.$emit('tryLogin');
  };
  ctrl["delete"] = function() {
    if (confirm("Are you sure you want to delete your comment?\n\nThe message will be removed but any replies will be preserved.")) {
      ctrl.db.deleted = true;
      return Comments["delete"](ctrl.db._id);
    }
  };
  ctrl.startEdit = function() {
    ctrl.editContent = ctrl.db.content;
    ctrl.editing = true;
    return $timeout(function() {
      return $scope.$broadcast('focus');
    });
  };
  ctrl.update = function(content) {
    Comments.update(ctrl.db._id, content);
    ctrl.db.content = content;
    return ctrl.editing = false;
  };
  if (ctrl.db.comments != null) {
    ctrl.db.comments = Comments.sort(ctrl.db.comments);
  }
  ctrl.upvote = function() {
    if (!ctrl.bloomSettings.loggedIn) {
      return;
    }
    if (ctrl.upvoted) {
      ctrl.db.upvotes = _.without(ctrl.db.upvotes, _.findWhere(ctrl.db.upvotes, {
        author: Session.me
      }));
      ctrl.upvoted = false;
      setUpvoteTooltip();
      Comments.deleteUpvote(Session.me, ctrl.db._id, ctrl.postId);
      return;
    }
    ctrl.upvoted = true;
    ctrl.db.upvotes.push({
      author: Session.me,
      createdAt: Date.now()
    });
    setUpvoteTooltip();
    $scope.animateUpvote();
    return Comments.upvote(Session.me, ctrl.db._id, ctrl.postId);
  };
  $scope.$watch((function() {
    return ctrl.replying;
  }), function(val, lastReplying) {
    if (!lastReplying && ctrl.replying) {
      return $timeout(function() {
        return $scope.$broadcast('focus');
      });
    }
  });
  ctrl.add = function() {
    var tempComment, _base;
    tempComment = {
      author: Session.me,
      content: ctrl.newContent,
      createdAt: Date.now(),
      newComment: true
    };
    Comments.addToComment(Session.me, ctrl.newContent, ctrl.db._id, ctrl.dbParams).then(function(saved) {
      return Comments.get(saved._id).then(function(comment) {
        ctrl.db.comments[0]._id = comment._id;
        return $scope.$emit('userCommented');
      });
    });
    ((_base = ctrl.db).comments || (_base.comments = [])).unshift(tempComment);
    ctrl.replying = false;
    return ctrl.newContent = '';
  };
  $scope.ctrl = ctrl;
  return _this;
};


},{}],12:[function(require,module,exports){
var _this = this;

module.exports = function($compile, $animate, scroller) {
  return {
    restrict: 'E',
    scope: {
      db: '=',
      dbParams: '=',
      depth: '@'
    },
    template: require('./template.jade'),
    controller: 'CommentCtrl',
    controllerAs: 'comment',
    replace: true,
    compile: function(tElement, tAttr) {
      var compiledContents, contents;
      contents = tElement.contents().remove();
      compiledContents = null;
      return function(scope, el, attr) {
        if (!compiledContents) {
          compiledContents = $compile(contents);
        }
        compiledContents(scope, function(clone, scope) {
          return el.append(clone);
        });
        scope.animateUpvote = function() {
          return;
          return $animate.addClass(el.find('a.upvote:eq(0) i'), 'animate-upvote');
        };
        scope.highlight = false;
        return;
        return scope.$on('highlightComment', function(e, obj) {
          if (obj._id === scope.db._id) {
            scroller.scrollToElement(el, 55, 1000);
            return scope.highlight = true;
          }
        });
      };
    }
  };
};


},{"./template.jade":13}],13:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div ng-class=\"{new: ctrl.db.newComment}\" class=\"comment-wrapper depth-{{ctrl.depth}}\"><div ng-class=\"{deleted: ctrl.db.deleted, highlight: highlight, collapsed: ctrl.collapsed}\" class=\"comment\"><div class=\"avatar\"><user-avatar user=\"ctrl.user\" hover=\"false\" ng-if=\"!ctrl.db.deleted\"></user-avatar><div ng-if=\"ctrl.db.deleted\" class=\"deleted\"></div></div><div class=\"header\"><span ng-if=\"!ctrl.db.deleted\"><span class=\"name\"><user-name user=\"ctrl.user\" hover=\"false\"></user-name></span><span class=\"time\">{{ctrl.db.createdAt | ago}}</span></span><div class=\"hover-tools\"><ul><li><a href=\"javascript:;\" ng-click=\"ctrl.collapsed = !ctrl.collapsed\"><i ng-if=\"!ctrl.collapsed\" class=\"fa fa-minus\"></i><i ng-if=\"ctrl.collapsed\" class=\"fa fa-plus\"></i></a></li></ul></div></div><div ng-if=\"!ctrl.db.deleted\" class=\"content\"><comment-content comment=\"ctrl.db\" ng-if=\"!ctrl.collapsed &amp;&amp; !ctrl.db.deleted &amp;&amp; !ctrl.editing\"></comment-content><span ng-if=\"ctrl.collapsed\" class=\"content-collapsed\">Comment collapsed.</span><bloom-input ng-model=\"ctrl.editContent\" ng-if=\"ctrl.editing\" button-text=\"Save\" on-submit=\"ctrl.update(ctrl.editContent)\"></bloom-input></div><span ng-if=\"ctrl.db.deleted\" class=\"content-deleted\">This comment has been deleted.</span><div ng-if=\"!ctrl.collapsed &amp;&amp; !ctrl.db.deleted &amp;&amp; !ctrl.editing\" class=\"footer\"><a href=\"javascript:;\" ng-click=\"ctrl.upvote()\" ng-if=\"!ctrl.db.deleted &amp;&amp; ctrl.bloomSettings.loggedIn\"><span ng-if=\"!ctrl.upvoted\">Like</span><span ng-if=\"ctrl.upvoted\">Unlike</span></a><span ng-if=\"!ctrl.db.deleted &amp;&amp; ctrl.bloomSettings.loggedIn\" class=\"bullet\">&bull;</span><a href=\"javascript:;\" ng-if=\"!ctrl.bloomSettings.loggedIn\" class=\"reply-link\">Log in to reply</a><a href=\"javascript:;\" ng-click=\"ctrl.replying = !ctrl.replying\" ng-class=\"{active: ctrl.replying}\" ng-if=\"ctrl.bloomSettings.loggedIn\" class=\"reply-link\">Reply</a><span ng-if=\"ctrl.owner &amp;&amp; !ctrl.db.deleted\"><span class=\"bullet\">&bull;</span><a href=\"javascript:;\" ng-click=\"ctrl.startEdit()\" ng-class=\"{active: ctrl.editing}\" class=\"edit-link\">Edit</a><span class=\"bullet\">&bull;</span><a href=\"javascript:;\" ng-click=\"ctrl.delete()\">Delete</a></span><span ng-if=\"!ctrl.db.deleted &amp;&amp; (ctrl.db.upvotes.length &gt; 0)\" class=\"bullet\">&bull;</span><a href=\"javascript:;\" ng-class=\"{upvoted: ctrl.upvoted}\" ng-if=\"!ctrl.db.deleted &amp;&amp; (ctrl.db.upvotes.length &gt; 0)\" ng-click=\"ctrl.showLikes = !ctrl.showLikes\" bs-tooltip=\"ctrl.tooltip\" data-placement=\"top\" class=\"upvote\"><i class=\"fa fa-heart\"></i><span>{{ctrl.db.upvotes.length}}</span></a></div><div ng-if=\"ctrl.replying\" class=\"reply\"><bloom-input ng-model=\"ctrl.newContent\" button-text=\"Reply\" placeholder=\"Reply to {{ctrl.user.name}}...\" on-submit=\"ctrl.add()\"></bloom-input></div></div><div ng-if=\"!ctrl.collapsed\" class=\"subcomments\"><div class=\"subcomment-list\"><comment db=\"child\" ng-repeat=\"child in ctrl.db.comments\" max-depth=\"maxDepth\" depth=\"{{ctrl.depth + 1}}\" db-params=\"dbParams\"></comment></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],14:[function(require,module,exports){
var _this = this;

module.exports = function($scope, Comments, Session, BloomSettings) {
  _this.db = [];
  _this.newContent = '';
  _this.bloomSettings = BloomSettings;
  _this.highlight = function(commentId) {};
  _this.updateCommentCount = function() {
    return $scope.onCount({
      count: Comments.fromTree(_this.db).length
    });
  };
  $scope.$on('userCommented', _this.updateCommentCount);
  _this.add = function() {
    var tempComment;
    tempComment = {
      content: _this.newContent,
      author: Session.me,
      createdAt: Date.now(),
      upvotes: [],
      asked: [],
      newComment: true
    };
    /*
      Fake add the comment instead of waiting for the server
    */

    _this.db.unshift(tempComment);
    Comments.addToPost(Session.me, _this.newContent, $scope.dbParams).then(function(comment) {
      var _ref;
      return (_ref = _this.db[0]) != null ? _ref._id = comment._id : void 0;
    });
    _this.updateCommentCount();
    return _this.newContent = '';
  };
  _this.refresh = function() {
    return Comments.byDiscussion($scope.dbParams.commentsId).then(function(comments) {
      _this.db = Comments.sort(Comments.toTree(comments));
      return _this.updateCommentCount();
    });
  };
  _this.refresh();
  _this.tryLogin = function() {
    return $scope.$emit('bloomClientLogin');
  };
  $scope.$on('tryLogin', function() {
    return _this.tryLogin();
  });
  return _this;
};


},{}],15:[function(require,module,exports){
var _this = this;

module.exports = function($timeout) {
  return {
    restrict: 'E',
    scope: {
      dbParams: '=',
      onLogin: '&',
      onCount: '&',
      maxDepth: '@'
    },
    template: require('./template.jade'),
    controller: require('./controller'),
    controllerAs: 'comments',
    link: function(scope, element) {}
  };
};


},{"./controller":14,"./template.jade":16}],16:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"bloom-comments\"> <div class=\"top-reply-wrapper\"><div class=\"top-reply\"><bloom-input ng-if=\"comments.bloomSettings.loggedIn\" ng-model=\"comments.newContent\" placeholder=\"Join the conversation...\" on-submit=\"comments.add()\" button-text=\"Post\"></bloom-input><a href=\"javascript:;\" ng-click=\"comments.tryLogin()\" ng-if=\"!comments.bloomSettings.loggedIn\" class=\"input-login-wall\">Log in to join the discussion</a></div></div><div ng-show=\"comments.db.length &gt; 0\" class=\"comments-list\"><comment db=\"comment\" ng-repeat=\"comment in comments.db\" max-depth=\"maxDepth\" depth=\"0\" db-params=\"dbParams\"></comment></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],17:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return angular.module('bloom.comments.helpers', []).config(function($sceProvider) {
    return $sceProvider.enabled(false);
  }).controller('CommentContentCtrl', function($scope) {
    var images;
    this.data = $scope.comment;
    if ($scope.type === 'comment') {
      images = $(this.data.content).find('img');
      this.data.previewSrc = $(images.get(0)).attr('src');
      this.data.content = $(this.data.content).text();
    }
    return this;
  }).directive('commentContent', function() {
    return {
      restrict: 'E',
      scope: {
        comment: '=',
        length: '@',
        type: '@'
      },
      template: require('./helpers/content.jade'),
      controller: 'CommentContentCtrl as content',
      link: function(scope, element) {
        return scope.length || (scope.length = 1000);
      }
    };
  });
};


},{"./helpers/content.jade":18}],18:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"comment-content\"><img ng-src=\"{{content.data.previewSrc}}\" ng-if=\"content.data.previewSrc\" class=\"preview\"/><div ng-if=\"content.data\" compile=\"content.data.content | atModule\"></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],19:[function(require,module,exports){
module.exports = function() {
  require('./helpers')();
  require('./comment/angular-scroll');
  return angular.module('bloom.comments', ['ngAnimate', 'ago', 'bloom.input', 'bloom.users', 'bloom.filters', 'bloom.session', 'bloom.settings', 'bloom.comments.helpers', 'duScroll', 'mgcrea.ngStrap']).config(function($sceProvider) {
    return $sceProvider.enabled(false);
  }).config(function($tooltipProvider) {
    return angular.extend($tooltipProvider.defaults, {
      html: true
    });
  }).service('Comments', require('./service')).directive('comment', require('./comment/directive')).controller('CommentCtrl', require('./comment/controller')).directive('comments', require('./comments/directive'));
};


},{"./comment/angular-scroll":10,"./comment/controller":11,"./comment/directive":12,"./comments/directive":15,"./helpers":17,"./service":20}],20:[function(require,module,exports){
var _this = this;

module.exports = function(BloomSettings, API, Session, $http, $q) {
  _this.sort = function(comments) {
    return _.sortBy(comments, function(c) {
      return -_this.rank(c);
    });
  };
  _this.prefer = function(comments, preferred) {
    var isMine;
    isMine = function(comment) {
      return _.contains(preferred, comment._id);
    };
    return _.filter(comments, isMine).concat(_.reject(comments, isMine));
  };
  _this.rank = function(comment) {
    var order;
    order = Math.log(Math.max((comment.upvotes || []).length, 1)) / Math.log(1.2);
    return order + comment.createdAt / 45000000;
  };
  _this["delete"] = function(commentId) {
    return API["delete"]("/comments/" + commentId);
  };
  _this.update = function(commentId, content) {
    var params;
    params = {
      content: content
    };
    return API.process(API.put("/comments/" + commentId, {
      params: params
    }));
  };
  _this.fromTree = function(data) {
    var addComment, comment, total, _i, _len;
    total = [];
    addComment = function(comment) {
      var child, _i, _len, _ref, _results;
      total.push(comment);
      _ref = comment.comments || [];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _results.push(addComment(child));
      }
      return _results;
    };
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      comment = data[_i];
      addComment(comment);
    }
    return total;
  };
  _this.toTree = function(data) {
    var dataMap, treeData;
    dataMap = data.reduce(function(map, node) {
      map[node._id] = node;
      return map;
    }, {});
    treeData = [];
    data.forEach(function(node) {
      var parent;
      parent = dataMap[node.parentCommentId];
      if (parent) {
        return (parent.comments || (parent.comments = [])).push(node);
      } else {
        return treeData.push(node);
      }
    });
    return treeData;
  };
  _this.deleteUpvote = function(author, commentId, postId) {
    var params;
    params = {
      author: author
    };
    API.post("/comments/" + commentId + "/deleteUpvote", {
      params: params
    });
    return $q.when(true);
  };
  _this.upvote = function(author, commentId, postId) {
    var params;
    params = {
      author: author
    };
    API.post("/comments/" + commentId + "/upvote", {
      params: params
    });
    return $q.when(true);
  };
  _this.addToPost = function(author, content, saveWith) {
    var params;
    params = {
      save: {
        author: author,
        content: content,
        dbParams: saveWith
      },
      auth: {
        user: Session.me,
        token: BloomSettings.token
      }
    };
    return API.process(API.post('/comments', {
      params: params
    }));
  };
  _this.addToComment = function(author, content, parentCommentId, saveWith) {
    var params;
    params = {
      save: {
        author: author,
        content: content,
        asked: [],
        upvotes: [],
        createdAt: Date.now(),
        parentCommentId: parentCommentId,
        dbParams: saveWith
      },
      auth: {
        user: Session.me,
        token: BloomSettings.token
      }
    };
    return API.process(API.post('/comments', {
      params: params
    }));
  };
  _this.byDiscussion = function(id) {
    return API.process(API.get("/discussion/" + id + "/comments"));
  };
  _this.getChildren = function(id) {
    return API.process(API.get("/comments/" + id + "/children"));
  };
  _this.get = function(_id) {
    return API.process(API.get("/comments/" + _id));
  };
  _this.all = function(_id) {
    return API.process(API.get("/comments"));
  };
  return _this;
};


},{}],21:[function(require,module,exports){
var _this = this;

module.exports = function(filterFilter, BloomSettings, Comments, $scope, $filter, Forum, Users, Session) {
  _this.maxSize = 10;
  _this.setPage = function(pageNo) {
    return _this.currentPage = pageNo;
  };
  _this.page = 1;
  _this.perPage = 10;
  _this.showReplies = false;
  _this.comments = [];
  _this.loaded = false;
  _this.search = '';
  _this.comments = [];
  _this.filtered = [];
  _this.replyTo = function(comment, content) {
    var dbParams;
    dbParams = comment.db.dbParams;
    Comments.addToComment(Session.me, content, comment.db._id, dbParams).then(function(saved) {
      return Comments.get(saved._id).then(function(newComment) {
        var commentWithDB;
        commentWithDB = {
          db: newComment
        };
        _this.addUser(commentWithDB);
        return (comment.children || (comment.children = [])).push(commentWithDB);
      });
    });
    return comment.reply = "";
  };
  _this.addPost = function(comment) {
    return BloomSettings.commentsIdToData(comment.db.dbParams.commentsId).then(function(data) {
      return comment.post = data;
    });
  };
  _this.addContext = function(comment) {
    if (comment.db.parentCommentId != null) {
      Comments.get(comment.db.parentCommentId).then(function(parent) {
        comment.parent = {
          db: parent
        };
        return _this.addUser(comment.parent);
      });
    }
    return Comments.getChildren(comment.db._id).then(function(children) {
      var val, _i, _len, _ref, _results;
      comment.children = children.map(function(child) {
        return {
          db: child
        };
      });
      _ref = comment.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        val = _ref[_i];
        _results.push(_this.addUser(val));
      }
      return _results;
    });
  };
  _this.addUser = function(comment) {
    return Users.get(comment.db.author).then(function(user) {
      return comment.user = user;
    });
  };
  _this.updatePage = function(page) {
    var comment, _i, _len, _ref, _results;
    _this.activeComments = _this.filtered.slice((page - 1) * _this.perPage, page * _this.perPage);
    _ref = _this.activeComments;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      comment = _ref[_i];
      _this.addContext(comment);
      _this.addPost(comment);
      _results.push(_this.addUser(comment));
    }
    return _results;
  };
  _this.showContext = function(comment) {
    return comment.showReplies = true;
  };
  $scope.$watch((function() {
    return _this.search;
  }), function() {
    return _this.updatePagination(_this.comments);
  });
  _this.updatePagination = function() {
    _this.filtered = _.sortBy($filter('filter')(_this.comments, _this.search), function(comment) {
      return -comment.db.createdAt;
    });
    _this.totalComments = _this.filtered.length;
    return _this.updatePage(_this.page);
  };
  Users.get(Session.me).then(function(me) {
    return _this.me = me;
  });
  Comments.all().then(function(db) {
    _this.loaded = true;
    _this.comments = db.map(function(data) {
      return {
        db: data,
        replying: false,
        replied: false,
        replyWith: function(text) {
          this.replied = true;
          this.replyText = this.reply;
          this.replying = false;
          return this.reply = "";
        }
      };
    });
    _this.last24Hours = _this.comments.filter(function(c) {
      return c.db.createdAt > (Date.now() - 86400000);
    }).length;
    return _this.updatePagination();
  });
  return _this;
};


},{}],22:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return {
    restrict: 'E',
    scope: {},
    template: require('./template'),
    controller: 'DashboardCtrl',
    controllerAs: 'dashboard'
  };
};


},{"./template":25}],23:[function(require,module,exports){
module.exports = function() {
  return angular.module('bloom.dashboard', ['bloom.settings', 'bloom.users', 'bloom.filters', 'bloom.session', 'bloom.comments', 'bloom.forum']).service('Dashboard', require('./service')).controller('DashboardCtrl', require('./controller')).directive('dashboard', require('./directive'));
};


},{"./controller":21,"./directive":22,"./service":24}],24:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return _this;
};


},{}],25:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"container\"><h1>Admin Dashboard</h1><div class=\"bloom-dashboard-metrics\"><div class=\"col-md-2 col-md-offset-3 text-center\"><div class=\"metric\">{{dashboard.last24Hours}}</div><div class=\"metric-label\">recent comments (24h)</div></div><div class=\"clearfix\"></div></div><div class=\"bloom-dashboard-comments\"><div class=\"filter\"><form class=\"form-inline\"><div class=\"form-group\"><input type=\"text\" placeholder=\"Filter\" ng-model=\"dashboard.search\" class=\"form-control\"/></div></form></div><div ng-repeat=\"comment in dashboard.activeComments\" ng-class=\"{ showReplies: comment.showReplies }\" class=\"bloom-dashboard-comment-wrapper\"><!-- parent comment--><div ng-if=\"comment.showReplies &amp;&amp; comment.parent.db._id\" class=\"bloom-dashboard-parent-wrapper\"><div class=\"bloom-dashboard-comment\"><div class=\"col name\"><div class=\"dashboard-avatar\"><user-avatar user=\"comment.parent.user\"></user-avatar></div><div class=\"dashboard-username\"><user-name user=\"comment.parent.user\"></user-name></div></div><div class=\"col comment\"><div class=\"dashboard-comment-content\"><comment-content comment=\"comment.parent.db\" length=\"80\"></comment-content></div></div><div class=\"col time\"><span class=\"time\">{{comment.parent.db.createdAt | ago}}</span></div><div class=\"col status\"><div class=\"indicator-unread\"></div></div><div class=\"clearfix\"></div></div></div><!-- main comment--><div ng-class=\"{ context: comment.showReplies }\" class=\"bloom-dashboard-comment\"><div class=\"col name\"><div class=\"dashboard-avatar\"><user-avatar user=\"comment.user\"></user-avatar></div><div class=\"dashboard-username\"><user-name user=\"comment.user\"></user-name></div><div ng-if=\"comment.children.length == 0\" class=\"unanswered\"><span class=\"label label-primary\">Unanswered!</span></div></div><div class=\"col comment\"><a target=\"_blank\" ng-href=\"{{comment.post.url}}\" class=\"title\">{{comment.post.title}}</a><div class=\"dashboard-comment-content\"><comment-content comment=\"comment.db\" length=\"80\"></comment-content></div><div class=\"comment-meta\"><a class=\"comment-vote\"><i class=\"fa fa-chevron-up comment-vote-icon\"></i><span>{{comment.db.upvotes.length}}</span></a><span class=\"bull\">&bull;</span><a href=\"javascript:;\" ng-click=\"comment.replying = true\" ng-if=\"!comment.replying\">Reply</a><a href=\"javascript:;\" ng-click=\"comment.replying = false\" ng-if=\"comment.replying\">Close reply</a><span class=\"bull\">&bull;</span><a href=\"javascript:;\" ng-click=\"dashboard.showContext(comment)\" ng-if=\"!comment.showReplies\">Show context ({{comment.children.length}} replies)</a><a href=\"javascript:;\" ng-click=\"comment.showReplies = false\" ng-if=\"comment.showReplies\">Close context ({{comment.children.length}} replies)</a><span class=\"bull\">&bull;</span><a href=\"javascript:;\">Delete</a></div><div ng-if=\"comment.replying\" class=\"comment-reply\"><bloom-input ng-model=\"comment.reply\" on-submit=\"dashboard.replyTo(comment, comment.reply)\" placeholder=\"Reply to {{comment.user.name}}\"></bloom-input></div></div><div class=\"col time\"><span class=\"time\">{{comment.db.createdAt | ago}}</span></div><div class=\"col status\"><div class=\"indicator-unread\"></div></div><div class=\"clearfix\"></div></div><!-- my reply--><div ng-show=\"comment.replied\" class=\"bloom-dashboard-comment my-reply\"><div class=\"col name\"><div class=\"dashboard-avatar\"><user-avatar user=\"dashboard.me\"></user-avatar></div><div class=\"dashboard-username\"><div class=\"bloom-username\"><user-name user=\"dashboard.me\"></user-name></div></div></div><div class=\"col comment\"><div class=\"dashboard-comment-content\"><div ng-bind-html=\"comment.replyText\"></div></div></div><div class=\"col time\"><span class=\"time\">{{comment.db.createdAt | ago}}</span></div><div class=\"col status\"><div class=\"indicator-unread\"></div></div><div class=\"clearfix\"></div></div><!-- children--><div ng-if=\"comment.showReplies\" class=\"bloom-dashboard-child-wrapper\"><div ng-repeat=\"child in comment.children\" class=\"bloom-dashboard-comment\"><div class=\"col name\"><div class=\"dashboard-avatar\"><user-avatar user=\"child.user\"></user-avatar></div><div class=\"dashboard-username\"><user-name user=\"child.user\"></user-name></div></div><div class=\"col comment\"><div class=\"dashboard-comment-content\"><comment-content comment=\"child.db\" length=\"80\"></comment-content></div></div><div class=\"col time\"><span class=\"time\">{{comment.db.createdAt | ago}}</span></div><div class=\"col status\"><div class=\"indicator-unread\"></div></div><div class=\"clearfix\"></div></div></div></div><div ng-if=\"dashboard.loaded\" class=\"paging\"><pagination total-items=\"dashboard.filtered.length\" items-per-page=\"dashboard.perPage\" on-select-page=\"dashboard.updatePage(page)\" page=\"dashboard.page\" boundary-links=\"true\" rotate=\"false\"></pagination></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],26:[function(require,module,exports){
var _this = this;

module.exports = function() {
  /* @all = [
    { title: 'All Categories', _id: 'xall', meta: true }
    { title: 'Uncategorized', _id: 'xuncategorized', meta: true }
    { title: 'General Boating', _id: 'xlessonq', meta: false }
    { title: 'Marine Electronics', _id: 'xhomework', meta: false }
    { title: 'Trucks & Trailers', _id: 'xhomework', meta: false }
    { title: 'For Sale and Wanted', _id: 'xdiy', meta: false } 
    { title: 'Fishing', _id: 'xnutrition', meta: false } 
    { title: 'Northeast', _id: 'xtroubleshooting', meta: false } 
    { title: 'Gulf Coast', _id: 'xfeedback', meta: false } 
    { title: 'West Coast', _id: 'xcognition', meta: false } 
  ]
  */

  _this.all = [
    {
      title: 'All Categories',
      _id: 'xall',
      meta: true
    }, {
      title: 'Uncategorized',
      _id: 'xuncategorized',
      meta: true
    }, {
      title: 'Announcements',
      _id: 'xdiy',
      meta: false
    }, {
      title: 'Recipes',
      _id: 'xbiology',
      meta: false
    }, {
      title: 'Troubleshooting',
      _id: 'xnutrition',
      meta: false
    }, {
      title: 'FAQs',
      _id: 'xtroubleshooting',
      meta: false
    }, {
      title: 'Sous Vide',
      _id: 'xfeedback',
      meta: false
    }, {
      title: 'DIY Hardware',
      _id: 'xcognition',
      meta: false
    }, {
      title: 'Off Topic',
      _id: 'xofftopic',
      meta: false
    }
  ];
  _this.get = function(_id) {
    return _.findWhere(_this.all, {
      _id: _id
    });
  };
  return _this;
};


},{}],27:[function(require,module,exports){
var _this = this;

module.exports = function(Categories) {
  return function(catId) {
    return Categories.get(catId).title;
  };
};


},{}],28:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return function(posts, category) {
    if (category._id === 'xall') {
      return posts;
    }
    return posts.filter(function(post) {
      var _ref;
      return ((_ref = post.tags) != null ? _ref[0] : void 0) === category._id;
    });
  };
};


},{}],29:[function(require,module,exports){
module.exports = function($scope, Categories, $rootScope, Forum, ForumState) {
  var _this = this;
  $rootScope.$watch('activePostId', function(val) {
    return _this.activePostId = val;
  });
  ForumState.refresh();
  this.categories = Categories.all;
  $scope.$watch((function() {
    return ForumState.posts;
  }), function(val) {
    return _this.posts = val;
  });
  this.searchActive = false;
  this.selectCategory = function(catId) {
    _this.activeCategory = Categories.get(catId);
    return _this.showCategories = false;
  };
  this.service = Forum;
  this.selectCategory('xall');
  return this;
};


},{}],30:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return {
    replace: true,
    restrict: 'E',
    scope: {},
    template: require('./template'),
    controller: 'ForumCtrl',
    controllerAs: 'forum'
  };
};


},{"./template":41}],31:[function(require,module,exports){
module.exports = function() {
  return angular.module('bloom.forum', ['ngAnimate', 'ui.router', 'ago', 'bloom.settings', 'bloom.users', 'bloom.ask', 'bloom.filters', 'bloom.session', 'bloom.comments']).config(require('./router')).service('Forum', require('./service')).service('ForumState', require('./state')).controller('ForumCtrl', require('./controller')).directive('forum', require('./directive')).controller('PostCtrl', require('./post/controller')).directive('post', require('./post/directive')).controller('NewPostCtrl', require('./new-post/controller')).directive('newPost', require('./new-post/directive')).service('Categories', require('./categories/service')).filter('toCategoryTitle', require('./categories/to-title')).filter('categoryFilter', require('./category-filter'));
};


},{"./categories/service":26,"./categories/to-title":27,"./category-filter":28,"./controller":29,"./directive":30,"./new-post/controller":32,"./new-post/directive":33,"./post/controller":35,"./post/directive":36,"./router":38,"./service":39,"./state":40}],32:[function(require,module,exports){
module.exports = function($scope, Forum, Categories, ForumState, $state, Session) {
  var _this = this;
  $scope.$on('$viewContentLoaded', function() {
    Forum.newPostActive = true;
    return $('input.new-post').focus();
  });
  $scope.$on('$destroy', function() {
    return Forum.newPostActive = false;
  });
  $scope.$watch('newPost.title', function() {
    return Forum.newPost.title = _this.title;
  });
  this.showCategories = false;
  this.activePost = -1;
  this.categories = Categories.all;
  this.title = '';
  this.content = '';
  this.activeCategory = Categories.get('xuncategorized');
  this.create = function() {
    return Forum.createPost({
      author: Session.me,
      category: 'Announcements',
      title: _this.title,
      content: _this.content,
      category: _this.activeCategory._id
    }).then(function(post) {
      $state.go('forum.post', {
        id: post._id
      });
      ForumState.refresh();
      _this.title = '';
      return _this.content = '';
    });
  };
  return this;
};


},{}],33:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return {
    restrict: 'E',
    scope: {},
    template: require('./template'),
    controller: 'NewPostCtrl',
    controllerAs: 'newPost'
  };
};


},{"./template":34}],34:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"post-active new-post\"><div class=\"post-inner-wrapper\"><div class=\"header\">Create a post<a ui-sref=\"forum\" class=\"new-post-close\"><!-- i.fa.fa-times--><span class=\"glyphicon glyphicon-remove\"></span></a></div><!-- h1.title(ng-class=\"{fadetitle: newPost.title.length > 0}\") Start a new discussion!--><input type=\"text\" ng-model=\"newPost.title\" placeholder=\"Type title here...\" tabindex=\"1\" class=\"new-post\"/><bloom-input ng-model=\"newPost.content\" placeholder=\"Type post here...\" on-submit=\"newPost.create()\" xtabindex=\"2\"></bloom-input><!-- .btn-group.btn-group-sm.categoriesbutton.btn.btn-default(type=\"button\",\n                      ng-repeat=\"category in newPost.categories |filter:{meta:false}\",\n                      ng-class=\"{ active: newPost.activeCategory._id == category._id }\",\n                      ng-click=\"newPost.activeCategory = category\") \n| {{category.title}}\n--><!-- .clearfix--><div class=\"post-actions\"><div class=\"category-list-wrapper\"><a tabindex=\"2\" href=\"javascript:;\" ng-click=\"newPost.showCategories = !newPost.showCategories\" class=\"category-list-active\">{{newPost.activeCategory.title}}<i class=\"fa fa-caret-down\"></i></a><div ng-if=\"newPost.showCategories\" class=\"bloom-popover category-list-popover simpleTransition\"><div class=\"popover-container\"><ul><li ng-repeat=\"category in newPost.categories | filter:{meta:false}\" ng-class=\"{ active: newPost.activeCategory._id == category._id }\" ng-click=\"newPost.activeCategory = category; newPost.showCategories = false;\"><a href=\"javascript:;\">{{category.title}}</a></li></ul></div><div class=\"popover-arrow\"></div></div></div><button tabindex=\"3\" type=\"submit\" ui-sref=\"forum\" class=\"btn btn-default\">Cancel</button><button tabindex=\"4\" type=\"submit\" ng-click=\"newPost.create()\" class=\"btn btn-primary\">Create</button></div><div class=\"clearfix\"></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],35:[function(require,module,exports){
module.exports = function($stateParams, $scope, Forum, Session, Users, $rootScope) {
  var _this = this;
  $rootScope.activePostId = $stateParams.id;
  this.activeComment = $stateParams.commentId;
  $scope.$on('$destroy', function() {
    return $rootScope.activePostId = null;
  });
  $scope.$on('addedComment', function() {
    return _this.data.commentCount++;
  });
  $scope.$on('removeComment', function() {
    return _this.data.commentCount++;
  });
  this._id = $stateParams.id;
  this.commentId = $stateParams.commentId;
  this.loaded = false;
  this.log = function() {
    return console.log('try to login');
  };
  this.upvote = function() {
    if (_this.upvoted) {
      return;
    }
    Forum.upvote(_this._id, Session.me);
    _this.upvoted = true;
    _this.data.upvotes.push({
      author: Session.me,
      createdAt: Date.now()
    });
    return $scope.animateUpvote();
  };
  this.commentsGetWith = {
    commentsId: this._id,
    commentsType: 'discussionPost'
  };
  this.commentsGetWith2 = {
    commentsId: "yo",
    commentsType: 'discussionPost'
  };
  this.setCommentCount = function(count) {
    _this.commentCount = count;
    return $scope.$emit('updatePostCommentCount', {
      postId: _this._id,
      commentCount: count
    });
  };
  Forum.getPost(this._id).then(function(data) {
    _this.data = data;
    Users.get(_this.data.author).then(function(user) {
      return _this.user = user;
    });
    _this.loaded = true;
    _this.upvoted = _.contains(_.pluck(_this.data.upvotes, 'author'), Session.me);
    return _this.askQuery = {
      index: 'bloom',
      type: 'post',
      id: _this._id
    };
  });
  return this;
};


},{}],36:[function(require,module,exports){
var _this = this;

module.exports = function($animate, $timeout) {
  return {
    restrict: 'E',
    scope: {
      db: '='
    },
    template: require('./template'),
    controller: 'PostCtrl',
    controllerAs: 'post',
    link: function(scope, el) {
      scope.animateUpvote = function() {
        return $animate.addClass(el.find('.post-vote-icon:eq(0)'), 'animate-upvote');
      };
      return;
      if (scope.post.activeComment != null) {
        return $timeout(function() {
          return scope.$broadcast('highlightComment', {
            _id: scope.post.activeComment
          });
        }, 1500);
      }
    }
  };
};


},{"./template":37}],37:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"post-active\"><div class=\"post-inner-wrapper\"><div ng-if=\"post.loaded\" class=\"post-inner\"><h1 class=\"title\">{{post.data.title}}</h1><div class=\"post-meta\"><div ng-if=\"post.user\" class=\"post-avatar\"><user-avatar user=\"post.user\"></user-avatar></div><div class=\"post-username\"><user-name user=\"post.user\" ng-if=\"post.user\"></user-name></div> in <a href=\"#\">{{post.data.tags[0] | toCategoryTitle}}</a><span class=\"bull\">&bull;</span><span class=\"time\">{{post.data.createdAt | ago}} ago</span></div><div compile=\"post.data.content\" class=\"post-message\"></div></div><div ng-if=\"post.loaded\" class=\"post-controls\"><a ng-class=\"{upvoted: post.upvoted}\" ng-click=\"post.upvote()\" class=\"post-vote\"><i class=\"fa fa-heart\"></i><span>{{post.data.upvotes.length || 0}}</span></a><span class=\"bull\">&bull;</span><span class=\"comment-count\">{{post.commentCount || 'No'}} comments</span><span class=\"bull\">&bull;</span><a ask=\"ask\" ask-query=\"post.askQuery\" asked=\"post.data.asked\" href=\"#\" class=\"ask-wrapper\">Ask to Answer<span ng-if=\"post.data.asked.length &gt; 0\"> ({{post.data.asked.length}})</span></a></div></div><div ng-if=\"post.loaded\" class=\"comments-wrapper\"><comments db-params=\"post.commentsGetWith\" on-login=\"post.log()\" on-count=\"post.setCommentCount(count)\"></comments></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],38:[function(require,module,exports){
var _this = this;

module.exports = function($sceProvider, $stateProvider, $urlRouterProvider, $locationProvider) {
  $sceProvider.enabled(false);
  $locationProvider.html5Mode(true);
  $urlRouterProvider.otherwise('/');
  return $stateProvider.state('home', {
    url: "/",
    templateUrl: '/home-page.html'
  }).state('content', {
    url: "/content",
    templateUrl: "/content-page.html"
  }).state('dashboard', {
    url: "/dashboard",
    template: "<dashboard></dashboard>"
  }).state('forum', {
    url: "/forum",
    template: "<forum></forum>"
  }).state('forum.newPost', {
    url: "/new",
    template: "<new-post></new-post>"
  }).state('forum.post', {
    url: "/:id",
    template: "<post></post>"
  }).state('forum.comment', {
    url: "/:id/comments/:commentId",
    template: "<post></post>"
  });
};


},{}],39:[function(require,module,exports){
var _this = this;

module.exports = function($q, Comments, Users, API) {
  _this.newPost = {};
  _this.newPostActive = {};
  _this.createPost = function(params) {
    params.createdAt = Date.now();
    return API.process(API.post('/forum/posts', {
      params: params
    }));
  };
  _this.addUserToPost = function(post) {
    var def;
    def = $q.defer();
    Users.get(post.author).then(function(user) {
      return def.resolve(_.extend(post, {
        user: user
      }));
    });
    return def.promise;
  };
  _this.addCommentsToPost = function(post) {
    var def;
    def = $q.defer();
    Comments.getChildren(post._id).then(function(comments) {
      return def.resolve(_.extend(post, {
        comments: comments
      }));
    });
    return def.promise;
  };
  _this.upvote = function(postId, author) {
    var params;
    params = {
      author: author
    };
    API.post("/forum/posts/" + postId + "/upvote", {
      params: params
    });
    return $q.when(true);
  };
  _this.getPost = function(id) {
    var def;
    def = $q.defer();
    API.process(API.get("/forum/posts/" + id)).then(function(post) {
      return _this.addCommentsToPost(post).then(function(newPost) {
        return def.resolve(newPost);
      });
    });
    return def.promise;
  };
  _this.getPosts = function() {
    var addComments, addUsers, def;
    def = $q.defer();
    addComments = function(posts) {
      return $q.all(posts.map(_this.addCommentsToPost));
    };
    addUsers = function(posts) {
      return $q.all(posts.map(_this.addUserToPost));
    };
    API.process(API.get("/forum/posts", {})).then(function(posts) {
      return addComments(posts).then(function(posts2) {
        return addUsers(posts).then(function(posts3) {
          return def.resolve(posts3);
        });
      });
    });
    return def.promise;
  };
  return _this;
};


},{}],40:[function(require,module,exports){
var _this = this;

module.exports = function(Forum, $rootScope) {
  _this.posts = [];
  $rootScope.$on('updatePostCommentCount', function(e, _arg) {
    var commentCount, postId, _ref;
    postId = _arg.postId, commentCount = _arg.commentCount;
    return (_ref = _.findWhere(_this.posts, {
      _id: postId
    })) != null ? _ref.commentCount = commentCount : void 0;
  });
  _this.refresh = function() {
    return Forum.getPosts().then(function(posts) {
      return _this.posts = posts;
    });
  };
  return _this;
};


},{}],41:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div ng-cloak=\"ng-cloak\" class=\"app\"><!-- .app-inner  --><!-- new-post modal--><div id=\"newPostModal\" tabindex=\"-1\" role=\"dialog\" class=\"modal fade\"><div class=\"modal-dialog\"><div class=\"modal-content\"><div class=\"modal-header\"><button type=\"button\" data-dismiss=\"modal\" class=\"close\">&times;</button><h4 class=\"modal-title\">New post</h4></div><div class=\"modal-body\"><input type=\"text\" ng-model=\"newPost.title\" placeholder=\"Type title here\" tabindex=\"1\" class=\"post-title\"/><bloom-input ng-model=\"newPost.content\" placeholder=\"Type post here\" on-submit=\"newPost.create()\" xtabindex=\"2\"></bloom-input></div></div></div></div><div ng-class=\"{'sidebar-new-post': forum.service.newPostActive}\" class=\"sidebar\"><header><div class=\"left\"><button type=\"button\" ui-sref=\"forum\"><i class=\"fa fa-home\"></i></button><div class=\"category-list-wrapper\"><a href=\"javascript:;\" ng-click=\"forum.showCategories = !forum.showCategories\" class=\"category-list-active\">{{forum.activeCategory.title}}<i class=\"fa fa-caret-down\"></i></a><div ng-if=\"forum.showCategories\" class=\"bloom-popover left category-list-popover simpleTransition\"><div class=\"popover-container\"><ul><li ng-repeat=\"cat in forum.categories\" ng-class=\"{ active: cat._id == forum.activeCategory._id }\" ng-click=\"forum.selectCategory(cat._id)\"><a href=\"javascript:;\">{{cat.title}}</a></li></ul></div><div class=\"popover-arrow\"></div></div><!-- .category-list(ng-if=\"forum.showCategories\")ul\n  li(ng-repeat=\"cat in forum.categories\",\n     ng-class=\"{ active: cat._id == forum.activeCategory._id }\",\n     ng-click=\"forum.selectCategory(cat._id)\")\n  a {{cat.title}}\n  --></div></div><div class=\"right\"><a href=\"javascript:;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"Disabled for demo\" class=\"sort active\">Hot</a><a href=\"javascript:;\" data-toggle=\"tooltip\" data-placement=\"bottom\" title=\"Disabled for demo\" class=\"sort\">New</a><a href=\"javascript:;\" ng-click=\"forum.searchActive = true\" class=\"search-icon\"><i class=\"fa fa-search\"></i></a></div><div ng-if=\"forum.searchActive\" class=\"header-search\"><div class=\"header-search-inset\"><i class=\"fa fa-search\"></i><input type=\"search\" ng-model=\"forum.search\" placeholder=\"Search\" class=\"search\"/></div><a href=\"javascript:;\" ng-click=\"forum.searchActive = false\" class=\"search-cancel\">Cancel</a></div></header><div class=\"sidebar-list\"><div ui-sref=\"forum.newPost\" class=\"item add-post\"><i class=\"fa fa-plus-circle\"></i><span>Add Post</span></div><div ng-repeat=\"post in forum.posts | categoryFilter:forum.activeCategory | filter:forum.search | orderBy:'createdAt':true\" ng-class=\"{active: post._id == forum.activePostId}\" ui-sref=\"forum.post({ id: post._id })\" ng-cloak=\"ng-cloak\" class=\"item\"><h5 class=\"title\"><a ng-click=\"\">{{post.title | truncate:false:80:'...' }}</a></h5><div class=\"meta\"><a ng-class=\"{upvoted: post.upvoted}\" class=\"post-vote\"><i class=\"fa fa-caret-up post-vote-icon\"></i><span>{{post.upvotes.length || 0}}</span></a><span class=\"bull\">&bull;</span><span class=\"comment-count\">{{post.commentCount}} comments</span><span class=\"bull\">&bull;</span><span>By </span><user-name user=\"post.user\" hover=\"false\"></user-name><span> in  </span><a ng-click=\"forum.selectCategory(post.tags[0])\" class=\"category\">{{post.tags[0] | toCategoryTitle }}</a></div><span class=\"time\">{{post.createdAt | ago}}</span></div></div></div><div ui-view=\"\" class=\"post-container comments-scroll\"><div class=\"post-landing\"><div class=\"home-items\"><div class=\"header\">Featured discussions</div><a class=\"item\"><img src=\"/images/riviera.png\" class=\"item-image\"/><h5 class=\"title\">Trip in the Riviera Ligure di Ponente</h5><p class=\"message\">Had an amazing time a few weeks ago - got five friends together on a weekend and rented a beautiful 47' Beneteau Sailboat through Boatbound... </p><div class=\"item-control\"><span class=\"post-vote\"><i class=\"fa fa-chevron-up post-vote-icon\"></i><span>8</span></span><span class=\"bull\">&bull;</span><span class=\"comment-count\">5 comments</span><span class=\"bull\">&bull;</span><span>By Andrew in Trips</span></div><div class=\"clear\"></div></a><a class=\"item\"><h5 class=\"title\">Cape Cod oyster poaching cases cracked</h5><p class=\"message\">Police say they know who stole more than $40,000 in oysters and equipment from beds in East Dennis and Barnstable last summer, but they're not quite ready to publicly name...</p><div class=\"item-control\"><span class=\"post-vote\"><i class=\"fa fa-chevron-up post-vote-icon\"></i><span>12</span></span><span class=\"bull\">&bull;</span><span class=\"comment-count\">3 comments</span><span class=\"bull\">&bull;</span><span>By Soundbounder in Discussions</span></div></a><a class=\"item\"><img src=\"/images/boatbound1.jpg\" class=\"item-image\"/><h5 class=\"title\">Default Undersized Cod On Wicked Tuna</h5><p class=\"message\">Anyone notice the undersized Cod that the Hebert brothers threw in the bait well on Sunday's show? I was pretty surprised...</p><div class=\"item-control\"><span class=\"post-vote\"><i class=\"fa fa-chevron-up post-vote-icon\"></i><span>3</span></span><span class=\"bull\">&bull;</span><span class=\"comment-count\">11 comments</span><span class=\"bull\">&bull;</span><span>By Door#3 in Northeast</span></div></a></div></div></div><div class=\"clearfix\"></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],42:[function(require,module,exports){
module.exports = function() {
  /*
  usage: <textarea ng-model="content" redactor></textarea>
  
  additional options:
  redactor: hash (pass in a redactor options hash)
  */

  return angular.module('redactor', []).directive('redactor', function($timeout, $http, $q) {
    return {
      restrict: "A",
      require: "ngModel",
      scope: {
        ngModel: '=',
        onFocus: "&",
        onBlur: "&"
      },
      link: function(scope, element, attrs, ngModel) {
        var $_element, additionalOptions, allData, data, dataToTitle, editor, fetchAuto, formattedData, inputFocused, options, updateModel,
          _this = this;
        updateModel = function(value) {
          return scope.$apply(function() {
            return ngModel.$setViewValue(value);
          });
        };
        inputFocused = false;
        options = {
          changeCallback: updateModel,
          focusCallback: function() {
            return scope.$apply(function() {
              return scope.onFocus();
            });
          },
          blurCallback: function() {
            return scope.$apply(function() {
              return scope.onBlur();
            });
          }
        };
        additionalOptions = (attrs.redactor ? scope.$eval(attrs.redactor) : {});
        editor = void 0;
        $_element = angular.element(element);
        scope.$on('addImage', function(e, url) {
          var newHtml;
          newHtml = $("<div>" + ngModel.$viewValue + "</div>").clone().append("<img src=\"" + url + "\">").html();
          return scope.ngModel = newHtml;
        });
        angular.extend(options, {
          buttons: ["bold", "italic"],
          placeholder: true,
          mobile: true,
          convertLinks: true,
          convertVideoLinks: true,
          convertImageLinks: true,
          tabFocus: false,
          dragUpload: true,
          tabFocus: false,
          pastePlainText: true
        });
        scope.$on('focus', function() {
          return setTimeout((function() {
            return element.redactor('focusEnd');
          }), 50);
        });
        $timeout(function() {
          editor = $_element.redactor(options);
          return ngModel.$render();
        });
        ngModel.$render = function() {
          if (angular.isDefined(editor)) {
            return $timeout(function() {
              return $_element.redactor("set", ngModel.$viewValue || "");
            });
          }
        };
        data = {
          Users: [
            {
              name: 'Chris Young',
              id: 'xchris'
            }, {
              name: 'Andrew Hsu',
              id: 'xandrew'
            }, {
              name: 'Grant Lee Crilly',
              id: 'xgrant'
            }, {
              name: 'Michael Natkin'
            }, {
              name: 'Huy Nguyen'
            }
          ],
          Recipes: [
            {
              name: 'Sous Vide Steak'
            }, {
              name: 'Perfect Eggs'
            }, {
              name: 'Fake Quail Eggs'
            }, {
              name: 'Lobster Bisque'
            }, {
              name: 'Lamb Rack'
            }
          ],
          Ingredients: [
            {
              name: 'Carrots'
            }, {
              name: 'Eggs'
            }, {
              name: 'Salmon'
            }, {
              name: 'Rib Eye Steak'
            }, {
              name: 'Quail Egg'
            }, {
              name: 'Coffee'
            }, {
              name: 'Whole Milk'
            }, {
              name: 'Beef Tenderloin'
            }
          ]
        };
        dataToTitle = function(data) {
          var thing, things, title, total, _i, _len;
          total = [];
          for (title in data) {
            things = data[title];
            for (_i = 0, _len = things.length; _i < _len; _i++) {
              thing = things[_i];
              thing.title = title;
            }
            total.push(things);
          }
          return _.flatten(total);
        };
        formattedData = dataToTitle(data);
        allData = [];
        fetchAuto = function(query) {
          var memoized,
            _this = this;
          memoized = _.memoize(function(urlQuery) {
            var baseAPI, def;
            baseAPI = 'http://www.chefsteps.com/comments/at';
            def = $q.defer();
            $http.get("" + baseAPI + "?search=" + urlQuery).then(function(res) {
              allData = dataToTitle(res.data);
              return def.resolve({
                data: allData,
                query: query
              });
            });
            return def.promise;
          });
          return memoized(query);
        };
        return setTimeout((function() {
          var latestQuery;
          return;
          latestQuery = null;
          element.atwho({
            at: "@",
            insert_tpl: '<span data-id="${id}" class="at-who-inserted">@${name}</span>',
            callbacks: {
              matcher: function(flag, subtext, should_start_with_space) {
                var match, regexp;
                flag = flag.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
                if (should_start_with_space) {
                  flag = '(?:^|\\s)' + flag;
                }
                regexp = new RegExp(flag + '([A-Za-z0-9_\ \+\-]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi');
                match = regexp.exec(subtext);
                if (match) {
                  return match[2] || match[1];
                } else {
                  return null;
                }
              }
            },
            fetchData: function(queryText, callback) {
              latestQuery = queryText;
              if (queryText === '') {
                return callback([]);
              } else {
                return fetchAuto(queryText).then(function(response) {
                  if (response.query === latestQuery) {
                    return callback(response.data);
                  }
                });
              }
            },
            sorter: function(query, items, search_key) {
              var filterTitles, sorted, titleScores;
              items = angular.copy(items);
              if (!query) {
                return items;
              }
              titleScores = {};
              items.map(function(item, index) {
                var _name;
                item.score = index / 100;
                return;
                item.score = item[search_key].score(query);
                titleScores[_name = item.title] || (titleScores[_name] = 0);
                if (item.score > titleScores[item.title]) {
                  return titleScores[item.title] = item.score;
                }
              });
              sorted = _.sortBy(items, function(item) {
                return -(titleScores[item.title] * 1000 + item.score);
              });
              filterTitles = sorted.map(function(item, index) {
                var before;
                before = sorted[index - 1];
                item.filteredTitle = before != null ? before.title === item.title ? '' : item.title : item.title;
                return item;
              });
              $('.at-wrapper').removeClass('no-items');
              return filterTitles;
            },
            data: formattedData,
            tpl: require('./at/item-template.jade')()
          });
          return $('.atwho-view').hide();
        }), 2500);
      }
    };
  });
};


},{"./at/item-template.jade":48}],43:[function(require,module,exports){
module.exports = function($compile) {
  return function(scope, element, attrs) {
    return scope.$watch((function(scope) {
      return scope.$eval(attrs.compile);
    }), function(value) {
      element.html(value);
      return $compile(element.contents())(scope);
    });
  };
};


},{}],44:[function(require,module,exports){
module.exports = function() {
  return {
    restrict: 'E',
    scope: {
      text: '@'
    },
    replace: true,
    template: require('./template'),
    controller: function() {
      return this;
    },
    controllerAs: 'at'
  };
};


},{"./template":50}],45:[function(require,module,exports){
module.exports = function() {
  return function(val) {
    if (!((val != null) && val.length > 0)) {
      return;
    }
    return val.replace(/\@(.*?)\&nbsp\;/g, '<at text="$1"></at> ');
  };
};


},{}],46:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"hover\"><div style=\"display:none;\" class=\"hover gene\"><div class=\"hover-content\"><img ng-src=\"/images/users/xgene.png\"/><div class=\"user-name\"><!-- user-name-no-hover(id=\"id\")--><a href=\"javascript:;\">Gene Linetsky</a></div><div class=\"joined\">Joined Mar 14, 2012</div><div class=\"upvotes\">591 total upvotes</div></div><div class=\"follow-hover-wrapper\"><button type=\"button\" ng-class=\"{ following: hover.following }\" ng-click=\"hover.toggleFollowing()\" class=\"btn-follow\"><span ng-show=\"!hover.following\"><i style=\"margin-right:2px;\" class=\"fa fa-user\"></i> Follow</span><span ng-show=\"hover.following\"><i class=\"fa fa-check\"></i> Following</span></button><span class=\"followers\">18 followers</span></div></div><div style=\"display:none;\" class=\"hover dylan\"><div class=\"hover-content\"><img ng-src=\"/images/users/xdylan.png\"/><div class=\"user-name\"><!-- user-name-no-hover(id=\"id\")--><a href=\"javascript:;\">Dylan Pyle</a></div><div class=\"joined\">Joined Nov 26, 2013</div><div class=\"upvotes\">323 total upvotes</div></div><div class=\"follow-hover-wrapper\"><button type=\"button\" ng-class=\"{ following: hover.following }\" ng-click=\"hover.toggleFollowing()\" class=\"btn-follow\"><span ng-show=\"!hover.following\"><i style=\"margin-right:2px;\" class=\"fa fa-user\"></i> Follow</span><span ng-show=\"hover.following\"><i class=\"fa fa-check\"></i> Following</span></button><span class=\"followers\">8 followers</span></div></div><div style=\"display:none;\" class=\"hover gadget\"><div class=\"hover-content\"><img ng-src=\"http://assets.vice.com/content-images/contentimage/no-slug/b6c9996e86fd1e82d4c4dc22c1081b21.jpg\"/><div class=\"user-name\"><!-- user-name-no-hover(id=\"id\")--><a href=\"javascript:;\">VegaOne Rice Lentils <span style=\"color: #e3cf7a; float: right;\"><i class=\"fa fa-star\"></i><i class=\"fa fa-star\"></i><i class=\"fa fa-star\"></i><i class=\"fa fa-star\">   </i></span></a></div><div class=\"joined\">17 ingredients</div><div class=\"upvotes\">By <a href=\"javascript:;\">tederific</a></div></div><div class=\"follow-hover-wrapper\"><button type=\"button\" ng-class=\"{ following: hover.following }\" ng-click=\"hover.toggleFollowing()\" class=\"btn-follow\"><span ng-show=\"!hover.following\"><i style=\"margin-right:2px;\" class=\"fa fa-user\"></i> Follow</span><span ng-show=\"hover.following\"><i class=\"fa fa-check\"></i> Following</span></button><span class=\"followers\">5 followers</span></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],47:[function(require,module,exports){
module.exports = function() {
  return {
    restrict: 'E',
    scope: {
      id: '='
    },
    template: require('./hover-template'),
    repace: true,
    link: function(scope, element) {
      var drop, show;
      show = (function() {
        switch (scope.id) {
          case 'Dylan Pyle':
            return '.dylan';
          case 'Gene Linetsky':
            return '.gene';
          default:
            return '.gadget';
        }
      })();
      return drop = new Drop({
        target: element.parents('.hover-target')[0],
        content: element.find(show).show()[0],
        position: 'top left',
        classes: 'drop-theme-arrows drop-theme-arrows-bounce hover bloom-avatar-hover',
        openOn: 'hover',
        inDelay: 600
      });
    }
  };
};


},{"./hover-template":46}],48:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<li data-id=\"${id}\" data-value=\"${name}\"><a href=\"javascript:;\"><div class=\"at-type\">${filteredTitle}</div><div class=\"at-item\"><img src=\"${avatarUrl}\"/><span>${name}</span></div></a></li>");;return buf.join("");
};
},{"jade/runtime":78}],49:[function(require,module,exports){
/*!
 * string_score.js: String Scoring Algorithm 0.1.20 
 *
 * http://joshaven.com/string_score
 * https://github.com/joshaven/string_score
 *
 * Copyright (C) 2009-2011 Joshaven Potter <yourtech@gmail.com>
 * Special thanks to all of the contributors listed here https://github.com/joshaven/string_score
 * MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * Date: Tue Mar 1 2011
 * Updated: Tue Jun 11 2013
*/

/**
 * Scores a string against another string.
 *  'Hello World'.score('he');     //=> 0.5931818181818181
 *  'Hello World'.score('Hello');  //=> 0.7318181818181818
 */
String.prototype.score = function(word, fuzziness) {

  // If the string is equal to the word, perfect match.
  if (this == word) return 1;

  //if it's not a perfect match and is empty return 0
  if( word == "") return 0;

  var runningScore = 0,
      charScore,
      finalScore,
      string = this,
      lString = string.toLowerCase(),
      strLength = string.length,
      lWord = word.toLowerCase(),
      wordLength = word.length,
      idxOf,
      startAt = 0,
      fuzzies = 1,
      fuzzyFactor;
  
  // Cache fuzzyFactor for speed increase
  if (fuzziness) fuzzyFactor = 1 - fuzziness;

  // Walk through word and add up scores.
  // Code duplication occurs to prevent checking fuzziness inside for loop
  if (fuzziness) {
    for (var i = 0; i < wordLength; ++i) {

      // Find next first case-insensitive match of a character.
      idxOf = lString.indexOf(lWord[i], startAt);
      
      if (-1 === idxOf) {
        fuzzies += fuzzyFactor;
        continue;
      } else if (startAt === idxOf) {
        // Consecutive letter & start-of-string Bonus
        charScore = 0.7;
      } else {
        charScore = 0.1;

        // Acronym Bonus
        // Weighing Logic: Typing the first character of an acronym is as if you
        // preceded it with two perfect character matches.
        if (string[idxOf - 1] === ' ') charScore += 0.8;
      }
      
      // Same case bonus.
      if (string[idxOf] === word[i]) charScore += 0.1; 
      
      // Update scores and startAt position for next round of indexOf
      runningScore += charScore;
      startAt = idxOf + 1;
    }
  } else {
    for (var i = 0; i < wordLength; ++i) {
    
      idxOf = lString.indexOf(lWord[i], startAt);
      
      if (-1 === idxOf) {
        return 0;
      } else if (startAt === idxOf) {
        charScore = 0.7;
      } else {
        charScore = 0.1;
        if (string[idxOf - 1] === ' ') charScore += 0.8;
      }

      if (string[idxOf] === word[i]) charScore += 0.1; 
      
      runningScore += charScore;
      startAt = idxOf + 1;
    }
  }

  // Reduce penalty for longer strings.
  finalScore = 0.5 * (runningScore / strLength  + runningScore / wordLength) / fuzzies;
  
  if ((lWord[0] === lString[0]) && (finalScore < 0.85)) {
    finalScore += 0.15;
  }
  
  return finalScore;
};

},{}],50:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<span class=\"at-custom hover-target\"><at-hover id=\"text\"></at-hover><b class=\"at-module\">@{{text}}</b></span>");;return buf.join("");
};
},{"jade/runtime":78}],51:[function(require,module,exports){
module.exports = function($timeout) {
  $(function() {
    return filepicker.setKey('ANAsscmHGSKqZCHObvuK6z');
  });
  return {
    restrict: 'E',
    scope: {
      ngModel: '=',
      placeholder: '@',
      onSubmit: '&',
      buttonText: "@",
      xtabindex: '@'
    },
    template: require('./template.jade'),
    link: function(scope, element) {
      var input, replaceInput, setFileEvent,
        _this = this;
      scope.focused = false;
      input = element.find('input[type=file]')[0];
      scope.setFocus = function(focused) {
        return scope.focused = focused;
      };
      scope.save = function() {
        $(input).click();
      };
      scope.progress = 0;
      scope.loading = false;
      input = element.find('input[type=file]')[0];
      setFileEvent = function() {
        return $(input).unbind().change(function() {
          var options;
          if (!input.value) {
            return;
          }
          scope.$apply(function() {
            scope.loading = true;
            return scope.progress = 0;
          });
          options = {
            mimetype: 'image/*'
          };
          return filepicker.store(element.find('input[type=file]')[0], options, function(InkBlob) {
            return scope.$apply(function() {
              var _this = this;
              scope.progress = 100;
              $timeout(function() {
                scope.loading = false;
                return scope.progress = 0;
              }, 1200);
              scope.$broadcast('addImage', InkBlob.url);
              return replaceInput();
            });
          }, function(FPError) {
            return console.log(FPError.toString());
          }, function(progress) {
            return scope.$apply(function() {
              return scope.progress = progress;
            });
          });
        });
      };
      replaceInput = function() {
        $(input).replaceWith($(input).val('').clone(true));
        input = element.find('input[type=file]')[0];
        return setFileEvent();
      };
      setFileEvent();
      scope.xtabindexPlus = +scope.xtabindex + 1;
      return scope.submit = function() {
        if (scope.ngModel.length > 0) {
          return scope.onSubmit();
        }
      };
    }
  };
};


},{"./template.jade":56}],52:[function(require,module,exports){
/*! jquery.atwho - v0.4.7 - 2014-03-19
* Copyright (c) 2014 chord.luo <chord.luo@gmail.com>; 
* homepage: http://ichord.github.com/At.js 
* Licensed MIT
*/

(function() {
  (function(factory) {
    if (typeof define === 'function' && define.amd) {
      return define(['jquery'], factory);
    } else {
      return factory(window.jQuery);
    }
  })(function($) {

var $CONTAINER, Api, App, Atwho, Controller, DEFAULT_CALLBACKS, KEY_CODE, Model, View,
  __slice = [].slice;

App = (function() {
  function App(inputor) {
    this.current_flag = null;
    this.controllers = {};
    this.alias_maps = {};
    this.$inputor = $(inputor);
    this.listen();
  }

  App.prototype.controller = function(at) {
    return this.controllers[this.alias_maps[at] || at || this.current_flag];
  };

  App.prototype.set_context_for = function(at) {
    this.current_flag = at;
    return this;
  };

  App.prototype.reg = function(flag, setting) {
    var controller, _base;
    controller = (_base = this.controllers)[flag] || (_base[flag] = new Controller(this, flag));
    if (setting.alias) {
      this.alias_maps[setting.alias] = flag;
    }
    controller.init(setting);
    return this;
  };

  App.prototype.listen = function() {
    return this.$inputor.on('keyup.atwhoInner', (function(_this) {
      return function(e) {
        return _this.on_keyup(e);
      };
    })(this)).on('keydown.atwhoInner', (function(_this) {
      return function(e) {
        return _this.on_keydown(e);
      };
    })(this)).on('scroll.atwhoInner', (function(_this) {
      return function(e) {
        var _ref;
        return (_ref = _this.controller()) != null ? _ref.view.hide() : void 0;
      };
    })(this)).on('blur.atwhoInner', (function(_this) {
      return function(e) {
        var c;
        if (c = _this.controller()) {
          return c.view.hide(c.get_opt("display_timeout"));
        }
      };
    })(this));
  };

  App.prototype.shutdown = function() {
    var c, _, _ref;
    _ref = this.controllers;
    for (_ in _ref) {
      c = _ref[_];
      c.destroy();
    }
    return this.$inputor.off('.atwhoInner');
  };

  App.prototype.dispatch = function() {
    return $.map(this.controllers, (function(_this) {
      return function(c) {
        if (c.look_up()) {
          return _this.set_context_for(c.at);
        }
      };
    })(this));
  };

  App.prototype.on_keyup = function(e) {
    var _ref;
    switch (e.keyCode) {
      case KEY_CODE.ESC:
        e.preventDefault();
        if ((_ref = this.controller()) != null) {
          _ref.view.hide();
        }
        break;
      case KEY_CODE.DOWN:
      case KEY_CODE.UP:
      case KEY_CODE.CTRL:
        $.noop();
        break;
      case KEY_CODE.P:
      case KEY_CODE.N:
        if (!e.ctrlKey) {
          this.dispatch();
        }
        break;
      default:
        this.dispatch();
    }
  };

  App.prototype.on_keydown = function(e) {
    var view, _ref;
    view = (_ref = this.controller()) != null ? _ref.view : void 0;
    if (!(view && view.visible())) {
      return;
    }
    switch (e.keyCode) {
      case KEY_CODE.ESC:
        e.preventDefault();
        view.hide();
        break;
      case KEY_CODE.UP:
        e.preventDefault();
        view.prev();
        break;
      case KEY_CODE.DOWN:
        e.preventDefault();
        view.next();
        break;
      case KEY_CODE.P:
        if (!e.ctrlKey) {
          return;
        }
        e.preventDefault();
        view.prev();
        break;
      case KEY_CODE.N:
        if (!e.ctrlKey) {
          return;
        }
        e.preventDefault();
        view.next();
        break;
      case KEY_CODE.TAB:
      case KEY_CODE.ENTER:
        if (!view.visible()) {
          return;
        }
        e.preventDefault();
        view.choose();
        break;
      default:
        $.noop();
    }
  };

  return App;

})();

Controller = (function() {
  var uuid, _uuid;

  _uuid = 0;

  uuid = function() {
    return _uuid += 1;
  };

  function Controller(app, at) {
    this.app = app;
    this.at = at;
    this.$inputor = this.app.$inputor;
    this.oDocument = this.$inputor[0].ownerDocument;
    this.oWindow = this.oDocument.defaultView || this.oDocument.parentWindow;
    this.id = this.$inputor[0].id || uuid();
    this.setting = null;
    this.query = null;
    this.pos = 0;
    this.cur_rect = null;
    this.range = null;
    $CONTAINER.append(this.$el = $("<div id='atwho-ground-" + this.id + "'></div>"));
    this.model = new Model(this);
    this.view = new View(this);
  }

  Controller.prototype.init = function(setting) {
    this.setting = $.extend({}, this.setting || $.fn.atwho["default"], setting);
    this.view.init();
    return this.model.reload(this.setting.data);
  };

  Controller.prototype.destroy = function() {
    this.trigger('beforeDestroy');
    this.model.destroy();
    return this.view.destroy();
  };

  Controller.prototype.call_default = function() {
    var args, error, func_name;
    func_name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    try {
      return DEFAULT_CALLBACKS[func_name].apply(this, args);
    } catch (_error) {
      error = _error;
      return $.error("" + error + " Or maybe At.js doesn't have function " + func_name);
    }
  };

  Controller.prototype.trigger = function(name, data) {
    var alias, event_name;
    if (data == null) {
      data = [];
    }
    data.push(this);
    alias = this.get_opt('alias');
    event_name = alias ? "" + name + "-" + alias + ".atwho" : "" + name + ".atwho";
    return this.$inputor.trigger(event_name, data);
  };

  Controller.prototype.callbacks = function(func_name) {
    return this.get_opt("callbacks")[func_name] || DEFAULT_CALLBACKS[func_name];
  };

  Controller.prototype.get_opt = function(at, default_value) {
    var e;
    try {
      return this.setting[at];
    } catch (_error) {
      e = _error;
      return null;
    }
  };

  Controller.prototype.content = function() {
    if (this.$inputor.is('textarea, input')) {
      return this.$inputor.val();
    } else {
      return this.$inputor.text();
    }
  };

  Controller.prototype.catch_query = function() {
    var caret_pos, content, end, query, start, subtext;
    content = this.content();
    caret_pos = this.$inputor.caret('pos');
    subtext = content.slice(0, caret_pos);
    query = this.callbacks("matcher").call(this, this.at, subtext, this.get_opt('start_with_space'));
    if (typeof query === "string" && query.length <= this.get_opt('max_len', 20)) {
      start = caret_pos - query.length;
      end = start + query.length;
      this.pos = start;
      query = {
        'text': query.toLowerCase(),
        'head_pos': start,
        'end_pos': end
      };
      this.trigger("matched", [this.at, query.text]);
    } else {
      this.view.hide();
    }
    return this.query = query;
  };

  Controller.prototype.rect = function() {
    var c, scale_bottom;
    if (!(c = this.$inputor.caret('offset', this.pos - 1))) {
      return;
    }
    if (this.$inputor.attr('contentEditable') === 'true') {
      c = (this.cur_rect || (this.cur_rect = c)) || c;
    }
    scale_bottom = document.selection ? 0 : 2;
    return {
      left: c.left,
      top: c.top,
      bottom: c.top + c.height + scale_bottom
    };
  };

  Controller.prototype.reset_rect = function() {
    if (this.$inputor.attr('contentEditable') === 'true') {
      return this.cur_rect = null;
    }
  };

  Controller.prototype.mark_range = function() {
    if (this.$inputor.attr('contentEditable') === 'true') {
      if (this.oWindow.getSelection) {
        this.range = this.oWindow.getSelection().getRangeAt(0);
      }
      if (this.oDocument.selection) {
        return this.ie8_range = this.oDocument.selection.createRange();
      }
    }
  };

  Controller.prototype.insert_content_for = function($li) {
    var data, data_value, tpl;
    data_value = $li.data('value');
    tpl = this.get_opt('insert_tpl');
    if (this.$inputor.is('textarea, input') || !tpl) {
      return data_value;
    }
    data = $.extend({}, $li.data('item-data'), {
      'atwho-data-value': data_value,
      'atwho-at': this.at
    });
    return this.callbacks("tpl_eval").call(this, tpl, data);
  };

  Controller.prototype.insert = function(content, $li) {
    var $inputor, $insert_node, class_name, content_node, insert_node, pos, range, sel, source, start_str, text;
    $inputor = this.$inputor;
    if ($inputor.attr('contentEditable') === 'true') {
      class_name = "atwho-view-flag atwho-view-flag-" + (this.get_opt('alias') || this.at);
      content_node = "" + content + "<span contenteditable='false'>&nbsp;<span>";
      
      insert_node = "<span contenteditable='false' class='" + class_name + "'>" + content_node + "</span>";
      $insert_node = $(insert_node, this.oDocument).data('atwho-data-item', $li.data('item-data'));
      if (this.oDocument.selection) {
        $insert_node = $("<span contenteditable='true'></span>", this.oDocument).html($insert_node);
      }
    }
    if ($inputor.is('textarea, input')) {
      content = '' + content;
      source = $inputor.val();
      start_str = source.slice(0, Math.max(this.query.head_pos - this.at.length, 0));
      text = "" + start_str + content + " " + (source.slice(this.query['end_pos'] || 0));
      $inputor.val(text);
      $inputor.caret('pos', start_str.length + content.length + 1);
    } else if (range = this.range) {
      pos = range.startOffset - (this.query.end_pos - this.query.head_pos) - this.at.length;
      range.setStart(range.endContainer, Math.max(pos, 0));
      range.setEnd(range.endContainer, range.endOffset);
      range.deleteContents();
      range.insertNode($insert_node[0]);
      range.collapse(false);
      sel = this.oWindow.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    } else if (range = this.ie8_range) {
      range.moveStart('character', this.query.end_pos - this.query.head_pos - this.at.length);
      range.pasteHTML(content_node);
      range.collapse(false);
      range.select();
    }
    if (!$inputor.is(':focus')) {
      $inputor.focus();
    }
    return $inputor.change();
  };

  Controller.prototype.render_view = function(data) {
    var search_key;
    search_key = this.get_opt("search_key");
    // data = this.callbacks("sorter").call(this, this.query.text, data.slice(0, 1001), search_key);
    if (this.query == null) return;
    if (this.query && this.query.text == "") { $('.at-wrapper').addClass('no-items'); }
    data = this.get_opt('sorter').call(this, this.query.text, data.slice(0, 1001), search_key);
    return this.view.render(data.slice(0, this.get_opt('limit')));
  };

  Controller.prototype.look_up = function() {
    var query, _callback;
    if (!(query = this.catch_query())) {
      return;
    }
    _callback = function(data) {
      // NICK commented out the next few lines and made this always run
      return this.render_view(data);
      /*
      if (data && data.length > 0) {
        return this.render_view(data);
      } else {
        return this.view.hide();
      }
      */
    };
    this.model.query(query.text, $.proxy(_callback, this));
    return query;
  };

  return Controller;

})();

Model = (function() {
  function Model(context) {
    this.context = context;
    this.at = this.context.at;
    this.storage = this.context.$inputor;
  }

  Model.prototype.destroy = function() {
    return this.storage.data(this.at, null);
  };

  Model.prototype.saved = function() {
    return this.fetch() > 0;
  };

  Model.prototype.query = function(query, callback) {
    this.context.get_opt("fetchData")(query, callback);
    return
    var data, search_key, _remote_filter;
    data = this.fetch();
    search_key = this.context.get_opt("search_key");
    data = this.context.callbacks('filter').call(this.context, query, data, search_key) || [];
    _remote_filter = this.context.callbacks('remote_filter');
    if (data.length > 0 || (!_remote_filter && data.length === 0)) {
      return callback(data);
    } else {
      return _remote_filter.call(this.context, query, callback);
    }
  };

  Model.prototype.fetch = function() {
    return this.storage.data(this.at) || [];
  };

  Model.prototype.save = function(data) {
    return this.storage.data(this.at, this.context.callbacks("before_save").call(this.context, data || []));
  };

  Model.prototype.load = function(data) {
    //if (!(this.saved() || !data)) {
    return this._load(data);
    //}
  };

  Model.prototype.reload = function(data) {
    return this._load(data);
  };

  Model.prototype._load = function(data) {
    if (typeof data === "string") {
      return $.ajax(data, {
        dataType: "json"
      }).done((function(_this) {
        return function(data) {
          return _this.save(data);
        };
      })(this));
    } else {
      return this.save(data);
    }
  };

  return Model;

})();

View = (function() {
  function View(context) {
    this.context = context;
    //this.$el = $("<div class='atwho-view'><ul class='atwho-view-ul'></ul></div>");
    emptyText = '<div class="empty-text">Type to include a user, ingredient, or recipe</div>';
    this.$el = $('<div class="at-wrapper no-items atwho-view">' + emptyText + '<ul class="atwho-view-ul"></ul></div>');
    this.timeout_id = null;
    this.context.$el.append(this.$el);
    this.bind_event();
  }

  View.prototype.init = function() {
    var id;
    id = this.context.get_opt("alias") || this.context.at.charCodeAt(0);
    return this.$el.attr({
      'id': "at-view-" + id
    });
  };

  View.prototype.destroy = function() {
    return this.$el.remove();
  };

  View.prototype.bind_event = function() {
    var $menu;
    $menu = this.$el.find('ul');
    return $menu.on('mouseenter.atwho-view', 'li', function(e) {
      $menu.find('.cur').removeClass('cur');
      return $(e.currentTarget).addClass('cur');
    }).on('click', (function(_this) {
      return function(e) {
        _this.choose();
        return e.preventDefault();
      };
    })(this));
  };

  View.prototype.visible = function() {
    return this.$el.is(":visible");
  };

  View.prototype.choose = function() {
    var $li, content;
    $li = this.$el.find(".cur");
    content = this.context.insert_content_for($li);
    this.context.insert(this.context.callbacks("before_insert").call(this.context, content, $li), $li);
    this.context.trigger("inserted", [$li]);
    return this.hide();
  };
  var computeFrameOffset = function(win, dims) {
    // initialize our result variable
    if (typeof dims === 'undefined') {
        var dims = { top: 0, left: 0 };
    }

    // find our <iframe> tag within our parent window
    var frames = win.parent.document.getElementsByTagName('iframe');
    var frame;
    var found = false;

    for (var i=0, len=frames.length; i<len; i++) {
        frame = frames[i];
        if (frame.contentWindow == win) {
            found = true;
            break;
        }
    }

    // add the offset & recur up the frame chain
 
    return $(frame).offset();
  };

  View.prototype.reposition = function(rect) {
    var offset;
    var frameOffset = computeFrameOffset(window);
    /*
    if (rect.bottom + this.$el.height() - $(window).scrollTop() > $(window).height()) {
      rect.bottom = rect.top - this.$el.height();
    }
    */

    var computed = {top:0, left:0};
    // I'm in an iFrame
    if (window.location != window.parent.location) {
      computed = computeFrameOffset(window);
    }

    /*
      10 is because jquery offset is not calculating the padding of bloom input
      TOOD fix
    */
    offset = {
      left: rect.left - computed.left,
      top: rect.bottom - computed.top
    };
    this.$el.offset(offset);

    return this.context.trigger("reposition", [offset]);
  };

  View.prototype.next = function() {
    var cur, next;
    cur = this.$el.find('.cur').removeClass('cur');
    next = cur.next();
    if (!next.length) {
      next = this.$el.find('li:first');
    }
    return next.addClass('cur');
  };

  View.prototype.prev = function() {
    var cur, prev;
    cur = this.$el.find('.cur').removeClass('cur');
    prev = cur.prev();
    if (!prev.length) {
      prev = this.$el.find('li:last');
    }
    return prev.addClass('cur');
  };

  View.prototype.show = function() {
    var rect;
    this.context.mark_range();
    if (!this.visible()) {
      this.$el.show();
      this.context.trigger('shown');
    }
    if (rect = this.context.rect()) {
      return this.reposition(rect);
    }
  };

  View.prototype.hide = function(time) {
    var callback;
    if (isNaN(time && this.visible())) {
      this.context.reset_rect();
      this.$el.hide();
      return this.context.trigger('hidden');
    } else {
      callback = (function(_this) {
        return function() {
          return _this.hide();
        };
      })(this);
      clearTimeout(this.timeout_id);
      return this.timeout_id = setTimeout(callback, time);
    }
  };

  View.prototype.render = function(list) {
    var $li, $ul, item, li, tpl, _i, _len;
    if (!($.isArray(list) && list.length > 0)) {
      // this.hide();
      // return;
    }
    this.$el.find('ul').empty();
    $ul = this.$el.find('ul');
    tpl = this.context.get_opt('tpl');
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      item = list[_i];
      item = $.extend({}, item, {
        'atwho-at': this.context.at
      });
      li = this.context.callbacks("tpl_eval").call(this.context, tpl, item);
      $li = $(this.context.callbacks("highlighter").call(this.context, li, this.context.query.text));
      $li.data("item-data", item);
      $ul.append($li);
    }
    this.show();
    return $ul.find("li:first").addClass("cur");
  };

  return View;

})();

KEY_CODE = {
  DOWN: 40,
  UP: 38,
  ESC: 27,
  TAB: 9,
  ENTER: 13,
  CTRL: 17,
  P: 80,
  N: 78
};

DEFAULT_CALLBACKS = {
  before_save: function(data) {
    var item, _i, _len, _results;
    if (!$.isArray(data)) {
      return data;
    }
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      item = data[_i];
      if ($.isPlainObject(item)) {
        _results.push(item);
      } else {
        _results.push({
          name: item
        });
      }
    }
    return _results;
  },
  matcher: function(flag, subtext, should_start_with_space) {
    var match, regexp;
    flag = flag.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
    if (should_start_with_space) {
      flag = '(?:^|\\s)' + flag;
    }
    regexp = new RegExp(flag + '([A-Za-z0-9_\+\-]*)$|' + flag + '([^\\x00-\\xff]*)$', 'gi');
    match = regexp.exec(subtext);
    if (match) {
      return match[2] || match[1];
    } else {
      return null;
    }
  },
  filter: function(query, data, search_key) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      item = data[_i];
      if (~item[search_key].toLowerCase().indexOf(query)) {
        _results.push(item);
      }
    }
    return _results;
  },
  remote_filter: null,
  sorter: function(query, items, search_key) {
    var item, _i, _len, _results;
    if (!query) {
      return items;
    }
    _results = [];
    for (_i = 0, _len = items.length; _i < _len; _i++) {
      item = items[_i];
      item.atwho_order = item[search_key].toLowerCase().indexOf(query);
      if (item.atwho_order > -1) {
        _results.push(item);
      }
      }
    return _results.sort(function(a, b) {
      return a.atwho_order - b.atwho_order;
    });
  },
  tpl_eval: function(tpl, map) {
    var error;
    try {
      return tpl.replace(/\$\{([^\}]*)\}/g, function(tag, key, pos) {
        return map[key];
      });
    } catch (_error) {
      error = _error;
      return "";
    }
  },
  highlighter: function(li, query) {
    return li
    /* var regexp;
    if (!query) {
      return li;
    }
    regexp = new RegExp(">\\s*(\\w*)(" + query.replace("+", "\\+") + ")(\\w*)\\s*<", 'ig');
    return li.replace(regexp, function(str, $1, $2, $3) {
      return '> ' + $1 + '<strong>' + $2 + '</strong>' + $3 + ' <';
    }); */
  },
  before_insert: function(value, $li) {
    return value;
  }
};

Api = {
  load: function(at, data) {
    var c;
    if (c = this.controller(at)) {
      return c.model.load(data);
    }
  },
  getInsertedItemsWithIDs: function(at) {
    var c, ids, items;
    if (!(c = this.controller(at))) {
      return [null, null];
    }
    if (at) {
      at = "-" + (c.get_opt('alias') || c.at);
    }
    ids = [];
    items = $.map(this.$inputor.find("span.atwho-view-flag" + (at || "")), function(item) {
      var data;
      data = $(item).data('atwho-data-item');
      if (ids.indexOf(data.id) > -1) {
        return;
      }
      if (data.id) {
        ids.push = data.id;
      }
      return data;
    });
    return [ids, items];
  },
  getInsertedItems: function(at) {
    return Api.getInsertedItemsWithIDs.apply(this, [at])[1];
  },
  getInsertedIDs: function(at) {
    return Api.getInsertedItemsWithIDs.apply(this, [at])[0];
  },
  run: function() {
    return this.dispatch();
  },
  destroy: function() {
    this.shutdown();
    return this.$inputor.data('atwho', null);
  }
};

Atwho = {
  init: function(options) {
    var $this, app;
    app = ($this = $(this)).data("atwho");
    if (!app) {
      $this.data('atwho', (app = new App(this)));
    }
    app.reg(options.at, options);
    return this;
  }
};

$CONTAINER = $("<div id='atwho-container'></div>");


$.fn.atwho = function(method) {
  var result, _args;
  _args = arguments;
  $(this.parents('.bloom-input')[0]).append($CONTAINER);
  //$('body').append($CONTAINER);
  result = null;
  this.filter('textarea, input, [contenteditable=true]').each(function() {
    var app;
    if (typeof method === 'object' || !method) {
      return Atwho.init.apply(this, _args);
    } else if (Api[method]) {
      if (app = $(this).data('atwho')) {
        return result = Api[method].apply(app, Array.prototype.slice.call(_args, 1));
      }
    } else {
      return $.error("Method " + method + " does not exist on jQuery.caret");
    }
  });
  return result || this;
};

$.fn.atwho["default"] = {
  at: void 0,
  alias: void 0,
  data: null,
  tpl: "<li data-value='${atwho-at}${name}'>${name}</li>",
  insert_tpl: "<span>${atwho-data-value}</span>",
  callbacks: DEFAULT_CALLBACKS,
  search_key: "name",
  start_with_space: true,
  limit: 5,
  max_len: 20,
  display_timeout: 300
};

  });
}).call(this);

},{}],53:[function(require,module,exports){
/*! jquery.caret 2014-03-14 */
(function(){!function(a){return"function"==typeof define&&define.amd?define(["jquery"],a):a(window.jQuery)}(function(a){"use strict";var b,c,d,e,f,g,h,i,j;return j="caret",b=function(){function b(a){this.$inputor=a,this.domInputor=this.$inputor[0]}return b.prototype.setPos=function(){return this.domInputor},b.prototype.getIEPosition=function(){return a.noop()},b.prototype.getPosition=function(){return a.noop()},b.prototype.getOldIEPos=function(){var a,b;return b=g.selection.createRange(),a=g.body.createTextRange(),a.moveToElementText(this.domInputor),a.setEndPoint("EndToEnd",b),a.text.length},b.prototype.getPos=function(){var a,b,c;return(c=this.range())?(a=c.cloneRange(),a.selectNodeContents(this.domInputor),a.setEnd(c.endContainer,c.endOffset),b=a.toString().length,a.detach(),b):g.selection?this.getOldIEPos():void 0},b.prototype.getOldIEOffset=function(){var a,b;return a=g.selection.createRange().duplicate(),a.moveStart("character",-1),b=a.getBoundingClientRect(),{height:b.bottom-b.top,left:b.left,top:b.top}},b.prototype.getOffset=function(){var b,c,d,e;if(i.getSelection&&(d=this.range())){if(d.endOffset-1<0)return null;b=d.cloneRange(),b.setStart(d.endContainer,d.endOffset-1),b.setEnd(d.endContainer,d.endOffset),e=b.getBoundingClientRect(),c={height:e.height,left:e.left+e.width,top:e.top},b.detach()}else g.selection&&(c=this.getOldIEOffset());return c&&!h&&(c.top+=a(i).scrollTop(),c.left+=a(i).scrollLeft()),c},b.prototype.range=function(){var a;if(i.getSelection)return a=i.getSelection(),a.rangeCount>0?a.getRangeAt(0):null},b}(),c=function(){function b(a){this.$inputor=a,this.domInputor=this.$inputor[0]}return b.prototype.getIEPos=function(){var a,b,c,d,e,f,h;return b=this.domInputor,f=g.selection.createRange(),e=0,f&&f.parentElement()===b&&(d=b.value.replace(/\r\n/g,"\n"),c=d.length,h=b.createTextRange(),h.moveToBookmark(f.getBookmark()),a=b.createTextRange(),a.collapse(!1),e=h.compareEndPoints("StartToEnd",a)>-1?c:-h.moveStart("character",-c)),e},b.prototype.getPos=function(){return g.selection?this.getIEPos():this.domInputor.selectionStart},b.prototype.setPos=function(a){var b,c;return b=this.domInputor,g.selection?(c=b.createTextRange(),c.move("character",a),c.select()):b.setSelectionRange&&b.setSelectionRange(a,a),b},b.prototype.getIEOffset=function(a){var b,c,d,e;return c=this.domInputor.createTextRange(),a||(a=this.getPos()),c.move("character",a),d=c.boundingLeft,e=c.boundingTop,b=c.boundingHeight,{left:d,top:e,height:b}},b.prototype.getOffset=function(b){var c,d,e;return c=this.$inputor,g.selection?(d=this.getIEOffset(b),d.top+=a(i).scrollTop()+c.scrollTop(),d.left+=a(i).scrollLeft()+c.scrollLeft(),d):(d=c.offset(),e=this.getPosition(b),d={left:d.left+e.left-c.scrollLeft(),top:d.top+e.top-c.scrollTop(),height:e.height})},b.prototype.getPosition=function(a){var b,c,e,f,g,h;return b=this.$inputor,e=function(a){return a.replace(/</g,"&lt").replace(/>/g,"&gt").replace(/`/g,"&#96").replace(/"/g,"&quot").replace(/\r\n|\r|\n/g,"<br />")},void 0===a&&(a=this.getPos()),h=b.val().slice(0,a),f="<span>"+e(h)+"</span>",f+="<span id='caret'>|</span>",g=new d(b),c=g.create(f).rect()},b.prototype.getIEPosition=function(a){var b,c,d,e,f;return d=this.getIEOffset(a),c=this.$inputor.offset(),e=d.left-c.left,f=d.top-c.top,b=d.height,{left:e,top:f,height:b}},b}(),d=function(){function b(a){this.$inputor=a}return b.prototype.css_attr=["overflowY","height","width","paddingTop","paddingLeft","paddingRight","paddingBottom","marginTop","marginLeft","marginRight","marginBottom","fontFamily","borderStyle","borderWidth","wordWrap","fontSize","lineHeight","overflowX","text-align"],b.prototype.mirrorCss=function(){var b,c=this;return b={position:"absolute",left:-9999,top:0,zIndex:-2e4,"white-space":"pre-wrap"},a.each(this.css_attr,function(a,d){return b[d]=c.$inputor.css(d)}),b},b.prototype.create=function(b){return this.$mirror=a("<div></div>"),this.$mirror.css(this.mirrorCss()),this.$mirror.html(b),this.$inputor.after(this.$mirror),this},b.prototype.rect=function(){var a,b,c;return a=this.$mirror.find("#caret"),b=a.position(),c={left:b.left,top:b.top,height:a.height()},this.$mirror.remove(),c},b}(),e={contentEditable:function(a){return!(!a[0].contentEditable||"true"!==a[0].contentEditable)}},f={pos:function(a){return a||0===a?this.setPos(a):this.getPos()},position:function(a){return g.selection?this.getIEPosition(a):this.getPosition(a)},offset:function(b){var c,d;return d=this.getOffset(b),h&&(c=a(h).offset(),d.top+=c.top,d.left+=c.left),d}},g=null,i=null,h=null,a.fn.caret=function(d){var j,k;g=this[0].ownerDocument,i=g.defaultView||g.parentWindow;try{h=i.frameElement}catch(l){k=l}return j=e.contentEditable(this)?new b(this):new c(this),f[d]?f[d].apply(j,Array.prototype.slice.call(arguments,1)):a.error("Method "+d+" does not exist on jQuery.caret")},a.fn.caret.EditableCaret=b,a.fn.caret.InputCaret=c,a.fn.caret.Utils=e,a.fn.caret.apis=f})}).call(this);
},{}],54:[function(require,module,exports){
module.exports = function() {
  require('./jquery.caret');
  require('./jquery.atwho');
  require('./redactor')();
  require('./angular-redactor')();
  require('./at/string-score');
  return angular.module('bloom.input', ['redactor']).directive('at', require('./at/directive')).filter('atModule', require('./at/filter')).directive('bloomInput', require('./directive')).directive('atHover', require('./at/hover')).directive('compile', require('./at/compile'));
};


},{"./angular-redactor":42,"./at/compile":43,"./at/directive":44,"./at/filter":45,"./at/hover":47,"./at/string-score":49,"./directive":51,"./jquery.atwho":52,"./jquery.caret":53,"./redactor":55}],55:[function(require,module,exports){
module.exports = function() {
  var _0x8a37=["\x75\x73\x65\x20\x73\x74\x72\x69\x63\x74","\x73\x74\x61\x72\x74\x4F\x66\x66\x73\x65\x74","\x65\x6E\x64\x4F\x66\x66\x73\x65\x74","\x72\x61\x6E\x67\x65","\x65\x71\x75\x61\x6C\x73","\x70\x72\x6F\x74\x6F\x74\x79\x70\x65","\x72\x65\x64\x61\x63\x74\x6F\x72","\x66\x6E","\x63\x61\x6C\x6C","\x73\x6C\x69\x63\x65","\x73\x74\x72\x69\x6E\x67","\x64\x61\x74\x61","\x75\x6E\x64\x65\x66\x69\x6E\x65\x64","\x69\x73\x46\x75\x6E\x63\x74\x69\x6F\x6E","\x61\x70\x70\x6C\x79","\x70\x75\x73\x68","\x4E\x6F\x20\x73\x75\x63\x68\x20\x6D\x65\x74\x68\x6F\x64\x20\x22","\x22\x20\x66\x6F\x72\x20\x52\x65\x64\x61\x63\x74\x6F\x72","\x65\x72\x72\x6F\x72","\x65\x61\x63\x68","\x6C\x65\x6E\x67\x74\x68","\x69\x6E\x69\x74","\x52\x65\x64\x61\x63\x74\x6F\x72","\x56\x45\x52\x53\x49\x4F\x4E","\x39\x2E\x32\x2E\x31","\x6F\x70\x74\x73","\x65\x6E","\x6C\x74\x72","","\x68\x74\x74\x70\x3A\x2F\x2F","\x31\x30\x70\x78","\x66\x69\x6C\x65","\x69\x6D\x61\x67\x65\x2F\x70\x6E\x67","\x69\x6D\x61\x67\x65\x2F\x6A\x70\x65\x67","\x69\x6D\x61\x67\x65\x2F\x67\x69\x66","\x66\x6F\x72\x6D\x61\x74\x74\x69\x6E\x67","\x62\x6F\x6C\x64","\x69\x74\x61\x6C\x69\x63","\x64\x65\x6C\x65\x74\x65\x64","\x75\x6E\x6F\x72\x64\x65\x72\x65\x64\x6C\x69\x73\x74","\x6F\x72\x64\x65\x72\x65\x64\x6C\x69\x73\x74","\x6F\x75\x74\x64\x65\x6E\x74","\x69\x6E\x64\x65\x6E\x74","\x68\x74\x6D\x6C","\x69\x6D\x61\x67\x65","\x76\x69\x64\x65\x6F","\x74\x61\x62\x6C\x65","\x6C\x69\x6E\x6B","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74","\x7C","\x68\x6F\x72\x69\x7A\x6F\x6E\x74\x61\x6C\x72\x75\x6C\x65","\x75\x6E\x64\x65\x72\x6C\x69\x6E\x65","\x61\x6C\x69\x67\x6E\x6C\x65\x66\x74","\x61\x6C\x69\x67\x6E\x63\x65\x6E\x74\x65\x72","\x61\x6C\x69\x67\x6E\x72\x69\x67\x68\x74","\x6A\x75\x73\x74\x69\x66\x79","\x70","\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65","\x70\x72\x65","\x68\x31","\x68\x32","\x68\x33","\x68\x34","\x68\x35","\x68\x36","\x68\x65\x61\x64","\x62\x6F\x64\x79","\x6D\x65\x74\x61","\x73\x63\x72\x69\x70\x74","\x73\x74\x79\x6C\x65","\x61\x70\x70\x6C\x65\x74","\x73\x74\x72\x6F\x6E\x67","\x65\x6D","\x3C\x70\x3E\x26\x23\x78\x32\x30\x30\x62\x3B\x3C\x2F\x70\x3E","\x26\x23\x78\x32\x30\x30\x62\x3B","\x50","\x48\x31","\x48\x32","\x48\x33","\x48\x34","\x48\x35","\x48\x36","\x44\x44","\x44\x4C","\x44\x54","\x44\x49\x56","\x54\x44","\x42\x4C\x4F\x43\x4B\x51\x55\x4F\x54\x45","\x4F\x55\x54\x50\x55\x54","\x46\x49\x47\x43\x41\x50\x54\x49\x4F\x4E","\x41\x44\x44\x52\x45\x53\x53","\x53\x45\x43\x54\x49\x4F\x4E","\x48\x45\x41\x44\x45\x52","\x46\x4F\x4F\x54\x45\x52","\x41\x53\x49\x44\x45","\x41\x52\x54\x49\x43\x4C\x45","\x61\x72\x65\x61","\x68\x72","\x69\x3F\x66\x72\x61\x6D\x65","\x6E\x6F\x73\x63\x72\x69\x70\x74","\x74\x62\x6F\x64\x79","\x74\x68\x65\x61\x64","\x74\x66\x6F\x6F\x74","\x6C\x69","\x64\x74","\x68\x5B\x31\x2D\x36\x5D","\x6F\x70\x74\x69\x6F\x6E","\x64\x69\x76","\x64\x6C","\x66\x69\x65\x6C\x64\x73\x65\x74","\x66\x6F\x72\x6D","\x66\x72\x61\x6D\x65\x73\x65\x74","\x6D\x61\x70","\x6F\x6C","\x73\x65\x6C\x65\x63\x74","\x74\x64","\x74\x68","\x74\x72","\x75\x6C","\x4C\x49","\x50\x52\x45","\x48\x54\x4D\x4C","\x49\x6E\x73\x65\x72\x74\x20\x56\x69\x64\x65\x6F","\x49\x6E\x73\x65\x72\x74\x20\x49\x6D\x61\x67\x65","\x54\x61\x62\x6C\x65","\x4C\x69\x6E\x6B","\x49\x6E\x73\x65\x72\x74\x20\x6C\x69\x6E\x6B","\x45\x64\x69\x74\x20\x6C\x69\x6E\x6B","\x55\x6E\x6C\x69\x6E\x6B","\x46\x6F\x72\x6D\x61\x74\x74\x69\x6E\x67","\x4E\x6F\x72\x6D\x61\x6C\x20\x74\x65\x78\x74","\x51\x75\x6F\x74\x65","\x43\x6F\x64\x65","\x48\x65\x61\x64\x65\x72\x20\x31","\x48\x65\x61\x64\x65\x72\x20\x32","\x48\x65\x61\x64\x65\x72\x20\x33","\x48\x65\x61\x64\x65\x72\x20\x34","\x48\x65\x61\x64\x65\x72\x20\x35","\x42\x6F\x6C\x64","\x49\x74\x61\x6C\x69\x63","\x46\x6F\x6E\x74\x20\x43\x6F\x6C\x6F\x72","\x42\x61\x63\x6B\x20\x43\x6F\x6C\x6F\x72","\x55\x6E\x6F\x72\x64\x65\x72\x65\x64\x20\x4C\x69\x73\x74","\x4F\x72\x64\x65\x72\x65\x64\x20\x4C\x69\x73\x74","\x4F\x75\x74\x64\x65\x6E\x74","\x49\x6E\x64\x65\x6E\x74","\x43\x61\x6E\x63\x65\x6C","\x49\x6E\x73\x65\x72\x74","\x53\x61\x76\x65","\x44\x65\x6C\x65\x74\x65","\x49\x6E\x73\x65\x72\x74\x20\x54\x61\x62\x6C\x65","\x41\x64\x64\x20\x52\x6F\x77\x20\x41\x62\x6F\x76\x65","\x41\x64\x64\x20\x52\x6F\x77\x20\x42\x65\x6C\x6F\x77","\x41\x64\x64\x20\x43\x6F\x6C\x75\x6D\x6E\x20\x4C\x65\x66\x74","\x41\x64\x64\x20\x43\x6F\x6C\x75\x6D\x6E\x20\x52\x69\x67\x68\x74","\x44\x65\x6C\x65\x74\x65\x20\x43\x6F\x6C\x75\x6D\x6E","\x44\x65\x6C\x65\x74\x65\x20\x52\x6F\x77","\x44\x65\x6C\x65\x74\x65\x20\x54\x61\x62\x6C\x65","\x52\x6F\x77\x73","\x43\x6F\x6C\x75\x6D\x6E\x73","\x41\x64\x64\x20\x48\x65\x61\x64","\x44\x65\x6C\x65\x74\x65\x20\x48\x65\x61\x64","\x54\x69\x74\x6C\x65","\x50\x6F\x73\x69\x74\x69\x6F\x6E","\x4E\x6F\x6E\x65","\x4C\x65\x66\x74","\x52\x69\x67\x68\x74","\x43\x65\x6E\x74\x65\x72","\x49\x6D\x61\x67\x65\x20\x57\x65\x62\x20\x4C\x69\x6E\x6B","\x54\x65\x78\x74","\x45\x6D\x61\x69\x6C","\x55\x52\x4C","\x56\x69\x64\x65\x6F\x20\x45\x6D\x62\x65\x64\x20\x43\x6F\x64\x65","\x49\x6E\x73\x65\x72\x74\x20\x46\x69\x6C\x65","\x55\x70\x6C\x6F\x61\x64","\x44\x6F\x77\x6E\x6C\x6F\x61\x64","\x43\x68\x6F\x6F\x73\x65","\x4F\x72\x20\x63\x68\x6F\x6F\x73\x65","\x44\x72\x6F\x70\x20\x66\x69\x6C\x65\x20\x68\x65\x72\x65","\x41\x6C\x69\x67\x6E\x20\x74\x65\x78\x74\x20\x74\x6F\x20\x74\x68\x65\x20\x6C\x65\x66\x74","\x43\x65\x6E\x74\x65\x72\x20\x74\x65\x78\x74","\x41\x6C\x69\x67\x6E\x20\x74\x65\x78\x74\x20\x74\x6F\x20\x74\x68\x65\x20\x72\x69\x67\x68\x74","\x4A\x75\x73\x74\x69\x66\x79\x20\x74\x65\x78\x74","\x49\x6E\x73\x65\x72\x74\x20\x48\x6F\x72\x69\x7A\x6F\x6E\x74\x61\x6C\x20\x52\x75\x6C\x65","\x44\x65\x6C\x65\x74\x65\x64","\x41\x6E\x63\x68\x6F\x72","\x4F\x70\x65\x6E\x20\x6C\x69\x6E\x6B\x20\x69\x6E\x20\x6E\x65\x77\x20\x74\x61\x62","\x55\x6E\x64\x65\x72\x6C\x69\x6E\x65","\x41\x6C\x69\x67\x6E\x6D\x65\x6E\x74","\x4E\x61\x6D\x65\x20\x28\x6F\x70\x74\x69\x6F\x6E\x61\x6C\x29","\x45\x64\x69\x74","\x72\x74\x65\x50\x61\x73\x74\x65","\x24\x65\x6C\x65\x6D\x65\x6E\x74","\x24\x73\x6F\x75\x72\x63\x65","\x75\x75\x69\x64","\x65\x78\x74\x65\x6E\x64","\x73\x74\x61\x72\x74","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x73","\x73\x6F\x75\x72\x63\x65\x48\x65\x69\x67\x68\x74","\x68\x65\x69\x67\x68\x74","\x63\x73\x73","\x73\x6F\x75\x72\x63\x65\x57\x69\x64\x74\x68","\x77\x69\x64\x74\x68","\x66\x75\x6C\x6C\x70\x61\x67\x65","\x69\x66\x72\x61\x6D\x65","\x6C\x69\x6E\x65\x62\x72\x65\x61\x6B\x73","\x70\x61\x72\x61\x67\x72\x61\x70\x68\x79","\x74\x6F\x6F\x6C\x62\x61\x72\x46\x69\x78\x65\x64\x42\x6F\x78","\x74\x6F\x6F\x6C\x62\x61\x72\x46\x69\x78\x65\x64","\x64\x6F\x63\x75\x6D\x65\x6E\x74","\x77\x69\x6E\x64\x6F\x77","\x73\x61\x76\x65\x64\x53\x65\x6C","\x63\x6C\x65\x61\x6E\x6C\x69\x6E\x65\x42\x65\x66\x6F\x72\x65","\x5E\x3C\x28\x2F\x3F","\x7C\x2F\x3F","\x6A\x6F\x69\x6E","\x6F\x77\x6E\x4C\x69\x6E\x65","\x63\x6F\x6E\x74\x4F\x77\x6E\x4C\x69\x6E\x65","\x29\x5B\x20\x3E\x5D","\x63\x6C\x65\x61\x6E\x6C\x69\x6E\x65\x41\x66\x74\x65\x72","\x5E\x3C\x28\x62\x72\x7C\x2F\x3F","\x7C\x2F","\x63\x6C\x65\x61\x6E\x6E\x65\x77\x4C\x65\x76\x65\x6C","\x5E\x3C\x2F\x3F\x28","\x6E\x65\x77\x4C\x65\x76\x65\x6C","\x72\x54\x65\x73\x74\x42\x6C\x6F\x63\x6B","\x5E\x28","\x62\x6C\x6F\x63\x6B\x4C\x65\x76\x65\x6C\x45\x6C\x65\x6D\x65\x6E\x74\x73","\x29\x24","\x69","\x61\x6C\x6C\x6F\x77\x65\x64\x54\x61\x67\x73","\x64\x65\x6C","\x62","\x73\x74\x72\x69\x6B\x65","\x69\x6E\x41\x72\x72\x61\x79","\x2D\x31","\x64\x65\x6E\x69\x65\x64\x54\x61\x67\x73","\x73\x70\x6C\x69\x63\x65","\x6D\x73\x69\x65","\x62\x72\x6F\x77\x73\x65\x72","\x6F\x70\x65\x72\x61","\x62\x75\x74\x74\x6F\x6E\x73","\x72\x65\x6D\x6F\x76\x65\x46\x72\x6F\x6D\x41\x72\x72\x61\x79\x42\x79\x56\x61\x6C\x75\x65","\x63\x75\x72\x4C\x61\x6E\x67","\x6C\x61\x6E\x67","\x6C\x61\x6E\x67\x73","\x62\x75\x69\x6C\x64\x53\x74\x61\x72\x74","\x74\x6F\x67\x67\x6C\x65","\x73\x68\x6F\x77","\x70\x61\x72\x61\x67\x72\x61\x70\x68","\x66\x6F\x72\x6D\x61\x74\x42\x6C\x6F\x63\x6B\x73","\x71\x75\x6F\x74\x65","\x66\x6F\x72\x6D\x61\x74\x51\x75\x6F\x74\x65","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65","\x63\x6F\x64\x65","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x70\x72\x65","\x68\x65\x61\x64\x65\x72\x31","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x68\x31","\x68\x65\x61\x64\x65\x72\x32","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x68\x32","\x68\x65\x61\x64\x65\x72\x33","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x68\x33","\x68\x65\x61\x64\x65\x72\x34","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x68\x34","\x68\x65\x61\x64\x65\x72\x35","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x61\x74\x5F\x68\x35","\x73\x74\x72\x69\x6B\x65\x74\x68\x72\x6F\x75\x67\x68","\x26\x62\x75\x6C\x6C\x3B\x20","\x69\x6E\x73\x65\x72\x74\x75\x6E\x6F\x72\x64\x65\x72\x65\x64\x6C\x69\x73\x74","\x31\x2E\x20","\x69\x6E\x73\x65\x72\x74\x6F\x72\x64\x65\x72\x65\x64\x6C\x69\x73\x74","\x3C\x20","\x69\x6E\x64\x65\x6E\x74\x69\x6E\x67\x4F\x75\x74\x64\x65\x6E\x74","\x3E\x20","\x69\x6E\x64\x65\x6E\x74\x69\x6E\x67\x49\x6E\x64\x65\x6E\x74","\x69\x6D\x61\x67\x65\x53\x68\x6F\x77","\x76\x69\x64\x65\x6F\x53\x68\x6F\x77","\x66\x69\x6C\x65\x53\x68\x6F\x77","\x69\x6E\x73\x65\x72\x74\x5F\x74\x61\x62\x6C\x65","\x74\x61\x62\x6C\x65\x53\x68\x6F\x77","\x73\x65\x70\x61\x72\x61\x74\x6F\x72","\x69\x6E\x73\x65\x72\x74\x5F\x72\x6F\x77\x5F\x61\x62\x6F\x76\x65","\x74\x61\x62\x6C\x65\x41\x64\x64\x52\x6F\x77\x41\x62\x6F\x76\x65","\x69\x6E\x73\x65\x72\x74\x5F\x72\x6F\x77\x5F\x62\x65\x6C\x6F\x77","\x74\x61\x62\x6C\x65\x41\x64\x64\x52\x6F\x77\x42\x65\x6C\x6F\x77","\x69\x6E\x73\x65\x72\x74\x5F\x63\x6F\x6C\x75\x6D\x6E\x5F\x6C\x65\x66\x74","\x74\x61\x62\x6C\x65\x41\x64\x64\x43\x6F\x6C\x75\x6D\x6E\x4C\x65\x66\x74","\x69\x6E\x73\x65\x72\x74\x5F\x63\x6F\x6C\x75\x6D\x6E\x5F\x72\x69\x67\x68\x74","\x74\x61\x62\x6C\x65\x41\x64\x64\x43\x6F\x6C\x75\x6D\x6E\x52\x69\x67\x68\x74","\x61\x64\x64\x5F\x68\x65\x61\x64","\x74\x61\x62\x6C\x65\x41\x64\x64\x48\x65\x61\x64","\x64\x65\x6C\x65\x74\x65\x5F\x68\x65\x61\x64","\x74\x61\x62\x6C\x65\x44\x65\x6C\x65\x74\x65\x48\x65\x61\x64","\x64\x65\x6C\x65\x74\x65\x5F\x63\x6F\x6C\x75\x6D\x6E","\x74\x61\x62\x6C\x65\x44\x65\x6C\x65\x74\x65\x43\x6F\x6C\x75\x6D\x6E","\x64\x65\x6C\x65\x74\x65\x5F\x72\x6F\x77","\x74\x61\x62\x6C\x65\x44\x65\x6C\x65\x74\x65\x52\x6F\x77","\x64\x65\x6C\x65\x74\x65\x5F\x74\x61\x62\x6C\x65","\x74\x61\x62\x6C\x65\x44\x65\x6C\x65\x74\x65\x54\x61\x62\x6C\x65","\x6C\x69\x6E\x6B\x5F\x69\x6E\x73\x65\x72\x74","\x6C\x69\x6E\x6B\x53\x68\x6F\x77","\x75\x6E\x6C\x69\x6E\x6B","\x61\x6C\x69\x67\x6E\x5F\x6C\x65\x66\x74","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x4C\x65\x66\x74","\x61\x6C\x69\x67\x6E\x5F\x63\x65\x6E\x74\x65\x72","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x43\x65\x6E\x74\x65\x72","\x61\x6C\x69\x67\x6E\x5F\x72\x69\x67\x68\x74","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x52\x69\x67\x68\x74","\x61\x6C\x69\x67\x6E\x5F\x6A\x75\x73\x74\x69\x66\x79","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x4A\x75\x73\x74\x69\x66\x79","\x69\x6E\x73\x65\x72\x74\x68\x6F\x72\x69\x7A\x6F\x6E\x74\x61\x6C\x72\x75\x6C\x65","\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x61\x75\x74\x6F\x73\x61\x76\x65\x49\x6E\x74\x65\x72\x76\x61\x6C","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x6F\x66\x66","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x65\x78\x74\x61\x72\x65\x61","\x72\x65\x6D\x6F\x76\x65\x44\x61\x74\x61","\x67\x65\x74","\x74\x65\x78\x74\x61\x72\x65\x61\x6D\x6F\x64\x65","\x61\x66\x74\x65\x72","\x24\x62\x6F\x78","\x72\x65\x6D\x6F\x76\x65","\x76\x61\x6C","\x24\x65\x64\x69\x74\x6F\x72","\x63\x6F\x6E\x74\x65\x6E\x74\x65\x64\x69\x74\x61\x62\x6C\x65","\x72\x65\x6D\x6F\x76\x65\x41\x74\x74\x72","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x65\x64\x69\x74\x6F\x72\x5F\x77\x79\x6D","\x72\x65\x6D\x6F\x76\x65\x43\x6C\x61\x73\x73","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x65\x64\x69\x74\x6F\x72","\x74\x6F\x6F\x6C\x62\x61\x72\x45\x78\x74\x65\x72\x6E\x61\x6C","\x61\x69\x72","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x61\x69\x72\x5F","\x24\x66\x72\x61\x6D\x65","\x24\x74\x6F\x6F\x6C\x62\x61\x72","\x64\x69\x72","\x63\x68\x69\x6C\x64\x72\x65\x6E","\x63\x6F\x6E\x74\x65\x6E\x74\x73","\x6F\x75\x74\x65\x72\x48\x74\x6D\x6C","\x64\x69\x72\x65\x63\x74\x69\x6F\x6E","\x61\x74\x74\x72","\x26\x23\x33\x36\x3B","\x72\x65\x70\x6C\x61\x63\x65","\x73\x65\x74\x43\x6F\x64\x65\x49\x66\x72\x61\x6D\x65","\x73\x65\x74\x45\x64\x69\x74\x6F\x72","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x52\x65\x6D\x6F\x76\x65\x46\x72\x6F\x6D\x45\x64\x69\x74\x6F\x72","\x63\x6C\x65\x61\x6E\x53\x61\x76\x65\x50\x72\x65\x43\x6F\x64\x65","\x63\x6C\x65\x61\x6E\x53\x74\x72\x69\x70\x54\x61\x67\x73","\x63\x6C\x65\x61\x6E\x43\x6F\x6E\x76\x65\x72\x74\x50\x72\x6F\x74\x65\x63\x74\x65\x64","\x63\x6C\x65\x61\x6E\x43\x6F\x6E\x76\x65\x72\x74\x49\x6E\x6C\x69\x6E\x65\x54\x61\x67\x73","\x63\x6C\x65\x61\x6E\x43\x6F\x6E\x76\x65\x72\x74\x65\x72\x73","\x24\x32\x3C\x62\x72\x3E","\x24","\x63\x6C\x65\x61\x6E\x45\x6D\x70\x74\x79","\x73\x65\x74\x4E\x6F\x6E\x45\x64\x69\x74\x61\x62\x6C\x65","\x73\x65\x74\x53\x70\x61\x6E\x73\x56\x65\x72\x69\x66\x69\x65\x64","\x73\x79\x6E\x63","\x69\x66\x72\x61\x6D\x65\x50\x61\x67\x65","\x73\x72\x63","\x61\x62\x6F\x75\x74\x3A\x62\x6C\x61\x6E\x6B","\x63\x6C\x65\x61\x6E\x52\x65\x6D\x6F\x76\x65\x53\x70\x61\x63\x65\x73","\x6F\x70\x65\x6E","\x77\x72\x69\x74\x65","\x63\x6C\x6F\x73\x65","\x66\x69\x6E\x64","\x73\x70\x61\x6E","\x69\x6E\x6C\x69\x6E\x65","\x6F\x75\x74\x65\x72\x48\x54\x4D\x4C","\x3C","\x74\x61\x67\x4E\x61\x6D\x65","\x67\x69","\x3C\x2F","\x72\x65\x70\x6C\x61\x63\x65\x57\x69\x74\x68","\x3C\x69\x6E\x6C\x69\x6E\x65\x24\x31\x3E","\x3C\x2F\x69\x6E\x6C\x69\x6E\x65\x3E","\x2E\x6E\x6F\x6E\x65\x64\x69\x74\x61\x62\x6C\x65","\x63\x6C\x65\x61\x6E\x55\x6E\x76\x65\x72\x69\x66\x69\x65\x64","\x67\x65\x74\x43\x6F\x64\x65\x49\x66\x72\x61\x6D\x65","\x73\x79\x6E\x63\x43\x6C\x65\x61\x6E","\x63\x6C\x65\x61\x6E\x52\x65\x6D\x6F\x76\x65\x45\x6D\x70\x74\x79\x54\x61\x67\x73","\x3C\x24\x31\x3E\x24\x32\x3C\x2F\x24\x31\x3E\x3C\x2F\x6C\x69\x3E","\x74\x72\x69\x6D","\x3C\x62\x72\x3E","\x78\x68\x74\x6D\x6C","\x62\x72","\x69\x6D\x67","\x69\x6E\x70\x75\x74","\x28\x2E\x2A\x3F\x5B\x5E\x2F\x24\x5D\x3F\x29\x3E","\x24\x31\x20\x2F\x3E","\x73\x79\x6E\x63\x42\x65\x66\x6F\x72\x65","\x63\x61\x6C\x6C\x62\x61\x63\x6B","\x73\x79\x6E\x63\x41\x66\x74\x65\x72","\x63\x68\x61\x6E\x67\x65","\x77\x68\x69\x63\x68","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x52\x65\x6D\x6F\x76\x65\x46\x72\x6F\x6D\x43\x6F\x64\x65","\x3C\x2F\x61\x3E\x20","\x3C\x70\x3E\x3C\x2F\x70\x3E","\x3C\x70\x3E\x20\x3C\x2F\x70\x3E","\x3C\x70\x3E\x26\x6E\x62\x73\x70\x3B\x3C\x2F\x70\x3E","\x6C\x69\x6E\x6B\x4E\x6F\x66\x6F\x6C\x6C\x6F\x77","\x3C\x61\x24\x31\x24\x32\x3E","\x3C\x61\x24\x31\x20\x72\x65\x6C\x3D\x22\x6E\x6F\x66\x6F\x6C\x6C\x6F\x77\x22\x3E","\x3C\x21\x2D\x2D\x3F\x70\x68\x70","\x3C\x3F\x70\x68\x70","\x3F\x2D\x2D\x3E","\x3F\x3E","\x3C\x24\x31\x63\x6C\x61\x73\x73\x3D\x22\x6E\x6F\x65\x64\x69\x74\x61\x62\x6C\x65\x22\x24\x32\x24\x33\x3E","\x3C\x2F\x24\x31\x3E","\x24\x33\x3C\x69\x6D\x67\x24\x34\x3E","\x63\x6C\x65\x61\x6E\x46\x6F\x6E\x74\x54\x61\x67","\x24\x32","\x3C\x73\x70\x61\x6E\x3E","\x3C\x73\x70\x61\x6E\x20","\x3C\x2F\x73\x70\x61\x6E\x3E","\x24\x31","\x26","\x26\x74\x72\x61\x64\x65\x3B","\x26\x63\x6F\x70\x79\x3B","\x26\x68\x65\x6C\x6C\x69\x70\x3B","\x26\x6D\x64\x61\x73\x68\x3B","\x26\x64\x61\x73\x68\x3B","\x63\x6C\x65\x61\x6E\x52\x65\x43\x6F\x6E\x76\x65\x72\x74\x50\x72\x6F\x74\x65\x63\x74\x65\x64","\x63\x6F\x6E\x74\x65\x6E\x74","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x6F\x78\x22\x20\x2F\x3E","\x7A\x2D\x69\x6E\x64\x65\x78","\x54\x45\x58\x54\x41\x52\x45\x41","\x6D\x6F\x62\x69\x6C\x65","\x69\x73\x4D\x6F\x62\x69\x6C\x65","\x62\x75\x69\x6C\x64\x4D\x6F\x62\x69\x6C\x65","\x62\x75\x69\x6C\x64\x43\x6F\x6E\x74\x65\x6E\x74","\x61\x75\x74\x6F\x72\x65\x73\x69\x7A\x65","\x69\x66\x72\x61\x6D\x65\x53\x74\x61\x72\x74","\x62\x75\x69\x6C\x64\x46\x72\x6F\x6D\x54\x65\x78\x74\x61\x72\x65\x61","\x62\x75\x69\x6C\x64\x46\x72\x6F\x6D\x45\x6C\x65\x6D\x65\x6E\x74","\x62\x75\x69\x6C\x64\x4F\x70\x74\x69\x6F\x6E\x73","\x62\x75\x69\x6C\x64\x41\x66\x74\x65\x72","\x68\x69\x64\x65","\x62\x75\x69\x6C\x64\x43\x6F\x64\x65\x61\x72\x65\x61","\x61\x70\x70\x65\x6E\x64","\x69\x6E\x73\x65\x72\x74\x41\x66\x74\x65\x72","\x3C\x64\x69\x76\x20\x2F\x3E","\x62\x75\x69\x6C\x64\x41\x64\x64\x43\x6C\x61\x73\x73\x65\x73","\x62\x75\x69\x6C\x64\x45\x6E\x61\x62\x6C\x65","\x6E\x61\x6D\x65","\x69\x64","\x3C\x74\x65\x78\x74\x61\x72\x65\x61\x20\x2F\x3E","\x73\x70\x6C\x69\x74","\x63\x6C\x61\x73\x73\x4E\x61\x6D\x65","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F","\x61\x64\x64\x43\x6C\x61\x73\x73","\x73\x65\x74","\x74\x61\x62\x69\x6E\x64\x65\x78","\x6D\x69\x6E\x48\x65\x69\x67\x68\x74","\x6D\x69\x6E\x2D\x68\x65\x69\x67\x68\x74","\x70\x78","\x6D\x6F\x7A\x69\x6C\x6C\x61","\x34\x35\x70\x78","\x70\x61\x64\x64\x69\x6E\x67\x2D\x62\x6F\x74\x74\x6F\x6D","\x6D\x61\x78\x48\x65\x69\x67\x68\x74","\x77\x79\x6D","\x74\x79\x70\x65\x77\x72\x69\x74\x65\x72","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x65\x64\x69\x74\x6F\x72\x2D\x74\x79\x70\x65\x77\x72\x69\x74\x65\x72","\x74\x6F\x6F\x6C\x62\x61\x72","\x74\x6F\x6F\x6C\x62\x61\x72\x49\x6E\x69\x74","\x74\x6F\x6F\x6C\x62\x61\x72\x42\x75\x69\x6C\x64","\x6D\x6F\x64\x61\x6C\x54\x65\x6D\x70\x6C\x61\x74\x65\x73\x49\x6E\x69\x74","\x62\x75\x69\x6C\x64\x50\x6C\x75\x67\x69\x6E\x73","\x62\x75\x69\x6C\x64\x42\x69\x6E\x64\x4B\x65\x79\x62\x6F\x61\x72\x64","\x61\x75\x74\x6F\x73\x61\x76\x65","\x6F\x62\x73\x65\x72\x76\x65\x53\x74\x61\x72\x74","\x70\x72\x6F\x78\x79","\x65\x6E\x61\x62\x6C\x65\x4F\x62\x6A\x65\x63\x74\x52\x65\x73\x69\x7A\x69\x6E\x67","\x65\x78\x65\x63\x43\x6F\x6D\x6D\x61\x6E\x64","\x65\x6E\x61\x62\x6C\x65\x49\x6E\x6C\x69\x6E\x65\x54\x61\x62\x6C\x65\x45\x64\x69\x74\x69\x6E\x67","\x66\x6F\x63\x75\x73","\x76\x69\x73\x75\x61\x6C","\x64\x62\x6C\x45\x6E\x74\x65\x72","\x64\x72\x61\x67\x55\x70\x6C\x6F\x61\x64","\x69\x6D\x61\x67\x65\x55\x70\x6C\x6F\x61\x64","\x64\x72\x6F\x70\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x44\x72\x6F\x70","\x6F\x6E","\x69\x6E\x70\x75\x74\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x70\x61\x73\x74\x65\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x50\x61\x73\x74\x65","\x6B\x65\x79\x64\x6F\x77\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x64\x6F\x77\x6E","\x6B\x65\x79\x75\x70\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x75\x70","\x74\x65\x78\x74\x61\x72\x65\x61\x4B\x65\x79\x64\x6F\x77\x6E\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x6B\x65\x79\x64\x6F\x77\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x65\x78\x74\x61\x72\x65\x61","\x66\x6F\x63\x75\x73\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x66\x6F\x63\x75\x73\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x74\x61\x72\x67\x65\x74","\x6D\x6F\x75\x73\x65\x64\x6F\x77\x6E","\x62\x6C\x75\x72\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x6F\x6F\x6C\x62\x61\x72","\x68\x61\x73\x43\x6C\x61\x73\x73","\x73\x69\x7A\x65","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x6F\x6F\x6C\x62\x61\x72","\x70\x61\x72\x65\x6E\x74\x73","\x73\x65\x6C\x65\x63\x74\x61\x6C\x6C","\x62\x6C\x75\x72\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x62\x6C\x75\x72","\x6F\x72\x69\x67\x69\x6E\x61\x6C\x45\x76\x65\x6E\x74","\x46\x6F\x72\x6D\x44\x61\x74\x61","\x64\x61\x74\x61\x54\x72\x61\x6E\x73\x66\x65\x72","\x66\x69\x6C\x65\x73","\x70\x72\x65\x76\x65\x6E\x74\x44\x65\x66\x61\x75\x6C\x74","\x64\x6E\x62\x49\x6D\x61\x67\x65\x54\x79\x70\x65\x73","\x74\x79\x70\x65","\x69\x6E\x64\x65\x78\x4F\x66","\x62\x75\x66\x66\x65\x72\x53\x65\x74","\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x22\x3E\x3C\x73\x70\x61\x6E\x3E\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x2F\x64\x69\x76\x3E","\x73\x33","\x69\x6D\x61\x67\x65\x55\x70\x6C\x6F\x61\x64\x50\x61\x72\x61\x6D","\x64\x72\x61\x67\x55\x70\x6C\x6F\x61\x64\x41\x6A\x61\x78","\x73\x33\x75\x70\x6C\x6F\x61\x64\x46\x69\x6C\x65","\x77\x65\x62\x6B\x69\x74","\x43\x68\x72\x6F\x6D\x65","\x75\x73\x65\x72\x41\x67\x65\x6E\x74","\x2E","\x76\x65\x72\x73\x69\x6F\x6E","\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x55\x70\x6C\x6F\x61\x64","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x43\x6C\x69\x70\x62\x6F\x61\x72\x64\x55\x70\x6C\x6F\x61\x64","\x63\x6C\x65\x61\x6E\x75\x70","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x53\x61\x76\x65","\x66\x75\x6C\x6C\x73\x63\x72\x65\x65\x6E","\x73\x61\x76\x65\x53\x63\x72\x6F\x6C\x6C","\x73\x63\x72\x6F\x6C\x6C\x54\x6F\x70","\x65\x78\x74\x72\x61\x63\x74\x43\x6F\x6E\x74\x65\x6E\x74","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x52\x65\x73\x74\x6F\x72\x65","\x67\x65\x74\x46\x72\x61\x67\x6D\x65\x6E\x74\x48\x74\x6D\x6C","\x70\x61\x73\x74\x65\x43\x6C\x65\x61\x6E","\x61\x75\x74\x6F","\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x46\x69\x6C\x65\x50\x61\x73\x74\x65","\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x44\x61\x74\x61","\x69\x74\x65\x6D\x73","\x67\x65\x74\x41\x73\x46\x69\x6C\x65","\x6F\x6E\x6C\x6F\x61\x64","\x70\x61\x73\x74\x65\x43\x6C\x69\x70\x62\x6F\x61\x72\x64\x55\x70\x6C\x6F\x61\x64","\x72\x65\x61\x64\x41\x73\x44\x61\x74\x61\x55\x52\x4C","\x63\x74\x72\x6C\x4B\x65\x79","\x6D\x65\x74\x61\x4B\x65\x79","\x67\x65\x74\x50\x61\x72\x65\x6E\x74","\x67\x65\x74\x43\x75\x72\x72\x65\x6E\x74","\x67\x65\x74\x42\x6C\x6F\x63\x6B","\x6B\x65\x79\x64\x6F\x77\x6E","\x69\x6D\x61\x67\x65\x52\x65\x73\x69\x7A\x65\x48\x69\x64\x65","\x44\x4F\x57\x4E","\x6B\x65\x79\x43\x6F\x64\x65","\x69\x6E\x73\x65\x72\x74\x41\x66\x74\x65\x72\x4C\x61\x73\x74\x45\x6C\x65\x6D\x65\x6E\x74","\x70\x61\x72\x65\x6E\x74","\x73\x68\x69\x66\x74\x4B\x65\x79","\x73\x68\x6F\x72\x74\x63\x75\x74\x73","\x61\x6C\x74\x4B\x65\x79","\x62\x75\x66\x66\x65\x72","\x62\x75\x66\x66\x65\x72\x55\x6E\x64\x6F","\x75\x6E\x64\x6F","\x72\x65\x62\x75\x66\x66\x65\x72","\x62\x75\x66\x66\x65\x72\x52\x65\x64\x6F","\x72\x65\x64\x6F","\x4C\x45\x46\x54\x5F\x57\x49\x4E","\x45\x4E\x54\x45\x52","\x67\x65\x74\x52\x61\x6E\x67\x65","\x63\x6F\x6C\x6C\x61\x70\x73\x65\x64","\x67\x65\x74\x53\x65\x6C\x65\x63\x74\x69\x6F\x6E","\x72\x61\x6E\x67\x65\x43\x6F\x75\x6E\x74","\x64\x65\x6C\x65\x74\x65\x43\x6F\x6E\x74\x65\x6E\x74\x73","\x6E\x6F\x64\x65\x54\x79\x70\x65","\x54\x48","\x63\x72\x65\x61\x74\x65\x45\x6C\x65\x6D\x65\x6E\x74","\x69\x6E\x73\x65\x72\x74\x4E\x6F\x64\x65","\x65\x6E\x74\x65\x72","\x69\x73\x45\x6E\x64\x4F\x66\x45\x6C\x65\x6D\x65\x6E\x74","\x69\x6E\x73\x65\x72\x74\x69\x6E\x67\x41\x66\x74\x65\x72\x4C\x61\x73\x74\x45\x6C\x65\x6D\x65\x6E\x74","\x6C\x61\x73\x74","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x64\x6F\x77\x6E\x50\x72\x65","\x74\x65\x73\x74","\x72\x42\x6C\x6F\x63\x6B\x54\x65\x73\x74","\x3C\x70\x3E","\x69\x6E\x76\x69\x73\x69\x62\x6C\x65\x53\x70\x61\x63\x65","\x3C\x2F\x70\x3E","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x53\x74\x61\x72\x74","\x72\x65\x70\x6C\x61\x63\x65\x4C\x69\x6E\x65\x42\x72\x65\x61\x6B","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x64\x6F\x77\x6E\x49\x6E\x73\x65\x72\x74\x4C\x69\x6E\x65\x42\x72\x65\x61\x6B","\x69\x6E\x73\x65\x72\x74\x4C\x69\x6E\x65\x42\x72\x65\x61\x6B","\x54\x41\x42","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x64\x6F\x77\x6E\x54\x61\x62","\x42\x41\x43\x4B\x53\x50\x41\x43\x45","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x64\x6F\x77\x6E\x42\x61\x63\x6B\x73\x70\x61\x63\x65","\x74\x65\x78\x74","\x0A","\x63\x72\x65\x61\x74\x65\x54\x65\x78\x74\x4E\x6F\x64\x65","\x73\x65\x61\x72\x63\x68","\x74\x61\x62\x46\x6F\x63\x75\x73","\x69\x73\x45\x6D\x70\x74\x79","\x74\x61\x62\x53\x70\x61\x63\x65\x73","\x09","\xA0","\x6E\x6F\x64\x65\x56\x61\x6C\x75\x65","\x6D\x61\x74\x63\x68","\x42\x4F\x44\x59","\x63\x6C\x6F\x6E\x65","\x6E\x65\x78\x74","\x42\x52","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x45\x6E\x64","\x63\x6F\x6E\x76\x65\x72\x74\x4C\x69\x6E\x6B\x73","\x63\x6F\x6E\x76\x65\x72\x74\x49\x6D\x61\x67\x65\x4C\x69\x6E\x6B\x73","\x63\x6F\x6E\x76\x65\x72\x74\x56\x69\x64\x65\x6F\x4C\x69\x6E\x6B\x73","\x62\x75\x69\x6C\x64\x45\x76\x65\x6E\x74\x4B\x65\x79\x75\x70\x43\x6F\x6E\x76\x65\x72\x74\x65\x72\x73","\x44\x45\x4C\x45\x54\x45","\x66\x6F\x72\x6D\x61\x74\x45\x6D\x70\x74\x79","\x6B\x65\x79\x75\x70","\x6C\x69\x6E\x6B\x50\x72\x6F\x74\x6F\x63\x6F\x6C","\x6C\x69\x6E\x6B\x53\x69\x7A\x65","\x66\x6F\x72\x6D\x61\x74\x4C\x69\x6E\x6B\x69\x66\x79","\x6F\x62\x73\x65\x72\x76\x65\x49\x6D\x61\x67\x65\x73","\x6F\x62\x73\x65\x72\x76\x65\x4C\x69\x6E\x6B\x73","\x70\x6C\x75\x67\x69\x6E\x73","\x69\x66\x72\x61\x6D\x65\x43\x72\x65\x61\x74\x65","\x69\x66\x72\x61\x6D\x65\x41\x70\x70\x65\x6E\x64","\x24\x73\x6F\x75\x72\x63\x65\x4F\x6C\x64","\x6C\x6F\x61\x64","\x69\x66\x72\x61\x6D\x65\x4C\x6F\x61\x64","\x6F\x6E\x65","\x3C\x69\x66\x72\x61\x6D\x65\x20\x73\x74\x79\x6C\x65\x3D\x22\x77\x69\x64\x74\x68\x3A\x20\x31\x30\x30\x25\x3B\x22\x20\x66\x72\x61\x6D\x65\x62\x6F\x72\x64\x65\x72\x3D\x22\x30\x22\x20\x2F\x3E","\x63\x6F\x6E\x74\x65\x6E\x74\x57\x69\x6E\x64\x6F\x77","\x69\x66\x72\x61\x6D\x65\x44\x6F\x63","\x64\x6F\x63\x75\x6D\x65\x6E\x74\x45\x6C\x65\x6D\x65\x6E\x74","\x72\x65\x6D\x6F\x76\x65\x43\x68\x69\x6C\x64","\x69\x73\x53\x74\x72\x69\x6E\x67","\x3C\x6C\x69\x6E\x6B\x20\x72\x65\x6C\x3D\x22\x73\x74\x79\x6C\x65\x73\x68\x65\x65\x74\x22\x20\x68\x72\x65\x66\x3D\x22","\x22\x20\x2F\x3E","\x69\x73\x41\x72\x72\x61\x79","\x69\x66\x72\x61\x6D\x65\x41\x64\x64\x43\x73\x73","\x6F\x77\x6E\x65\x72\x44\x6F\x63\x75\x6D\x65\x6E\x74","\x64\x65\x66\x61\x75\x6C\x74\x56\x69\x65\x77","\x73\x65\x74\x46\x75\x6C\x6C\x70\x61\x67\x65\x4F\x6E\x49\x6E\x69\x74","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x4F\x6E\x46\x6F\x63\x75\x73","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x4F\x6E\x42\x6C\x75\x72","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x47\x65\x74","\x66\x6F\x63\x75\x73\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x46\x6F\x63\x75\x73","\x62\x6C\x75\x72\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x42\x6C\x75\x72","\x76\x65\x72\x69\x66\x69\x65\x64","\x3C\x73\x70\x61\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x22\x3E","\x73\x70\x61\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72","\x65\x6D\x70\x74\x79\x48\x74\x6D\x6C","\x72\x65\x6D\x6F\x76\x65\x46\x6F\x72\x6D\x61\x74","\x73\x68\x6F\x72\x74\x63\x75\x74\x73\x4C\x6F\x61\x64","\x73\x75\x70\x65\x72\x73\x63\x72\x69\x70\x74","\x73\x75\x62\x73\x63\x72\x69\x70\x74","\x66\x6F\x63\x75\x73\x53\x65\x74","\x73\x65\x74\x54\x69\x6D\x65\x6F\x75\x74","\x73\x65\x6C\x65\x63\x74\x4E\x6F\x64\x65\x43\x6F\x6E\x74\x65\x6E\x74\x73","\x63\x6F\x6C\x6C\x61\x70\x73\x65","\x72\x65\x6D\x6F\x76\x65\x41\x6C\x6C\x52\x61\x6E\x67\x65\x73","\x61\x64\x64\x52\x61\x6E\x67\x65","\x74\x6F\x67\x67\x6C\x65\x43\x6F\x64\x65","\x74\x6F\x67\x67\x6C\x65\x56\x69\x73\x75\x61\x6C","\x6D\x6F\x64\x69\x66\x69\x65\x64","\x6B\x65\x79\x64\x6F\x77\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x65\x78\x74\x61\x72\x65\x61\x2D\x69\x6E\x64\x65\x6E\x74\x69\x6E\x67","\x62\x75\x74\x74\x6F\x6E\x41\x63\x74\x69\x76\x65\x56\x69\x73\x75\x61\x6C","\x62\x75\x74\x74\x6F\x6E\x49\x6E\x61\x63\x74\x69\x76\x65","\x69\x6E\x6E\x65\x72\x48\x65\x69\x67\x68\x74","\x74\x69\x64\x79\x48\x74\x6D\x6C","\x63\x6C\x65\x61\x6E\x48\x74\x6D\x6C","\x74\x65\x78\x74\x61\x72\x65\x61\x49\x6E\x64\x65\x6E\x74\x69\x6E\x67","\x62\x75\x74\x74\x6F\x6E\x49\x6E\x61\x63\x74\x69\x76\x65\x56\x69\x73\x75\x61\x6C","\x62\x75\x74\x74\x6F\x6E\x41\x63\x74\x69\x76\x65","\x73\x75\x62\x73\x74\x72\x69\x6E\x67","\x70\x6F\x73\x74","\x6E\x61\x6D\x65\x3D","\x3D","\x70\x61\x72\x73\x65\x4A\x53\x4F\x4E","\x61\x75\x74\x6F\x73\x61\x76\x65\x45\x72\x72\x6F\x72","\x61\x6A\x61\x78","\x62\x75\x74\x74\x6F\x6E\x73\x48\x69\x64\x65\x4F\x6E\x4D\x6F\x62\x69\x6C\x65","\x61\x69\x72\x42\x75\x74\x74\x6F\x6E\x73","\x62\x75\x74\x74\x6F\x6E\x53\x6F\x75\x72\x63\x65","\x64\x72\x6F\x70\x64\x6F\x77\x6E","\x66\x6F\x72\x6D\x61\x74\x74\x69\x6E\x67\x54\x61\x67\x73","\x61\x69\x72\x45\x6E\x61\x62\x6C\x65","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x6F\x6F\x6C\x62\x61\x72\x5F","\x3C\x75\x6C\x3E","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x6F\x6F\x6C\x62\x61\x72\x2D\x74\x79\x70\x65\x77\x72\x69\x74\x65\x72","\x74\x6F\x6F\x6C\x62\x61\x72\x4F\x76\x65\x72\x66\x6C\x6F\x77","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x6F\x6F\x6C\x62\x61\x72\x2D\x6F\x76\x65\x72\x66\x6C\x6F\x77","\x24\x61\x69\x72","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x61\x69\x72\x5F","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x61\x69\x72\x22\x3E","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x6F\x6F\x6C\x62\x61\x72\x2D\x65\x78\x74\x65\x72\x6E\x61\x6C","\x70\x72\x65\x70\x65\x6E\x64","\x66\x69\x6C\x65\x55\x70\x6C\x6F\x61\x64","\x62\x75\x74\x74\x6F\x6E\x42\x75\x69\x6C\x64","\x3C\x6C\x69\x3E","\x61","\x74\x6F\x6F\x6C\x62\x61\x72\x4F\x62\x73\x65\x72\x76\x65\x53\x63\x72\x6F\x6C\x6C","\x73\x63\x72\x6F\x6C\x6C\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x74\x6F\x6F\x6C\x62\x61\x72\x46\x69\x78\x65\x64\x54\x61\x72\x67\x65\x74","\x61\x63\x74\x69\x76\x65\x42\x75\x74\x74\x6F\x6E\x73","\x6D\x6F\x75\x73\x65\x75\x70\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x20\x6B\x65\x79\x75\x70\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x62\x75\x74\x74\x6F\x6E\x41\x63\x74\x69\x76\x65\x4F\x62\x73\x65\x72\x76\x65\x72","\x74\x6F\x70","\x6F\x66\x66\x73\x65\x74","\x31\x30\x30\x25","\x6C\x65\x66\x74","\x69\x6E\x6E\x65\x72\x57\x69\x64\x74\x68","\x74\x6F\x6F\x6C\x62\x61\x72\x5F\x66\x69\x78\x65\x64\x5F\x62\x6F\x78","\x66\x69\x78\x65\x64","\x74\x6F\x6F\x6C\x62\x61\x72\x46\x69\x78\x65\x64\x54\x6F\x70\x4F\x66\x66\x73\x65\x74","\x61\x62\x73\x6F\x6C\x75\x74\x65","\x76\x69\x73\x69\x62\x69\x6C\x69\x74\x79","\x76\x69\x73\x69\x62\x6C\x65","\x68\x69\x64\x64\x65\x6E","\x72\x65\x6C\x61\x74\x69\x76\x65","\x67\x65\x74\x53\x65\x6C\x65\x63\x74\x69\x6F\x6E\x54\x65\x78\x74","\x6D\x6F\x75\x73\x65\x75\x70","\x61\x69\x72\x53\x68\x6F\x77","\x66\x6F\x63\x75\x73\x4E\x6F\x64\x65","\x67\x65\x74\x45\x6C\x65\x6D\x65\x6E\x74","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x61\x69\x72","\x70\x6F\x73\x69\x74\x69\x6F\x6E","\x63\x6C\x69\x65\x6E\x74\x58","\x63\x6C\x69\x65\x6E\x74\x59","\x61\x69\x72\x42\x69\x6E\x64\x48\x69\x64\x65","\x45\x53\x43","\x63\x6F\x6C\x6C\x61\x70\x73\x65\x54\x6F\x53\x74\x61\x72\x74","\x66\x61\x64\x65\x4F\x75\x74","\x6D\x6F\x75\x73\x65\x64\x6F\x77\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x63\x6C\x6F\x73\x65\x73\x74","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x52\x65\x6D\x6F\x76\x65","\x6D\x6F\x75\x73\x65\x6D\x6F\x76\x65\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x3C\x61\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x73\x65\x70\x61\x72\x61\x74\x6F\x72\x5F\x64\x72\x6F\x70\x22\x3E","\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x23\x22\x20\x63\x6C\x61\x73\x73\x3D\x22","\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E\x5F","\x22\x3E","\x74\x69\x74\x6C\x65","\x3C\x2F\x61\x3E","\x63\x6C\x69\x63\x6B","\x72\x65\x74\x75\x72\x6E\x56\x61\x6C\x75\x65","\x65\x78\x65\x63","\x66\x75\x6E\x63","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E\x5F\x62\x6F\x78\x5F","\x62\x75\x74\x74\x6F\x6E\x47\x65\x74","\x64\x72\x6F\x70\x61\x63\x74","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x48\x69\x64\x65\x41\x6C\x6C","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x53\x68\x6F\x77","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x53\x68\x6F\x77\x6E","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x48\x69\x64\x65","\x73\x74\x6F\x70\x50\x72\x6F\x70\x61\x67\x61\x74\x69\x6F\x6E","\x66\x6F\x63\x75\x73\x57\x69\x74\x68\x53\x61\x76\x65\x53\x63\x72\x6F\x6C\x6C","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x61\x63\x74","\x61\x2E\x64\x72\x6F\x70\x61\x63\x74","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E","\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x6A\x61\x76\x61\x73\x63\x72\x69\x70\x74\x3A\x3B\x22\x20\x74\x69\x74\x6C\x65\x3D\x22","\x22\x20\x74\x61\x62\x69\x6E\x64\x65\x78\x3D\x22\x2D\x31\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x2D\x69\x63\x6F\x6E\x20\x72\x65\x2D","\x22\x3E\x3C\x2F\x61\x3E","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x62\x74\x6E\x2D\x69\x6D\x61\x67\x65","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x75\x74\x74\x6F\x6E\x5F\x64\x69\x73\x61\x62\x6C\x65\x64","\x69\x73\x46\x6F\x63\x75\x73\x65\x64","\x61\x69\x72\x42\x69\x6E\x64\x4D\x6F\x75\x73\x65\x6D\x6F\x76\x65\x48\x69\x64\x65","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E\x5F\x62\x6F\x78\x5F","\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E","\x61\x70\x70\x65\x6E\x64\x54\x6F","\x64\x72\x6F\x70\x64\x6F\x77\x6E\x42\x75\x69\x6C\x64","\x61\x2E\x72\x65\x2D","\x61\x63\x74\x69\x76\x65\x42\x75\x74\x74\x6F\x6E\x73\x53\x74\x61\x74\x65\x73","\x2E\x72\x65\x2D","\x6E\x6F\x74","\x61\x2E\x72\x65\x2D\x69\x63\x6F\x6E","\x61\x2E\x72\x65\x2D\x68\x74\x6D\x6C","\x72\x65\x2D","\x66\x61\x2D\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x62\x74\x6E","\x3C\x69\x20\x63\x6C\x61\x73\x73\x3D\x22\x66\x61\x20","\x22\x3E\x3C\x2F\x69\x3E","\x62\x65\x66\x6F\x72\x65","\x62\x75\x74\x74\x6F\x6E\x49\x6E\x61\x63\x74\x69\x76\x65\x41\x6C\x6C","\x62\x75\x74\x74\x6F\x6E\x41\x63\x74\x69\x76\x65\x54\x6F\x67\x67\x6C\x65","\x41","\x6C\x69\x6E\x6B\x5F\x65\x64\x69\x74","\x61\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x64\x6F\x77\x6E\x5F\x6C\x69\x6E\x6B","\x74\x6F\x4C\x6F\x77\x65\x72\x43\x61\x73\x65","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x54\x61\x67\x73","\x74\x65\x78\x74\x2D\x61\x6C\x69\x67\x6E","\x72\x69\x67\x68\x74","\x63\x65\x6E\x74\x65\x72","\x61\x6C\x69\x67\x6E\x6A\x75\x73\x74\x69\x66\x79","\x67\x65\x74\x52\x61\x6E\x67\x65\x41\x74","\x69\x6E\x6E\x65\x72\x48\x54\x4D\x4C","\x63\x72\x65\x61\x74\x65\x44\x6F\x63\x75\x6D\x65\x6E\x74\x46\x72\x61\x67\x6D\x65\x6E\x74","\x61\x70\x70\x65\x6E\x64\x43\x68\x69\x6C\x64","\x66\x69\x72\x73\x74\x43\x68\x69\x6C\x64","\x63\x6C\x6F\x6E\x65\x52\x61\x6E\x67\x65","\x73\x65\x74\x53\x74\x61\x72\x74\x41\x66\x74\x65\x72","\x66\x6F\x72\x6D\x61\x74\x62\x6C\x6F\x63\x6B","\x3E","\x69\x6E\x73\x65\x72\x74\x68\x74\x6D\x6C","\x69\x73\x49\x65\x31\x31","\x70\x61\x73\x74\x65\x48\x54\x4D\x4C","\x63\x72\x65\x61\x74\x65\x52\x61\x6E\x67\x65","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E","\x65\x78\x65\x63\x50\x61\x73\x74\x65\x46\x72\x61\x67","\x53\x55\x50","\x53\x55\x42","\x69\x6E\x6C\x69\x6E\x65\x52\x65\x6D\x6F\x76\x65\x46\x6F\x72\x6D\x61\x74\x52\x65\x70\x6C\x61\x63\x65","\x69\x6E\x73\x65\x72\x74\x48\x74\x6D\x6C","\x63\x75\x72\x72\x65\x6E\x74\x4F\x72\x50\x61\x72\x65\x6E\x74\x49\x73","\x66\x6F\x72\x6D\x61\x74\x74\x69\x6E\x67\x50\x72\x65","\x65\x78\x65\x63\x4C\x69\x73\x74\x73","\x65\x78\x65\x63\x55\x6E\x6C\x69\x6E\x6B","\x6F\x6C\x2C\x20\x75\x6C","\x69\x73\x50\x61\x72\x65\x6E\x74\x52\x65\x64\x61\x63\x74\x6F\x72","\x4F\x4C","\x55\x4C","\x67\x65\x74\x4E\x6F\x64\x65\x73","\x67\x65\x74\x42\x6C\x6F\x63\x6B\x73","\x75\x6E\x73\x68\x69\x66\x74","\x65\x6D\x70\x74\x79","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x72\x65\x70\x6C\x61\x63\x65\x64","\x3A\x65\x6D\x70\x74\x79","\x3C\x74\x64\x3E","\x77\x72\x61\x70\x41\x6C\x6C","\x6E\x6F\x64\x65\x54\x65\x73\x74\x42\x6C\x6F\x63\x6B\x73","\x69\x6E\x64\x65\x6E\x74\x69\x6E\x67\x53\x74\x61\x72\x74","\x70\x72\x65\x76","\x75\x6C\x2C\x20\x6F\x6C","\x66\x6F\x72\x6D\x61\x74\x42\x6C\x6F\x63\x6B","\x3C\x64\x69\x76\x20\x64\x61\x74\x61\x2D\x74\x61\x67\x62\x6C\x6F\x63\x6B\x3D\x22\x22\x3E","\x6D\x61\x72\x67\x69\x6E\x2D\x6C\x65\x66\x74","\x6E\x6F\x72\x6D\x61\x6C\x69\x7A\x65","\x69\x6E\x64\x65\x6E\x74\x56\x61\x6C\x75\x65","\x69\x6E\x73\x69\x64\x65\x4F\x75\x74\x64\x65\x6E\x74","\x74\x61\x67\x62\x6C\x6F\x63\x6B","\x72\x65\x6D\x6F\x76\x65\x45\x6D\x70\x74\x79\x41\x74\x74\x72","\x4A\x75\x73\x74\x69\x66\x79\x4C\x65\x66\x74","\x61\x6C\x69\x67\x6E\x6D\x65\x6E\x74\x53\x65\x74","\x4A\x75\x73\x74\x69\x66\x79\x52\x69\x67\x68\x74","\x4A\x75\x73\x74\x69\x66\x79\x43\x65\x6E\x74\x65\x72","\x4A\x75\x73\x74\x69\x66\x79\x46\x75\x6C\x6C","\x6F\x6C\x64\x49\x45","\x70\x6C\x61\x63\x65\x68\x6F\x6C\x64\x65\x72\x53\x74\x61\x72\x74","\x3C\x68\x72\x3E","\x63\x6F\x6E\x76\x65\x72\x74\x44\x69\x76\x73","\x3C\x70\x24\x31\x3E\x24\x32\x3C\x2F\x70\x3E","\x63\x6C\x65\x61\x6E\x50\x61\x72\x61\x67\x72\x61\x70\x68\x79","\x74\x65\x6D\x70\x6C\x61\x74\x65\x56\x61\x72\x73","\x3C\x21\x2D\x2D\x20\x74\x65\x6D\x70\x6C\x61\x74\x65\x20\x64\x6F\x75\x62\x6C\x65\x20\x24\x31\x20\x2D\x2D\x3E","\x3C\x21\x2D\x2D\x20\x74\x65\x6D\x70\x6C\x61\x74\x65\x20\x24\x31\x20\x2D\x2D\x3E","\x3C\x74\x69\x74\x6C\x65\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x2F\x6A\x61\x76\x61\x73\x63\x72\x69\x70\x74\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x73\x63\x72\x69\x70\x74\x2D\x74\x61\x67\x22\x24\x31\x3E\x24\x32\x3C\x2F\x74\x69\x74\x6C\x65\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x24\x31\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x20\x72\x65\x6C\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x73\x74\x79\x6C\x65\x2D\x74\x61\x67\x22\x3E\x24\x32\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x24\x31\x20\x72\x65\x6C\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x66\x6F\x72\x6D\x2D\x74\x61\x67\x22\x3E\x24\x32\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E","\x70\x68\x70\x54\x61\x67\x73","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x20\x72\x65\x6C\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x68\x70\x2D\x74\x61\x67\x22\x3E\x24\x31\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E","\x7B\x7B\x24\x31\x7D\x7D","\x7B\x24\x31\x7D","\x3C\x73\x63\x72\x69\x70\x74\x24\x31\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x2F\x6A\x61\x76\x61\x73\x63\x72\x69\x70\x74\x22\x3E\x24\x32\x3C\x2F\x73\x63\x72\x69\x70\x74\x3E","\x3C\x73\x74\x79\x6C\x65\x24\x31\x3E\x24\x32\x3C\x2F\x73\x74\x79\x6C\x65\x3E","\x3C\x66\x6F\x72\x6D\x24\x31\x24\x32\x3E\x24\x33\x3C\x2F\x66\x6F\x72\x6D\x3E","\x3C\x3F\x70\x68\x70\x0D\x0A\x24\x31\x0D\x0A\x3F\x3E","\x6D\x65\x72\x67\x65","\x62\x75\x66\x66\x65\x72\x5F","\x20","\x3E\x20\x3C","\x63\x6C\x65\x61\x6E\x52\x65\x70\x6C\x61\x63\x65\x72","\x3C\x62\x3E\x5C\x73\x2A\x3C\x2F\x62\x3E","\x3C\x62\x3E\x26\x6E\x62\x73\x70\x3B\x3C\x2F\x62\x3E","\x3C\x65\x6D\x3E\x5C\x73\x2A\x3C\x2F\x65\x6D\x3E","\x3C\x70\x72\x65\x3E\x3C\x2F\x70\x72\x65\x3E","\x3C\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E\x5C\x73\x2A\x3C\x2F\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E","\x3C\x64\x64\x3E\x3C\x2F\x64\x64\x3E","\x3C\x64\x74\x3E\x3C\x2F\x64\x74\x3E","\x3C\x75\x6C\x3E\x3C\x2F\x75\x6C\x3E","\x3C\x6F\x6C\x3E\x3C\x2F\x6F\x6C\x3E","\x3C\x6C\x69\x3E\x3C\x2F\x6C\x69\x3E","\x3C\x74\x61\x62\x6C\x65\x3E\x3C\x2F\x74\x61\x62\x6C\x65\x3E","\x3C\x74\x72\x3E\x3C\x2F\x74\x72\x3E","\x3C\x73\x70\x61\x6E\x3E\x5C\x73\x2A\x3C\x73\x70\x61\x6E\x3E","\x3C\x73\x70\x61\x6E\x3E\x26\x6E\x62\x73\x70\x3B\x3C\x73\x70\x61\x6E\x3E","\x3C\x70\x3E\x5C\x73\x2A\x3C\x2F\x70\x3E","\x3C\x70\x3E\x5C\x73\x2A\x3C\x62\x72\x3E\x5C\x73\x2A\x3C\x2F\x70\x3E","\x3C\x64\x69\x76\x3E\x5C\x73\x2A\x3C\x2F\x64\x69\x76\x3E","\x3C\x64\x69\x76\x3E\x5C\x73\x2A\x3C\x62\x72\x3E\x5C\x73\x2A\x3C\x2F\x64\x69\x76\x3E","\x72\x65\x6D\x6F\x76\x65\x45\x6D\x70\x74\x79\x54\x61\x67\x73","\x63\x6F\x6E\x63\x61\x74","\x7B\x72\x65\x70\x6C\x61\x63\x65","\x7D\x0A","\x0A\x0A","\x28\x63\x6F\x6D\x6D\x65\x6E\x74\x7C\x68\x74\x6D\x6C\x7C\x62\x6F\x64\x79\x7C\x68\x65\x61\x64\x7C\x74\x69\x74\x6C\x65\x7C\x6D\x65\x74\x61\x7C\x73\x74\x79\x6C\x65\x7C\x73\x63\x72\x69\x70\x74\x7C\x6C\x69\x6E\x6B\x7C\x69\x66\x72\x61\x6D\x65\x7C\x74\x61\x62\x6C\x65\x7C\x74\x68\x65\x61\x64\x7C\x74\x66\x6F\x6F\x74\x7C\x63\x61\x70\x74\x69\x6F\x6E\x7C\x63\x6F\x6C\x7C\x63\x6F\x6C\x67\x72\x6F\x75\x70\x7C\x74\x62\x6F\x64\x79\x7C\x74\x72\x7C\x74\x64\x7C\x74\x68\x7C\x64\x69\x76\x7C\x64\x6C\x7C\x64\x64\x7C\x64\x74\x7C\x75\x6C\x7C\x6F\x6C\x7C\x6C\x69\x7C\x70\x72\x65\x7C\x73\x65\x6C\x65\x63\x74\x7C\x6F\x70\x74\x69\x6F\x6E\x7C\x66\x6F\x72\x6D\x7C\x6D\x61\x70\x7C\x61\x72\x65\x61\x7C\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x7C\x61\x64\x64\x72\x65\x73\x73\x7C\x6D\x61\x74\x68\x7C\x73\x74\x79\x6C\x65\x7C\x70\x7C\x68\x5B\x31\x2D\x36\x5D\x7C\x68\x72\x7C\x66\x69\x65\x6C\x64\x73\x65\x74\x7C\x6C\x65\x67\x65\x6E\x64\x7C\x73\x65\x63\x74\x69\x6F\x6E\x7C\x61\x72\x74\x69\x63\x6C\x65\x7C\x61\x73\x69\x64\x65\x7C\x68\x67\x72\x6F\x75\x70\x7C\x68\x65\x61\x64\x65\x72\x7C\x66\x6F\x6F\x74\x65\x72\x7C\x6E\x61\x76\x7C\x66\x69\x67\x75\x72\x65\x7C\x66\x69\x67\x63\x61\x70\x74\x69\x6F\x6E\x7C\x64\x65\x74\x61\x69\x6C\x73\x7C\x6D\x65\x6E\x75\x7C\x73\x75\x6D\x6D\x61\x72\x79\x29","\x28\x3C","\x5B\x5E\x3E\x5D\x2A\x3E\x29","\x0A\x24\x31","\x28\x3C\x2F","\x3E\x29","\x24\x31\x0A\x0A","\x0D\x0A","\x67","\x0D","\x2F\x0A\x0A\x2B\x2F","\x0A\x73\x2A\x0A","\x68\x61\x73\x4F\x77\x6E\x50\x72\x6F\x70\x65\x72\x74\x79","\x3C\x70\x3E\x3C\x70\x3E","\x3C\x2F\x70\x3E\x3C\x2F\x70\x3E","\x3C\x70\x3E\x73\x3F\x3C\x2F\x70\x3E","\x3C\x70\x3E\x28\x5B\x5E\x3C\x5D\x2B\x29\x3C\x2F\x28\x64\x69\x76\x7C\x61\x64\x64\x72\x65\x73\x73\x7C\x66\x6F\x72\x6D\x29\x3E","\x3C\x70\x3E\x24\x31\x3C\x2F\x70\x3E\x3C\x2F\x24\x32\x3E","\x3C\x70\x3E\x28\x3C\x2F\x3F","\x5B\x5E\x3E\x5D\x2A\x3E\x29\x3C\x2F\x70\x3E","\x3C\x70\x3E\x28\x3C\x6C\x69\x2E\x2B\x3F\x29\x3C\x2F\x70\x3E","\x3C\x70\x3E\x73\x3F\x28\x3C\x2F\x3F","\x28\x3C\x2F\x3F","\x5B\x5E\x3E\x5D\x2A\x3E\x29\x73\x3F\x3C\x2F\x70\x3E","\x5B\x5E\x3E\x5D\x2A\x3E\x29\x73\x3F\x3C\x62\x72\x20\x2F\x3E","\x3C\x62\x72\x20\x2F\x3E\x28\x73\x2A\x3C\x2F\x3F\x28\x3F\x3A\x70\x7C\x6C\x69\x7C\x64\x69\x76\x7C\x64\x6C\x7C\x64\x64\x7C\x64\x74\x7C\x74\x68\x7C\x70\x72\x65\x7C\x74\x64\x7C\x75\x6C\x7C\x6F\x6C\x29\x5B\x5E\x3E\x5D\x2A\x3E\x29","\x0A\x3C\x2F\x70\x3E","\x3C\x6C\x69\x3E\x3C\x70\x3E","\x3C\x2F\x70\x3E\x3C\x2F\x6C\x69\x3E","\x3C\x2F\x6C\x69\x3E","\x3C\x2F\x6C\x69\x3E\x3C\x70\x3E","\x3C\x70\x3E\x09\x3F\x0A\x3F\x3C\x70\x3E","\x3C\x2F\x64\x74\x3E\x3C\x70\x3E","\x3C\x2F\x64\x74\x3E","\x3C\x2F\x64\x64\x3E\x3C\x70\x3E","\x3C\x2F\x64\x64\x3E","\x3C\x62\x72\x3E\x3C\x2F\x70\x3E\x3C\x2F\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E","\x3C\x2F\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E","\x3C\x70\x3E\x09\x2A\x3C\x2F\x70\x3E","\x7D","\x62\x6F\x6C\x64\x54\x61\x67","\x69\x74\x61\x6C\x69\x63\x54\x61\x67","\x3E\x24\x31\x3C\x2F","\x3C\x73\x74\x72\x6F\x6E\x67\x3E\x24\x31\x3C\x2F\x73\x74\x72\x6F\x6E\x67\x3E","\x3C\x62\x3E\x24\x31\x3C\x2F\x62\x3E","\x3C\x65\x6D\x3E\x24\x31\x3C\x2F\x65\x6D\x3E","\x3C\x69\x3E\x24\x31\x3C\x2F\x69\x3E","\x3C\x64\x65\x6C\x3E\x24\x31\x3C\x2F\x64\x65\x6C\x3E","\x3C\x73\x74\x72\x69\x6B\x65\x3E\x24\x31\x3C\x2F\x73\x74\x72\x69\x6B\x65\x3E","\x63\x6C\x65\x61\x6E\x45\x6E\x63\x6F\x64\x65\x45\x6E\x74\x69\x74\x69\x65\x73","\x22","\x26\x71\x75\x6F\x74\x3B","\x26\x67\x74\x3B","\x26\x6C\x74\x3B","\x26\x61\x6D\x70\x3B","\x6C\x69\x2C\x20\x69\x6D\x67\x2C\x20\x61\x2C\x20\x62\x2C\x20\x73\x74\x72\x6F\x6E\x67\x2C\x20\x73\x75\x62\x2C\x20\x73\x75\x70\x2C\x20\x69\x2C\x20\x65\x6D\x2C\x20\x75\x2C\x20\x73\x6D\x61\x6C\x6C\x2C\x20\x73\x74\x72\x69\x6B\x65\x2C\x20\x64\x65\x6C\x2C\x20\x73\x70\x61\x6E\x2C\x20\x63\x69\x74\x65","\x6C\x69\x6E\x65\x2D\x68\x65\x69\x67\x68\x74","\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x2D\x63\x6F\x6C\x6F\x72","\x5B\x73\x74\x79\x6C\x65\x2A\x3D\x22\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x2D\x63\x6F\x6C\x6F\x72\x3A\x20\x74\x72\x61\x6E\x73\x70\x61\x72\x65\x6E\x74\x3B\x22\x5D\x5B\x73\x74\x79\x6C\x65\x2A\x3D\x22\x6C\x69\x6E\x65\x2D\x68\x65\x69\x67\x68\x74\x22\x5D","\x66\x69\x6C\x74\x65\x72","\x5B\x73\x74\x79\x6C\x65\x2A\x3D\x22\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x2D\x63\x6F\x6C\x6F\x72\x3A\x20\x74\x72\x61\x6E\x73\x70\x61\x72\x65\x6E\x74\x3B\x22\x5D","\x75\x6E\x77\x72\x61\x70","\x64\x69\x76\x5B\x73\x74\x79\x6C\x65\x3D\x22\x74\x65\x78\x74\x2D\x61\x6C\x69\x67\x6E\x3A\x20\x2D\x77\x65\x62\x6B\x69\x74\x2D\x61\x75\x74\x6F\x3B\x22\x5D","\x75\x6C\x2C\x20\x6F\x6C\x2C\x20\x6C\x69","\x63\x6C\x65\x61\x6E\x6C\x65\x76\x65\x6C","\x73\x75\x62\x73\x74\x72","\x63\x6C\x65\x61\x6E\x46\x69\x6E\x69\x73\x68","\x63\x68\x61\x72\x41\x74","\x63\x6C\x65\x61\x6E\x47\x65\x74\x54\x61\x62\x73","\x21\x2D\x2D","\x2D\x2D\x3E","\x3E\x0A","\x21","\x70\x6C\x61\x63\x65\x54\x61\x67","\x3F","\x63\x6C\x65\x61\x6E\x54\x61\x67","\x3C\x73\x63\x72\x69\x70\x74\x24\x31\x3E\x3C\x2F\x73\x63\x72\x69\x70\x74\x3E","\x2F","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31\x22\x3E\x3C\x2F\x73\x70\x61\x6E\x3E","\x3C\x64\x69\x76\x3E","\x2F\x3E","\x70\x61\x72\x61\x67\x72\x61\x70\x68\x73","\x3C\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E","\x67\x65\x74\x53\x65\x6C\x65\x63\x74\x69\x6F\x6E\x48\x74\x6D\x6C","\x74\x6D\x70","\x69\x6E\x6C\x69\x6E\x65\x46\x6F\x72\x6D\x61\x74","\x3C\x74\x6D\x70\x3E\x3C\x2F\x74\x6D\x70\x3E","\x3C\x2F\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x3E\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31\x22\x3E","\x73\x70\x61\x6E\x23\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x57\x72\x61\x70","\x28\x2E\x2A\x3F\x29\x3E","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x45\x6C\x65\x6D\x65\x6E\x74","\x63\x6C\x61\x73\x73","\x69\x6E\x6C\x69\x6E\x65\x45\x61\x63\x68\x4E\x6F\x64\x65\x73","\x69\x6E\x6C\x69\x6E\x65\x4D\x65\x74\x68\x6F\x64\x73","\x73\x74\x61\x72\x74\x43\x6F\x6E\x74\x61\x69\x6E\x65\x72","\x65\x6E\x64\x43\x6F\x6E\x74\x61\x69\x6E\x65\x72","\x69\x6E\x6C\x69\x6E\x65\x55\x6E\x77\x72\x61\x70\x53\x70\x61\x6E","\x66\x6F\x6E\x74\x53\x69\x7A\x65","\x66\x6F\x6E\x74","\x69\x6E\x6C\x69\x6E\x65\x53\x65\x74\x4D\x65\x74\x68\x6F\x64\x73","\x49\x4E\x4C\x49\x4E\x45","\x61\x74\x74\x72\x69\x62\x75\x74\x65\x73","\x3C\x69\x6E\x6C\x69\x6E\x65\x3E","\x70\x61\x72\x65\x6E\x74\x4E\x6F\x64\x65","\x74\x6F\x55\x70\x70\x65\x72\x43\x61\x73\x65","\x70\x61\x72\x73\x65\x48\x54\x4D\x4C","\x67\x65\x74\x52\x61\x6E\x67\x65\x53\x65\x6C\x65\x63\x74\x65\x64\x4E\x6F\x64\x65\x73","\x73\x65\x74\x53\x70\x61\x6E\x73\x56\x65\x72\x69\x66\x69\x65\x64\x48\x74\x6D\x6C","\x70\x2C\x20\x3A\x68\x65\x61\x64\x65\x72\x2C\x20\x75\x6C\x2C\x20\x6F\x6C\x2C\x20\x6C\x69\x2C\x20\x64\x69\x76\x2C\x20\x74\x61\x62\x6C\x65\x2C\x20\x74\x64\x2C\x20\x62\x6C\x6F\x63\x6B\x71\x75\x6F\x74\x65\x2C\x20\x70\x72\x65\x2C\x20\x61\x64\x64\x72\x65\x73\x73\x2C\x20\x73\x65\x63\x74\x69\x6F\x6E\x2C\x20\x68\x65\x61\x64\x65\x72\x2C\x20\x66\x6F\x6F\x74\x65\x72\x2C\x20\x61\x73\x69\x64\x65\x2C\x20\x61\x72\x74\x69\x63\x6C\x65","\x69\x73","\x69\x6E\x73\x65\x72\x74\x48\x74\x6D\x6C\x41\x64\x76\x61\x6E\x63\x65\x64","\x66\x6F\x63\x75\x73\x45\x6E\x64","\u200B","\x53\x50\x41\x4E","\x73\x65\x74\x45\x6E\x64\x41\x66\x74\x65\x72","\x63\x61\x72\x65\x74\x50\x6F\x73\x69\x74\x69\x6F\x6E\x46\x72\x6F\x6D\x50\x6F\x69\x6E\x74","\x6F\x66\x66\x73\x65\x74\x4E\x6F\x64\x65","\x73\x65\x74\x53\x74\x61\x72\x74","\x63\x61\x72\x65\x74\x52\x61\x6E\x67\x65\x46\x72\x6F\x6D\x50\x6F\x69\x6E\x74","\x63\x72\x65\x61\x74\x65\x54\x65\x78\x74\x52\x61\x6E\x67\x65","\x6D\x6F\x76\x65\x54\x6F\x50\x6F\x69\x6E\x74","\x64\x75\x70\x6C\x69\x63\x61\x74\x65","\x45\x6E\x64\x54\x6F\x45\x6E\x64","\x73\x65\x74\x45\x6E\x64\x50\x6F\x69\x6E\x74","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31\x22\x3E","\x3C\x62\x72\x3E\x3C\x62\x72\x3E","\x23\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31","\x73\x65\x74\x43\x61\x72\x65\x74\x41\x66\x74\x65\x72","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x52\x65\x6D\x6F\x76\x65\x4D\x61\x72\x6B\x65\x72\x73","\x67\x65\x74\x43\x61\x72\x65\x74\x4F\x66\x66\x73\x65\x74","\x70\x61\x73\x74\x65\x42\x65\x66\x6F\x72\x65","\x70\x61\x73\x74\x65\x50\x6C\x61\x69\x6E\x54\x65\x78\x74","\x74\x65\x78\x74\x43\x6F\x6E\x74\x65\x6E\x74","\x69\x6E\x6E\x65\x72\x54\x65\x78\x74","\x70\x61\x73\x74\x65\x49\x6E\x73\x65\x72\x74","\x70\x61\x73\x74\x65\x50\x72\x65","\x3C\x75\x6C\x3E\x3C\x6C\x69\x24\x32\x3C\x2F\x6C\x69\x3E","\x3C\x6C\x69\x24\x32\x3C\x2F\x6C\x69\x3E","\x3C\x6C\x69\x24\x32\x3C\x2F\x6C\x69\x3E\x3C\x2F\x75\x6C\x3E","\x3C\x75\x6C\x3E\x3C\x6C\x69\x24\x32\x3C\x2F\x6C\x69\x3E\x3C\x2F\x75\x6C\x3E","\x63\x6C\x65\x61\x6E\x53\x70\x61\x63\x65\x73","\x26\x6E\x62\x73\x70\x3B","\x24\x33","\x5B\x74\x64\x5D","\x5B\x74\x64\x20\x63\x6F\x6C\x73\x70\x61\x6E\x3D\x22\x24\x32\x22\x5D\x24\x34\x5B\x2F\x74\x64\x5D","\x5B\x74\x64\x20\x72\x6F\x77\x73\x70\x61\x6E\x3D\x22\x24\x32\x22\x5D\x24\x34\x5B\x2F\x74\x64\x5D","\x5B\x61\x20\x68\x72\x65\x66\x3D\x22\x24\x32\x22\x5D\x24\x34\x5B\x2F\x61\x5D","\x5B\x69\x66\x72\x61\x6D\x65\x24\x31\x5D\x24\x32\x5B\x2F\x69\x66\x72\x61\x6D\x65\x5D","\x5B\x76\x69\x64\x65\x6F\x24\x31\x5D\x24\x32\x5B\x2F\x76\x69\x64\x65\x6F\x5D","\x5B\x61\x75\x64\x69\x6F\x24\x31\x5D\x24\x32\x5B\x2F\x61\x75\x64\x69\x6F\x5D","\x5B\x65\x6D\x62\x65\x64\x24\x31\x5D\x24\x32\x5B\x2F\x65\x6D\x62\x65\x64\x5D","\x5B\x6F\x62\x6A\x65\x63\x74\x24\x31\x5D\x24\x32\x5B\x2F\x6F\x62\x6A\x65\x63\x74\x5D","\x5B\x70\x61\x72\x61\x6D\x24\x31\x5D","\x5B\x69\x6D\x67\x24\x31\x5D","\x3C\x24\x31\x3E","\x3C\x74\x64\x20\x63\x6F\x6C\x73\x70\x61\x6E\x3D\x22\x24\x31\x22\x3E\x24\x32\x3C\x2F\x74\x64\x3E","\x3C\x74\x64\x20\x72\x6F\x77\x73\x70\x61\x6E\x3D\x22\x24\x31\x22\x3E\x24\x32\x3C\x2F\x74\x64\x3E","\x3C\x74\x64\x3E\x26\x6E\x62\x73\x70\x3B\x3C\x2F\x74\x64\x3E","\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x24\x31\x22\x3E\x24\x32\x3C\x2F\x61\x3E","\x3C\x69\x66\x72\x61\x6D\x65\x24\x31\x3E\x24\x32\x3C\x2F\x69\x66\x72\x61\x6D\x65\x3E","\x3C\x76\x69\x64\x65\x6F\x24\x31\x3E\x24\x32\x3C\x2F\x76\x69\x64\x65\x6F\x3E","\x3C\x61\x75\x64\x69\x6F\x24\x31\x3E\x24\x32\x3C\x2F\x61\x75\x64\x69\x6F\x3E","\x3C\x65\x6D\x62\x65\x64\x24\x31\x3E\x24\x32\x3C\x2F\x65\x6D\x62\x65\x64\x3E","\x3C\x6F\x62\x6A\x65\x63\x74\x24\x31\x3E\x24\x32\x3C\x2F\x6F\x62\x6A\x65\x63\x74\x3E","\x3C\x70\x61\x72\x61\x6D\x24\x31\x3E","\x3C\x69\x6D\x67\x24\x31\x3E","\x3C\x70\x3E\x24\x32\x3C\x2F\x70\x3E","\x3C\x62\x72\x20\x2F\x3E","\x24\x31\x3C\x62\x72\x3E","\x3C\x74\x64\x24\x31\x3E\x24\x33\x3C\x2F\x74\x64\x3E","\x70\x61\x73\x74\x65\x43\x6C\x69\x70\x62\x6F\x61\x72\x64\x4D\x6F\x7A\x69\x6C\x6C\x61","\x3C\x69\x6D\x67","\x3C\x69\x6D\x67\x20\x64\x61\x74\x61\x2D\x6D\x6F\x7A\x69\x6C\x6C\x61\x2D\x70\x61\x73\x74\x65\x2D\x69\x6D\x61\x67\x65\x3D\x22","\x22\x20","\x3C\x6C\x69\x3E\x24\x31\x3C\x2F\x6C\x69\x3E","\x3C\x74\x64\x24\x31\x3E\x24\x32\x24\x34\x3C\x2F\x74\x64\x3E","\x3C\x74\x64\x24\x31\x3E\x24\x32\x24\x33\x3C\x2F\x74\x64\x3E","\x70\x61\x73\x74\x65\x41\x66\x74\x65\x72","\x70\x3A\x65\x6D\x70\x74\x79","\x70\x61\x73\x74\x65\x43\x6C\x69\x70\x62\x6F\x61\x72\x64\x55\x70\x6C\x6F\x61\x64\x4D\x6F\x7A\x69\x6C\x6C\x61","\x75\x70\x6C\x6F\x61\x64\x46\x69\x65\x6C\x64\x73","\x6F\x62\x6A\x65\x63\x74","\x23","\x69\x6D\x67\x5B\x64\x61\x74\x61\x2D\x6D\x6F\x7A\x69\x6C\x6C\x61\x2D\x70\x61\x73\x74\x65\x2D\x69\x6D\x61\x67\x65\x5D","\x2C","\x3A","\x3B","\x70\x61\x73\x74\x65\x43\x6C\x69\x70\x62\x6F\x61\x72\x64\x41\x70\x70\x65\x6E\x64\x46\x69\x65\x6C\x64\x73","\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x55\x70\x6C\x6F\x61\x64\x55\x72\x6C","\x66\x69\x6C\x65\x6C\x69\x6E\x6B","\x64\x61\x74\x61\x2D\x6D\x6F\x7A\x69\x6C\x6C\x61\x2D\x70\x61\x73\x74\x65\x2D\x69\x6D\x61\x67\x65","\x72\x65\x73\x75\x6C\x74","\x3C\x69\x6D\x67\x20\x73\x72\x63\x3D\x22","\x22\x20\x69\x64\x3D\x22\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x2D\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72\x22\x20\x2F\x3E","\x69\x6D\x67\x23\x63\x6C\x69\x70\x62\x6F\x61\x72\x64\x2D\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72","\x70\x6F\x70","\x6C\x69\x6E\x6B\x4F\x62\x73\x65\x72\x76\x65\x72","\x63\x6C\x69\x63\x6B\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x6C\x69\x6E\x6B\x4F\x62\x73\x65\x72\x76\x65\x72\x54\x6F\x6F\x6C\x74\x69\x70\x43\x6C\x6F\x73\x65","\x75\x6E\x73\x65\x6C\x65\x63\x74\x61\x62\x6C\x65","\x69\x6D\x61\x67\x65\x52\x65\x73\x69\x7A\x65","\x3C\x73\x70\x61\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6C\x69\x6E\x6B\x2D\x74\x6F\x6F\x6C\x74\x69\x70\x22\x3E\x3C\x2F\x73\x70\x61\x6E\x3E","\x68\x72\x65\x66","\x2E\x2E\x2E","\x3C\x61\x20\x68\x72\x65\x66\x3D\x22","\x22\x20\x74\x61\x72\x67\x65\x74\x3D\x22\x5F\x62\x6C\x61\x6E\x6B\x22\x3E","\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x23\x22\x3E","\x65\x64\x69\x74","\x20\x7C\x20","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6C\x69\x6E\x6B\x2D\x74\x6F\x6F\x6C\x74\x69\x70","\x72\x61\x6E\x67\x79","\x73\x65\x74\x43\x61\x72\x65\x74","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x53\x65\x74","\x73\x65\x74\x45\x6E\x64","\x66\x6F\x72\x6D\x61\x74\x43\x68\x61\x6E\x67\x65\x54\x61\x67","\x65\x78\x74\x72\x61\x63\x74\x43\x6F\x6E\x74\x65\x6E\x74\x73","\x67\x65\x74\x54\x65\x78\x74\x4E\x6F\x64\x65\x73\x49\x6E","\x63\x68\x69\x6C\x64\x4E\x6F\x64\x65\x73","\x64\x69\x76\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x65\x64\x69\x74\x6F\x72","\x6E\x6F\x64\x65\x4E\x61\x6D\x65","\x74\x61\x67\x54\x65\x73\x74\x42\x6C\x6F\x63\x6B","\x69\x73\x43\x6F\x6C\x6C\x61\x70\x73\x65\x64","\x6E\x65\x78\x74\x4E\x6F\x64\x65","\x63\x6F\x6D\x6D\x6F\x6E\x41\x6E\x63\x65\x73\x74\x6F\x72\x43\x6F\x6E\x74\x61\x69\x6E\x65\x72","\x68\x61\x73\x43\x68\x69\x6C\x64\x4E\x6F\x64\x65\x73","\x6E\x65\x78\x74\x53\x69\x62\x6C\x69\x6E\x67","\x63\x6C\x6F\x6E\x65\x43\x6F\x6E\x74\x65\x6E\x74\x73","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x43\x72\x65\x61\x74\x65\x4D\x61\x72\x6B\x65\x72","\x73\x61\x76\x65\x53\x65\x6C\x65\x63\x74\x69\x6F\x6E","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x22\x3E","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x32\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x22\x3E","\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x53\x65\x74\x4D\x61\x72\x6B\x65\x72","\x64\x65\x74\x61\x63\x68","\x73\x70\x61\x6E\x23\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x32","\x72\x65\x73\x74\x6F\x72\x65\x53\x65\x6C\x65\x63\x74\x69\x6F\x6E","\x73\x70\x61\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72","\x72\x65\x6D\x6F\x76\x65\x4D\x61\x72\x6B\x65\x72\x73","\x6D\x6F\x64\x61\x6C\x5F\x74\x61\x62\x6C\x65","\x74\x61\x62\x6C\x65\x49\x6E\x73\x65\x72\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x74\x61\x62\x6C\x65\x5F\x62\x74\x6E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x6C\x65\x5F\x72\x6F\x77\x73","\x6D\x6F\x64\x61\x6C\x49\x6E\x69\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x6C\x65\x5F\x63\x6F\x6C\x75\x6D\x6E\x73","\x3C\x64\x69\x76\x3E\x3C\x2F\x64\x69\x76\x3E","\x72\x61\x6E\x64\x6F\x6D","\x66\x6C\x6F\x6F\x72","\x3C\x74\x61\x62\x6C\x65\x20\x69\x64\x3D\x22\x74\x61\x62\x6C\x65","\x22\x3E\x3C\x74\x62\x6F\x64\x79\x3E\x3C\x2F\x74\x62\x6F\x64\x79\x3E\x3C\x2F\x74\x61\x62\x6C\x65\x3E","\x3C\x2F\x74\x64\x3E","\x6D\x6F\x64\x61\x6C\x43\x6C\x6F\x73\x65","\x23\x74\x61\x62\x6C\x65","\x73\x70\x61\x6E\x23\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31\x2C\x20\x69\x6E\x6C\x69\x6E\x65\x23\x73\x65\x6C\x65\x63\x74\x69\x6F\x6E\x2D\x6D\x61\x72\x6B\x65\x72\x2D\x31","\x66\x69\x72\x73\x74","\x63\x65\x6C\x6C\x49\x6E\x64\x65\x78","\x65\x71","\x3C\x74\x68\x65\x61\x64\x3E\x3C\x2F\x74\x68\x65\x61\x64\x3E","\x74\x61\x62\x6C\x65\x41\x64\x64\x52\x6F\x77","\x74\x61\x62\x6C\x65\x41\x64\x64\x43\x6F\x6C\x75\x6D\x6E","\x6D\x6F\x64\x61\x6C\x5F\x76\x69\x64\x65\x6F","\x76\x69\x64\x65\x6F\x49\x6E\x73\x65\x72\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x76\x69\x64\x65\x6F\x5F\x62\x74\x6E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x76\x69\x64\x65\x6F\x5F\x61\x72\x65\x61","\x69\x6E\x73\x65\x72\x74\x5F\x6C\x69\x6E\x6B\x5F\x6E\x6F\x64\x65","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x75\x72\x6C\x5F\x74\x65\x78\x74","\x6C\x6F\x63\x61\x74\x69\x6F\x6E","\x6D\x61\x69\x6C\x74\x6F\x3A","\x5E\x28\x68\x74\x74\x70\x7C\x66\x74\x70\x7C\x68\x74\x74\x70\x73\x29\x3A\x2F\x2F","\x68\x6F\x73\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x75\x72\x6C","\x5F\x62\x6C\x61\x6E\x6B","\x63\x68\x65\x63\x6B\x65\x64","\x70\x72\x6F\x70","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x62\x6C\x61\x6E\x6B","\x6C\x69\x6E\x6B\x49\x6E\x73\x65\x72\x74\x50\x72\x65\x73\x73\x65\x64","\x6C\x69\x6E\x6B\x50\x72\x6F\x63\x65\x73\x73","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x6C\x69\x6E\x6B\x5F\x62\x74\x6E","\x6D\x6F\x64\x61\x6C\x5F\x6C\x69\x6E\x6B","\x40","\x20\x74\x61\x72\x67\x65\x74\x3D\x22\x5F\x62\x6C\x61\x6E\x6B\x22","\x28\x28\x78\x6E\x2D\x2D\x29\x3F\x5B\x61\x2D\x7A\x30\x2D\x39\x5D\x2B\x28\x2D\x5B\x61\x2D\x7A\x30\x2D\x39\x5D\x2B\x29\x2A\x2E\x29\x2B\x5B\x61\x2D\x7A\x5D\x7B\x32\x2C\x7D","\x5E","\x6C\x69\x6E\x6B\x49\x6E\x73\x65\x72\x74","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x61\x64\x64\x65\x64\x2D\x6C\x69\x6E\x6B","\x61\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x61\x64\x64\x65\x64\x2D\x6C\x69\x6E\x6B","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x6E\x61\x6D\x65","\x69\x73\x49\x50\x61\x64","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65","\x66\x69\x6C\x65\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x66\x69\x6C\x65\x55\x70\x6C\x6F\x61\x64\x45\x72\x72\x6F\x72","\x66\x69\x6C\x65\x55\x70\x6C\x6F\x61\x64\x50\x61\x72\x61\x6D","\x64\x72\x61\x67\x75\x70\x6C\x6F\x61\x64\x49\x6E\x69\x74","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65","\x75\x70\x6C\x6F\x61\x64\x49\x6E\x69\x74","\x6D\x6F\x64\x61\x6C\x5F\x66\x69\x6C\x65","\x66\x69\x6C\x65\x6E\x61\x6D\x65","\x22\x20\x69\x64\x3D\x22\x66\x69\x6C\x65\x6C\x69\x6E\x6B\x2D\x6D\x61\x72\x6B\x65\x72\x22\x3E","\x63\x68\x72\x6F\x6D\x65","\x61\x23\x66\x69\x6C\x65\x6C\x69\x6E\x6B\x2D\x6D\x61\x72\x6B\x65\x72","\x69\x6D\x61\x67\x65\x47\x65\x74\x4A\x73\x6F\x6E","\x66\x6F\x6C\x64\x65\x72","\x69\x73\x45\x6D\x70\x74\x79\x4F\x62\x6A\x65\x63\x74","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x66\x6F\x6C\x64\x65\x72","\x74\x68\x75\x6D\x62","\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x66\x6F\x6C\x64\x65\x72\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x66\x6F\x6C\x64\x65\x72","\x22\x20\x72\x65\x6C\x3D\x22","\x22\x20\x74\x69\x74\x6C\x65\x3D\x22","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x62\x6F\x78","\x69\x6D\x61\x67\x65\x54\x68\x75\x6D\x62\x43\x6C\x69\x63\x6B","\x3C\x73\x65\x6C\x65\x63\x74\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x62\x6F\x78\x5F\x73\x65\x6C\x65\x63\x74\x22\x3E","\x3C\x6F\x70\x74\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22","\x3C\x2F\x6F\x70\x74\x69\x6F\x6E\x3E","\x67\x65\x74\x4A\x53\x4F\x4E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x74\x61\x62\x2D\x32","\x69\x6D\x61\x67\x65\x43\x61\x6C\x6C\x62\x61\x63\x6B","\x69\x6D\x61\x67\x65\x55\x70\x6C\x6F\x61\x64\x45\x72\x72\x6F\x72","\x63\x68\x61\x6E\x67\x65\x2E\x72\x65\x64\x61\x63\x74\x6F\x72","\x73\x33\x68\x61\x6E\x64\x6C\x65\x46\x69\x6C\x65\x53\x65\x6C\x65\x63\x74","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x73","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x33","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x74\x61\x62\x2D\x31","\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x73\x5F\x61\x63\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x32","\x69\x6D\x61\x67\x65\x54\x61\x62\x4C\x69\x6E\x6B","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x61\x62\x2D\x63\x6F\x6E\x74\x72\x6F\x6C\x2D\x33","\x69\x6D\x61\x67\x65\x43\x61\x6C\x6C\x62\x61\x63\x6B\x4C\x69\x6E\x6B","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x75\x70\x6C\x6F\x61\x64\x5F\x62\x74\x6E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x6C\x69\x6E\x6B","\x6D\x6F\x64\x61\x6C\x5F\x69\x6D\x61\x67\x65","\x61\x6C\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x61\x6C\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x65\x64\x69\x74\x5F\x73\x72\x63","\x64\x69\x73\x70\x6C\x61\x79","\x62\x6C\x6F\x63\x6B","\x66\x6C\x6F\x61\x74","\x6E\x6F\x6E\x65","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x5F\x69\x6D\x61\x67\x65\x5F\x61\x6C\x69\x67\x6E","\x69\x6D\x61\x67\x65\x52\x65\x6D\x6F\x76\x65","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x64\x65\x6C\x65\x74\x65\x5F\x62\x74\x6E","\x69\x6D\x61\x67\x65\x53\x61\x76\x65","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x53\x61\x76\x65\x42\x74\x6E","\x6D\x6F\x64\x61\x6C\x5F\x69\x6D\x61\x67\x65\x5F\x65\x64\x69\x74","\x69\x6D\x61\x67\x65\x44\x65\x6C\x65\x74\x65","\x30\x20","\x69\x6D\x61\x67\x65\x46\x6C\x6F\x61\x74\x4D\x61\x72\x67\x69\x6E","\x20\x30","\x30\x20\x30\x20","\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x62\x6F\x78","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x62\x6F\x78","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x65\x64\x69\x74\x74\x65\x72\x2C\x20\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x72\x65\x73\x69\x7A\x65\x72","\x6D\x61\x72\x67\x69\x6E\x54\x6F\x70","\x6D\x61\x72\x67\x69\x6E\x42\x6F\x74\x74\x6F\x6D","\x6D\x61\x72\x67\x69\x6E\x4C\x65\x66\x74","\x6D\x61\x72\x67\x69\x6E\x52\x69\x67\x68\x74","\x6D\x61\x72\x67\x69\x6E","\x6F\x70\x61\x63\x69\x74\x79","\x63\x6C\x69\x63\x6B\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x72\x65\x73\x69\x7A\x65\x2D\x68\x69\x64\x65","\x6B\x65\x79\x64\x6F\x77\x6E\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x64\x65\x6C\x65\x74\x65","\x64\x72\x61\x67\x73\x74\x61\x72\x74","\x64\x72\x6F\x70\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x69\x6E\x73\x69\x64\x65\x2D\x64\x72\x6F\x70","\x69\x6D\x61\x67\x65\x52\x65\x73\x69\x7A\x65\x43\x6F\x6E\x74\x72\x6F\x6C\x73","\x70\x61\x67\x65\x58","\x72\x6F\x75\x6E\x64","\x70\x61\x67\x65\x59","\x6D\x6F\x75\x73\x65\x6D\x6F\x76\x65","\x2D\x37\x70\x78","\x2D\x31\x33\x70\x78","\x39\x70\x78","\x33\x70\x78\x20\x35\x70\x78","\x69\x6D\x61\x67\x65\x45\x64\x69\x74\x74\x65\x72","\x2D\x31\x31\x70\x78","\x2D\x31\x38\x70\x78","\x31\x31\x70\x78","\x37\x70\x78\x20\x31\x30\x70\x78","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x62\x6F\x78\x22\x20\x64\x61\x74\x61\x2D\x72\x65\x64\x61\x63\x74\x6F\x72\x3D\x22\x76\x65\x72\x69\x66\x69\x65\x64\x22\x3E","\x69\x6E\x6C\x69\x6E\x65\x2D\x62\x6C\x6F\x63\x6B","\x31\x70\x78\x20\x64\x61\x73\x68\x65\x64\x20\x72\x67\x62\x61\x28\x30\x2C\x20\x30\x2C\x20\x30\x2C\x20\x2E\x36\x29","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x65\x64\x69\x74\x74\x65\x72\x22\x20\x64\x61\x74\x61\x2D\x72\x65\x64\x61\x63\x74\x6F\x72\x3D\x22\x76\x65\x72\x69\x66\x69\x65\x64\x22\x3E","\x35\x30\x25","\x23\x30\x30\x30","\x23\x66\x66\x66","\x70\x6F\x69\x6E\x74\x65\x72","\x69\x6D\x61\x67\x65\x45\x64\x69\x74","\x3C\x73\x70\x61\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x69\x6D\x61\x67\x65\x2D\x72\x65\x73\x69\x7A\x65\x72\x22\x20\x64\x61\x74\x61\x2D\x72\x65\x64\x61\x63\x74\x6F\x72\x3D\x22\x76\x65\x72\x69\x66\x69\x65\x64\x22\x3E\x3C\x2F\x73\x70\x61\x6E\x3E","\x6E\x77\x2D\x72\x65\x73\x69\x7A\x65","\x2D\x34\x70\x78","\x2D\x35\x70\x78","\x31\x70\x78\x20\x73\x6F\x6C\x69\x64\x20\x23\x66\x66\x66","\x38\x70\x78","\x3C\x69\x6D\x67\x20\x69\x64\x3D\x22\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72\x22\x20\x73\x72\x63\x3D\x22","\x72\x65\x6C","\x22\x20\x61\x6C\x74\x3D\x22","\x69\x6D\x61\x67\x65\x49\x6E\x73\x65\x72\x74","\x69\x6D\x67\x23\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x66\x69\x6C\x65\x2D\x69\x6E\x73\x65\x72\x74\x22\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x2D\x69\x6E\x6C\x69\x6E\x65\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x73\x70\x61\x6E\x3E\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x66\x6F\x72\x6D\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x55\x70\x6C\x6F\x61\x64\x46\x69\x6C\x65\x46\x6F\x72\x6D\x22\x20\x6D\x65\x74\x68\x6F\x64\x3D\x22\x70\x6F\x73\x74\x22\x20\x61\x63\x74\x69\x6F\x6E\x3D\x22\x22\x20\x65\x6E\x63\x74\x79\x70\x65\x3D\x22\x6D\x75\x6C\x74\x69\x70\x61\x72\x74\x2F\x66\x6F\x72\x6D\x2D\x64\x61\x74\x61\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x6E\x61\x6D\x65\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x2F\x3E\x3C\x64\x69\x76\x20\x73\x74\x79\x6C\x65\x3D\x22\x6D\x61\x72\x67\x69\x6E\x2D\x74\x6F\x70\x3A\x20\x37\x70\x78\x3B\x22\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x66\x69\x6C\x65\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x22\x20\x6E\x61\x6D\x65\x3D\x22","\x22\x20\x2F\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x2F\x66\x6F\x72\x6D\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x69\x6D\x61\x67\x65\x2D\x65\x64\x69\x74\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x61\x6C\x74\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x2F\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x6C\x69\x6E\x6B\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x2F\x3E\x3C\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x63\x68\x65\x63\x6B\x62\x6F\x78\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x62\x6C\x61\x6E\x6B\x22\x3E\x20","\x6C\x69\x6E\x6B\x5F\x6E\x65\x77\x5F\x74\x61\x62","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x69\x6D\x61\x67\x65\x5F\x70\x6F\x73\x69\x74\x69\x6F\x6E","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x73\x65\x6C\x65\x63\x74\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x6F\x72\x6D\x5F\x69\x6D\x61\x67\x65\x5F\x61\x6C\x69\x67\x6E\x22\x3E\x3C\x6F\x70\x74\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22\x6E\x6F\x6E\x65\x22\x3E","\x3C\x2F\x6F\x70\x74\x69\x6F\x6E\x3E\x3C\x6F\x70\x74\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22\x6C\x65\x66\x74\x22\x3E","\x3C\x2F\x6F\x70\x74\x69\x6F\x6E\x3E\x3C\x6F\x70\x74\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22\x63\x65\x6E\x74\x65\x72\x22\x3E","\x3C\x2F\x6F\x70\x74\x69\x6F\x6E\x3E\x3C\x6F\x70\x74\x69\x6F\x6E\x20\x76\x61\x6C\x75\x65\x3D\x22\x72\x69\x67\x68\x74\x22\x3E","\x3C\x2F\x6F\x70\x74\x69\x6F\x6E\x3E\x3C\x2F\x73\x65\x6C\x65\x63\x74\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E\x3C\x66\x6F\x6F\x74\x65\x72\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x64\x65\x6C\x65\x74\x65\x5F\x62\x74\x6E\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x64\x65\x6C\x65\x74\x65\x5F\x62\x74\x6E\x22\x3E","\x5F\x64\x65\x6C\x65\x74\x65","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E","\x63\x61\x6E\x63\x65\x6C","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x53\x61\x76\x65\x42\x74\x6E\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E\x22\x3E","\x73\x61\x76\x65","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x2F\x66\x6F\x6F\x74\x65\x72\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x69\x6D\x61\x67\x65\x2D\x69\x6E\x73\x65\x72\x74\x22\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x73\x22\x3E\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x23\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x61\x62\x2D\x63\x6F\x6E\x74\x72\x6F\x6C\x2D\x31\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x73\x5F\x61\x63\x74\x22\x3E","\x75\x70\x6C\x6F\x61\x64","\x3C\x2F\x61\x3E\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x23\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x61\x62\x2D\x63\x6F\x6E\x74\x72\x6F\x6C\x2D\x32\x22\x3E","\x63\x68\x6F\x6F\x73\x65","\x3C\x2F\x61\x3E\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x23\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x74\x61\x62\x2D\x63\x6F\x6E\x74\x72\x6F\x6C\x2D\x33\x22\x3E","\x3C\x2F\x61\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x2D\x69\x6E\x6C\x69\x6E\x65\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x73\x70\x61\x6E\x3E\x3C\x2F\x73\x70\x61\x6E\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x66\x6F\x72\x6D\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x49\x6E\x73\x65\x72\x74\x49\x6D\x61\x67\x65\x46\x6F\x72\x6D\x22\x20\x6D\x65\x74\x68\x6F\x64\x3D\x22\x70\x6F\x73\x74\x22\x20\x61\x63\x74\x69\x6F\x6E\x3D\x22\x22\x20\x65\x6E\x63\x74\x79\x70\x65\x3D\x22\x6D\x75\x6C\x74\x69\x70\x61\x72\x74\x2F\x66\x6F\x72\x6D\x2D\x64\x61\x74\x61\x22\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x31\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x22\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x66\x69\x6C\x65\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x22\x20\x6E\x61\x6D\x65\x3D\x22","\x22\x20\x2F\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x32\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6D\x61\x67\x65\x5F\x62\x6F\x78\x22\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x2F\x66\x6F\x72\x6D\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x33\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x69\x6D\x61\x67\x65\x5F\x77\x65\x62\x5F\x6C\x69\x6E\x6B","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x6E\x61\x6D\x65\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x6C\x69\x6E\x6B\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x66\x69\x6C\x65\x5F\x6C\x69\x6E\x6B\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x20\x2F\x3E\x3C\x62\x72\x3E\x3C\x62\x72\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E\x3C\x66\x6F\x6F\x74\x65\x72\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x75\x70\x6C\x6F\x61\x64\x5F\x62\x74\x6E\x22\x3E","\x69\x6E\x73\x65\x72\x74","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x6C\x69\x6E\x6B\x2D\x69\x6E\x73\x65\x72\x74\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E\x55\x52\x4C\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x75\x72\x6C\x22\x20\x2F\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x70\x75\x74\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x75\x72\x6C\x5F\x74\x65\x78\x74\x22\x20\x2F\x3E\x3C\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x63\x68\x65\x63\x6B\x62\x6F\x78\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6C\x69\x6E\x6B\x5F\x62\x6C\x61\x6E\x6B\x22\x3E\x20","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E\x3C\x66\x6F\x6F\x74\x65\x72\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x6C\x69\x6E\x6B\x5F\x62\x74\x6E\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E\x22\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x74\x61\x62\x6C\x65\x2D\x69\x6E\x73\x65\x72\x74\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x72\x6F\x77\x73","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x73\x69\x7A\x65\x3D\x22\x35\x22\x20\x76\x61\x6C\x75\x65\x3D\x22\x32\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x6C\x65\x5F\x72\x6F\x77\x73\x22\x20\x2F\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x63\x6F\x6C\x75\x6D\x6E\x73","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x69\x6E\x70\x75\x74\x20\x74\x79\x70\x65\x3D\x22\x74\x65\x78\x74\x22\x20\x73\x69\x7A\x65\x3D\x22\x35\x22\x20\x76\x61\x6C\x75\x65\x3D\x22\x33\x22\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x6C\x65\x5F\x63\x6F\x6C\x75\x6D\x6E\x73\x22\x20\x2F\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E\x3C\x66\x6F\x6F\x74\x65\x72\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x74\x61\x62\x6C\x65\x5F\x62\x74\x6E\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E\x22\x3E","\x3C\x73\x65\x63\x74\x69\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x6D\x6F\x64\x61\x6C\x2D\x76\x69\x64\x65\x6F\x2D\x69\x6E\x73\x65\x72\x74\x22\x3E\x3C\x66\x6F\x72\x6D\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x49\x6E\x73\x65\x72\x74\x56\x69\x64\x65\x6F\x46\x6F\x72\x6D\x22\x3E\x3C\x6C\x61\x62\x65\x6C\x3E","\x76\x69\x64\x65\x6F\x5F\x68\x74\x6D\x6C\x5F\x63\x6F\x64\x65","\x3C\x2F\x6C\x61\x62\x65\x6C\x3E\x3C\x74\x65\x78\x74\x61\x72\x65\x61\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x76\x69\x64\x65\x6F\x5F\x61\x72\x65\x61\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x77\x69\x64\x74\x68\x3A\x20\x39\x39\x25\x3B\x20\x68\x65\x69\x67\x68\x74\x3A\x20\x31\x36\x30\x70\x78\x3B\x22\x3E\x3C\x2F\x74\x65\x78\x74\x61\x72\x65\x61\x3E\x3C\x2F\x66\x6F\x72\x6D\x3E\x3C\x2F\x73\x65\x63\x74\x69\x6F\x6E\x3E\x3C\x66\x6F\x6F\x74\x65\x72\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E","\x3C\x2F\x62\x75\x74\x74\x6F\x6E\x3E\x3C\x62\x75\x74\x74\x6F\x6E\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x69\x6E\x73\x65\x72\x74\x5F\x76\x69\x64\x65\x6F\x5F\x62\x74\x6E\x22\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x62\x74\x6E\x20\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E\x22\x3E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x6F\x76\x65\x72\x6C\x61\x79","\x24\x6F\x76\x65\x72\x6C\x61\x79","\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x6F\x76\x65\x72\x6C\x61\x79\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x2F\x64\x69\x76\x3E","\x6D\x6F\x64\x61\x6C\x4F\x76\x65\x72\x6C\x61\x79","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C","\x24\x6D\x6F\x64\x61\x6C","\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x22\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x20\x6E\x6F\x6E\x65\x3B\x22\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65\x22\x3E\x26\x74\x69\x6D\x65\x73\x3B\x3C\x2F\x64\x69\x76\x3E\x3C\x68\x65\x61\x64\x65\x72\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x68\x65\x61\x64\x65\x72\x22\x3E\x3C\x2F\x68\x65\x61\x64\x65\x72\x3E\x3C\x64\x69\x76\x20\x69\x64\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x69\x6E\x6E\x65\x72\x22\x3E\x3C\x2F\x64\x69\x76\x3E\x3C\x2F\x64\x69\x76\x3E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65","\x68\x64\x6C\x4D\x6F\x64\x61\x6C\x43\x6C\x6F\x73\x65","\x6D\x6F\x64\x61\x6C\x63\x6F\x6E\x74\x65\x6E\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x69\x6E\x6E\x65\x72","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x68\x65\x61\x64\x65\x72","\x64\x72\x61\x67\x67\x61\x62\x6C\x65","\x63\x75\x72\x73\x6F\x72","\x6D\x6F\x76\x65","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x74\x61\x62\x5F\x73\x65\x6C\x65\x63\x74\x65\x64","\x6F\x75\x74\x65\x72\x48\x65\x69\x67\x68\x74","\x6D\x61\x72\x67\x69\x6E\x2D\x74\x6F\x70","\x2D","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x62\x74\x6E\x5F\x6D\x6F\x64\x61\x6C\x5F\x63\x6C\x6F\x73\x65","\x66\x6F\x6F\x74\x65\x72\x20\x62\x75\x74\x74\x6F\x6E","\x73\x61\x76\x65\x4D\x6F\x64\x61\x6C\x53\x63\x72\x6F\x6C\x6C","\x2D\x32\x30\x30\x30\x70\x78","\x6D\x6F\x64\x61\x6C\x53\x61\x76\x65\x42\x6F\x64\x79\x4F\x76\x65\x66\x6C\x6F\x77","\x6F\x76\x65\x72\x66\x6C\x6F\x77","\x30","\x33\x30\x30\x70\x78","\x66\x75\x6E\x63\x74\x69\x6F\x6E","\x6D\x6F\x64\x61\x6C\x4F\x70\x65\x6E\x65\x64","\x66\x6F\x63\x75\x73\x69\x6E\x2E\x6D\x6F\x64\x61\x6C","\x2E\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x6D\x6F\x64\x61\x6C\x5F\x61\x63\x74\x69\x6F\x6E\x5F\x62\x74\x6E","\x6B\x65\x79\x70\x72\x65\x73\x73","\x69\x6E\x70\x75\x74\x5B\x74\x79\x70\x65\x3D\x74\x65\x78\x74\x5D","\x66\x61\x73\x74","\x75\x6E\x62\x69\x6E\x64","\x6D\x6F\x64\x61\x6C\x43\x6C\x6F\x73\x65\x64","\x73\x33\x75\x70\x6C\x6F\x61\x64\x54\x6F\x53\x33","\x73\x33\x65\x78\x65\x63\x75\x74\x65\x4F\x6E\x53\x69\x67\x6E\x65\x64\x55\x72\x6C","\x47\x45\x54","\x26\x74\x79\x70\x65\x3D","\x6F\x76\x65\x72\x72\x69\x64\x65\x4D\x69\x6D\x65\x54\x79\x70\x65","\x74\x65\x78\x74\x2F\x70\x6C\x61\x69\x6E\x3B\x20\x63\x68\x61\x72\x73\x65\x74\x3D\x78\x2D\x75\x73\x65\x72\x2D\x64\x65\x66\x69\x6E\x65\x64","\x6F\x6E\x72\x65\x61\x64\x79\x73\x74\x61\x74\x65\x63\x68\x61\x6E\x67\x65","\x72\x65\x61\x64\x79\x53\x74\x61\x74\x65","\x73\x74\x61\x74\x75\x73","\x66\x61\x64\x65\x49\x6E","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73","\x72\x65\x73\x70\x6F\x6E\x73\x65\x54\x65\x78\x74","\x73\x65\x6E\x64","\x77\x69\x74\x68\x43\x72\x65\x64\x65\x6E\x74\x69\x61\x6C\x73","\x50\x55\x54","\x73\x33\x63\x72\x65\x61\x74\x65\x43\x4F\x52\x53\x52\x65\x71\x75\x65\x73\x74","\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x2C\x20\x23\x72\x65\x64\x61\x63\x74\x6F\x72\x2D\x70\x72\x6F\x67\x72\x65\x73\x73\x2D\x64\x72\x61\x67","\x6F\x6E\x65\x72\x72\x6F\x72","\x6F\x6E\x70\x72\x6F\x67\x72\x65\x73\x73","\x43\x6F\x6E\x74\x65\x6E\x74\x2D\x54\x79\x70\x65","\x73\x65\x74\x52\x65\x71\x75\x65\x73\x74\x48\x65\x61\x64\x65\x72","\x78\x2D\x61\x6D\x7A\x2D\x61\x63\x6C","\x70\x75\x62\x6C\x69\x63\x2D\x72\x65\x61\x64","\x75\x70\x6C\x6F\x61\x64\x4F\x70\x74\x69\x6F\x6E\x73","\x49\x4E\x50\x55\x54","\x65\x6C","\x65\x6C\x65\x6D\x65\x6E\x74\x5F\x61\x63\x74\x69\x6F\x6E","\x61\x63\x74\x69\x6F\x6E","\x73\x75\x62\x6D\x69\x74","\x75\x70\x6C\x6F\x61\x64\x53\x75\x62\x6D\x69\x74","\x74\x72\x69\x67\x67\x65\x72","\x65\x6C\x65\x6D\x65\x6E\x74","\x75\x70\x6C\x6F\x61\x64\x46\x72\x61\x6D\x65","\x75\x70\x6C\x6F\x61\x64\x46\x6F\x72\x6D","\x66","\x3C\x69\x66\x72\x61\x6D\x65\x20\x73\x74\x79\x6C\x65\x3D\x22\x64\x69\x73\x70\x6C\x61\x79\x3A\x6E\x6F\x6E\x65\x22\x20\x69\x64\x3D\x22","\x22\x20\x6E\x61\x6D\x65\x3D\x22","\x22\x3E\x3C\x2F\x69\x66\x72\x61\x6D\x65\x3E","\x75\x70\x6C\x6F\x61\x64\x4C\x6F\x61\x64\x65\x64","\x72\x65\x64\x61\x63\x74\x6F\x72\x55\x70\x6C\x6F\x61\x64\x46\x6F\x72\x6D","\x72\x65\x64\x61\x63\x74\x6F\x72\x55\x70\x6C\x6F\x61\x64\x46\x69\x6C\x65","\x3C\x66\x6F\x72\x6D\x20\x20\x61\x63\x74\x69\x6F\x6E\x3D\x22","\x75\x72\x6C","\x22\x20\x6D\x65\x74\x68\x6F\x64\x3D\x22\x50\x4F\x53\x54\x22\x20\x74\x61\x72\x67\x65\x74\x3D\x22","\x22\x20\x69\x64\x3D\x22","\x22\x20\x65\x6E\x63\x74\x79\x70\x65\x3D\x22\x6D\x75\x6C\x74\x69\x70\x61\x72\x74\x2F\x66\x6F\x72\x6D\x2D\x64\x61\x74\x61\x22\x20\x2F\x3E","\x3C\x69\x6E\x70\x75\x74\x2F\x3E","\x65\x6E\x63\x74\x79\x70\x65","\x6D\x75\x6C\x74\x69\x70\x61\x72\x74\x2F\x66\x6F\x72\x6D\x2D\x64\x61\x74\x61","\x6D\x65\x74\x68\x6F\x64","\x50\x4F\x53\x54","\x63\x6F\x6E\x74\x65\x6E\x74\x44\x6F\x63\x75\x6D\x65\x6E\x74","\x66\x72\x61\x6D\x65\x73","\x73\x75\x63\x63\x65\x73\x73","\x55\x70\x6C\x6F\x61\x64\x20\x66\x61\x69\x6C\x65\x64\x21","\x64\x72\x61\x67\x75\x70\x6C\x6F\x61\x64\x4F\x70\x74\x69\x6F\x6E\x73","\x64\x72\x6F\x70\x5F\x66\x69\x6C\x65\x5F\x68\x65\x72\x65","\x6F\x72\x5F\x63\x68\x6F\x6F\x73\x65","\x64\x72\x6F\x70\x61\x72\x65\x61","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x61\x72\x65\x61\x22\x3E\x3C\x2F\x64\x69\x76\x3E","\x64\x72\x6F\x70\x61\x72\x65\x61\x62\x6F\x78","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x61\x72\x65\x61\x62\x6F\x78\x22\x3E","\x3C\x2F\x64\x69\x76\x3E","\x64\x72\x6F\x70\x61\x6C\x74\x65\x72\x6E\x61\x74\x69\x76\x65","\x3C\x64\x69\x76\x20\x63\x6C\x61\x73\x73\x3D\x22\x72\x65\x64\x61\x63\x74\x6F\x72\x5F\x64\x72\x6F\x70\x61\x6C\x74\x65\x72\x6E\x61\x74\x69\x76\x65\x22\x3E","\x61\x74\x65\x78\x74","\x64\x72\x61\x67\x6F\x76\x65\x72","\x64\x72\x61\x67\x75\x70\x6C\x6F\x61\x64\x4F\x6E\x64\x72\x61\x67","\x64\x72\x61\x67\x6C\x65\x61\x76\x65","\x64\x72\x61\x67\x75\x70\x6C\x6F\x61\x64\x4F\x6E\x64\x72\x61\x67\x6C\x65\x61\x76\x65","\x6F\x6E\x64\x72\x6F\x70","\x64\x72\x6F\x70","\x68\x6F\x76\x65\x72","\x75\x70\x6C\x6F\x61\x64\x50\x61\x72\x61\x6D","\x78\x68\x72","\x61\x6A\x61\x78\x53\x65\x74\x74\x69\x6E\x67\x73","\x70\x72\x6F\x67\x72\x65\x73\x73","\x75\x70\x6C\x6F\x61\x64\x50\x72\x6F\x67\x72\x65\x73\x73","\x61\x64\x64\x45\x76\x65\x6E\x74\x4C\x69\x73\x74\x65\x6E\x65\x72","\x61\x6A\x61\x78\x53\x65\x74\x75\x70","\x73\x6C\x6F\x77","\x3C\x69\x6D\x67\x3E","\x64\x72\x61\x67\x2D\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72","\x69\x6E\x73\x65\x72\x74\x4E\x6F\x64\x65\x54\x6F\x43\x61\x72\x65\x74\x50\x6F\x73\x69\x74\x69\x6F\x6E\x46\x72\x6F\x6D\x50\x6F\x69\x6E\x74","\x69\x6D\x67\x23\x64\x72\x61\x67\x2D\x69\x6D\x61\x67\x65\x2D\x6D\x61\x72\x6B\x65\x72","\x6C\x6F\x61\x64\x65\x64","\x74\x6F\x74\x61\x6C","\x4C\x6F\x61\x64\x69\x6E\x67\x20","\x25\x20","\x74\x6F\x53\x74\x72\x69\x6E\x67","\x5B\x6F\x62\x6A\x65\x63\x74\x20\x53\x74\x72\x69\x6E\x67\x5D","\x74\x72\x69\x64\x65\x6E\x74","\x63\x6F\x6D\x70\x61\x74\x69\x62\x6C\x65","\x72\x76","\x6F\x70\x72","\x63\x6C\x6F\x6E\x65\x4E\x6F\x64\x65","\x67\x65\x74\x43\x61\x72\x65\x74\x4F\x66\x66\x73\x65\x74\x52\x61\x6E\x67\x65","\x3C\x69\x66\x72\x61\x6D\x65\x20\x77\x69\x64\x74\x68\x3D\x22\x35\x30\x30\x22\x20\x68\x65\x69\x67\x68\x74\x3D\x22\x32\x38\x31\x22\x20\x73\x72\x63\x3D\x22","\x22\x20\x66\x72\x61\x6D\x65\x62\x6F\x72\x64\x65\x72\x3D\x22\x30\x22\x20\x61\x6C\x6C\x6F\x77\x66\x75\x6C\x6C\x73\x63\x72\x65\x65\x6E\x3E\x3C\x2F\x69\x66\x72\x61\x6D\x65\x3E","\x2F\x2F\x77\x77\x77\x2E\x79\x6F\x75\x74\x75\x62\x65\x2E\x63\x6F\x6D\x2F\x65\x6D\x62\x65\x64\x2F\x24\x31","\x2F\x2F\x70\x6C\x61\x79\x65\x72\x2E\x76\x69\x6D\x65\x6F\x2E\x63\x6F\x6D\x2F\x76\x69\x64\x65\x6F\x2F\x24\x32","\x3C\x69\x6D\x67\x20\x73\x72\x63\x3D\x22\x24\x31\x22\x3E","\x24\x31\x3C\x61\x20\x68\x72\x65\x66\x3D\x22","\x24\x32\x22\x3E","\x3C\x2F\x61\x3E\x24\x33\x24\x34","\x24\x31\x3C\x61\x20\x68\x72\x65\x66\x3D\x22\x24\x32\x22\x3E","\x3C\x2F\x61\x3E\x24\x35\x24\x36"];(function (c){var a=0;_0x8a37[0];var d=function (e){this[0]=e[_0x8a37[1]];this[1]=e[_0x8a37[2]];this[_0x8a37[3]]=e;return this;} ;d[_0x8a37[5]][_0x8a37[4]]=function (){return this[0]===this[1];} ;c[_0x8a37[7]][_0x8a37[6]]=function (f){var g=[];var e=Array[_0x8a37[5]][_0x8a37[9]][_0x8a37[8]](arguments,1);if( typeof f===_0x8a37[10]){this[_0x8a37[19]](function (){var j=c[_0x8a37[11]](this,_0x8a37[6]);if( typeof j!==_0x8a37[12]&&c[_0x8a37[13]](j[f])){var h=j[f][_0x8a37[14]](j,e);if(h!==undefined&&h!==j){g[_0x8a37[15]](h);} ;} else {return c[_0x8a37[18]](_0x8a37[16]+f+_0x8a37[17]);} ;} );} else {this[_0x8a37[19]](function (){if(!c[_0x8a37[11]](this,_0x8a37[6])){c[_0x8a37[11]](this,_0x8a37[6],b(this,f));} ;} );} ;if(g[_0x8a37[20]]===0){return this;} else {if(g[_0x8a37[20]]===1){return g[0];} else {return g;} ;} ;} ;function b(f,e){return  new b[_0x8a37[5]][_0x8a37[21]](f,e);} ;c[_0x8a37[22]]=b;c[_0x8a37[22]][_0x8a37[23]]=_0x8a37[24];c[_0x8a37[22]][_0x8a37[25]]={rangy:false,iframe:false,fullpage:false,css:false,lang:_0x8a37[26],direction:_0x8a37[27],placeholder:_0x8a37[28],typewriter:false,wym:false,mobile:true,cleanup:true,tidyHtml:true,pastePlainText:false,removeEmptyTags:true,cleanSpaces:true,cleanFontTag:true,templateVars:false,xhtml:false,visual:true,focus:false,tabindex:false,autoresize:true,minHeight:false,maxHeight:false,shortcuts:true,autosave:false,autosaveInterval:60,plugins:false,linkProtocol:_0x8a37[29],linkNofollow:false,linkSize:50,imageFloatMargin:_0x8a37[30],imageGetJson:false,dragUpload:true,imageTabLink:true,imageUpload:false,imageUploadParam:_0x8a37[31],fileUpload:false,fileUploadParam:_0x8a37[31],clipboardUpload:true,clipboardUploadUrl:false,dnbImageTypes:[_0x8a37[32],_0x8a37[33],_0x8a37[34]],s3:false,uploadFields:false,observeImages:true,observeLinks:true,modalOverlay:true,tabSpaces:false,tabFocus:true,air:false,airButtons:[_0x8a37[35],_0x8a37[36],_0x8a37[37],_0x8a37[38],_0x8a37[39],_0x8a37[40],_0x8a37[41],_0x8a37[42]],toolbar:true,toolbarFixed:false,toolbarFixedTarget:document,toolbarFixedTopOffset:0,toolbarFixedBox:false,toolbarExternal:false,toolbarOverflow:false,buttonSource:true,buttons:[_0x8a37[43],_0x8a37[35],_0x8a37[36],_0x8a37[37],_0x8a37[38],_0x8a37[39],_0x8a37[40],_0x8a37[41],_0x8a37[42],_0x8a37[44],_0x8a37[45],_0x8a37[31],_0x8a37[46],_0x8a37[47],_0x8a37[48],_0x8a37[49],_0x8a37[50]],buttonsHideOnMobile:[],activeButtons:[_0x8a37[38],_0x8a37[37],_0x8a37[36],_0x8a37[51],_0x8a37[39],_0x8a37[40],_0x8a37[52],_0x8a37[53],_0x8a37[54],_0x8a37[55],_0x8a37[46]],activeButtonsStates:{b:_0x8a37[36],strong:_0x8a37[36],i:_0x8a37[37],em:_0x8a37[37],del:_0x8a37[38],strike:_0x8a37[38],ul:_0x8a37[39],ol:_0x8a37[40],u:_0x8a37[51],tr:_0x8a37[46],td:_0x8a37[46],table:_0x8a37[46]},formattingTags:[_0x8a37[56],_0x8a37[57],_0x8a37[58],_0x8a37[59],_0x8a37[60],_0x8a37[61],_0x8a37[62],_0x8a37[63],_0x8a37[64]],linebreaks:false,paragraphy:true,convertDivs:true,convertLinks:true,convertImageLinks:false,convertVideoLinks:false,formattingPre:false,phpTags:false,allowedTags:false,deniedTags:[_0x8a37[43],_0x8a37[65],_0x8a37[47],_0x8a37[66],_0x8a37[67],_0x8a37[68],_0x8a37[69],_0x8a37[70]],boldTag:_0x8a37[71],italicTag:_0x8a37[72],indentValue:20,buffer:[],rebuffer:[],textareamode:false,emptyHtml:_0x8a37[73],invisibleSpace:_0x8a37[74],rBlockTest:/^(P|H[1-6]|LI|ADDRESS|SECTION|HEADER|FOOTER|ASIDE|ARTICLE)$/i,alignmentTags:[_0x8a37[75],_0x8a37[76],_0x8a37[77],_0x8a37[78],_0x8a37[79],_0x8a37[80],_0x8a37[81],_0x8a37[82],_0x8a37[83],_0x8a37[84],_0x8a37[85],_0x8a37[86],_0x8a37[87],_0x8a37[88],_0x8a37[89],_0x8a37[90],_0x8a37[91],_0x8a37[92],_0x8a37[93],_0x8a37[94],_0x8a37[95]],ownLine:[_0x8a37[96],_0x8a37[66],_0x8a37[65],_0x8a37[97],_0x8a37[98],_0x8a37[47],_0x8a37[67],_0x8a37[99],_0x8a37[69],_0x8a37[68],_0x8a37[46],_0x8a37[100],_0x8a37[101],_0x8a37[102]],contOwnLine:[_0x8a37[103],_0x8a37[104],_0x8a37[104],_0x8a37[105],_0x8a37[106],_0x8a37[68]],newLevel:[_0x8a37[57],_0x8a37[107],_0x8a37[108],_0x8a37[109],_0x8a37[110],_0x8a37[111],_0x8a37[112],_0x8a37[113],_0x8a37[56],_0x8a37[58],_0x8a37[114],_0x8a37[115],_0x8a37[116],_0x8a37[117],_0x8a37[118]],blockLevelElements:[_0x8a37[75],_0x8a37[76],_0x8a37[77],_0x8a37[78],_0x8a37[79],_0x8a37[80],_0x8a37[81],_0x8a37[82],_0x8a37[83],_0x8a37[84],_0x8a37[85],_0x8a37[119],_0x8a37[87],_0x8a37[88],_0x8a37[89],_0x8a37[120],_0x8a37[90],_0x8a37[91],_0x8a37[92],_0x8a37[93],_0x8a37[94],_0x8a37[95],_0x8a37[86]],langs:{en:{html:_0x8a37[121],video:_0x8a37[122],image:_0x8a37[123],table:_0x8a37[124],link:_0x8a37[125],link_insert:_0x8a37[126],link_edit:_0x8a37[127],unlink:_0x8a37[128],formatting:_0x8a37[129],paragraph:_0x8a37[130],quote:_0x8a37[131],code:_0x8a37[132],header1:_0x8a37[133],header2:_0x8a37[134],header3:_0x8a37[135],header4:_0x8a37[136],header5:_0x8a37[137],bold:_0x8a37[138],italic:_0x8a37[139],fontcolor:_0x8a37[140],backcolor:_0x8a37[141],unorderedlist:_0x8a37[142],orderedlist:_0x8a37[143],outdent:_0x8a37[144],indent:_0x8a37[145],cancel:_0x8a37[146],insert:_0x8a37[147],save:_0x8a37[148],_delete:_0x8a37[149],insert_table:_0x8a37[150],insert_row_above:_0x8a37[151],insert_row_below:_0x8a37[152],insert_column_left:_0x8a37[153],insert_column_right:_0x8a37[154],delete_column:_0x8a37[155],delete_row:_0x8a37[156],delete_table:_0x8a37[157],rows:_0x8a37[158],columns:_0x8a37[159],add_head:_0x8a37[160],delete_head:_0x8a37[161],title:_0x8a37[162],image_position:_0x8a37[163],none:_0x8a37[164],left:_0x8a37[165],right:_0x8a37[166],center:_0x8a37[167],image_web_link:_0x8a37[168],text:_0x8a37[169],mailto:_0x8a37[170],web:_0x8a37[171],video_html_code:_0x8a37[172],file:_0x8a37[173],upload:_0x8a37[174],download:_0x8a37[175],choose:_0x8a37[176],or_choose:_0x8a37[177],drop_file_here:_0x8a37[178],align_left:_0x8a37[179],align_center:_0x8a37[180],align_right:_0x8a37[181],align_justify:_0x8a37[182],horizontalrule:_0x8a37[183],deleted:_0x8a37[184],anchor:_0x8a37[185],link_new_tab:_0x8a37[186],underline:_0x8a37[187],alignment:_0x8a37[188],filename:_0x8a37[189],edit:_0x8a37[190]}}};b[_0x8a37[7]]=c[_0x8a37[22]][_0x8a37[5]]={keyCode:{BACKSPACE:8,DELETE:46,DOWN:40,ENTER:13,ESC:27,TAB:9,CTRL:17,META:91,LEFT:37,LEFT_WIN:91},init:function (f,e){this[_0x8a37[191]]=false;this[_0x8a37[192]]=this[_0x8a37[193]]=c(f);this[_0x8a37[194]]=a++;var g=c[_0x8a37[195]](true,{},c[_0x8a37[22]][_0x8a37[25]]);this[_0x8a37[25]]=c[_0x8a37[195]]({},g,this[_0x8a37[192]][_0x8a37[11]](),e);this[_0x8a37[196]]=true;this[_0x8a37[197]]=[];this[_0x8a37[198]]=this[_0x8a37[193]][_0x8a37[200]](_0x8a37[199]);this[_0x8a37[201]]=this[_0x8a37[193]][_0x8a37[200]](_0x8a37[202]);if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[25]][_0x8a37[204]]=true;} ;if(this[_0x8a37[25]][_0x8a37[205]]){this[_0x8a37[25]][_0x8a37[206]]=false;} ;if(this[_0x8a37[25]][_0x8a37[206]]){this[_0x8a37[25]][_0x8a37[205]]=false;} ;if(this[_0x8a37[25]][_0x8a37[207]]){this[_0x8a37[25]][_0x8a37[208]]=true;} ;this[_0x8a37[209]]=document;this[_0x8a37[210]]=window;this[_0x8a37[211]]=false;this[_0x8a37[212]]= new RegExp(_0x8a37[213]+this[_0x8a37[25]][_0x8a37[216]][_0x8a37[215]](_0x8a37[214])+_0x8a37[49]+this[_0x8a37[25]][_0x8a37[217]][_0x8a37[215]](_0x8a37[49])+_0x8a37[218]);this[_0x8a37[219]]= new RegExp(_0x8a37[220]+this[_0x8a37[25]][_0x8a37[216]][_0x8a37[215]](_0x8a37[214])+_0x8a37[221]+this[_0x8a37[25]][_0x8a37[217]][_0x8a37[215]](_0x8a37[221])+_0x8a37[218]);this[_0x8a37[222]]= new RegExp(_0x8a37[223]+this[_0x8a37[25]][_0x8a37[224]][_0x8a37[215]](_0x8a37[49])+_0x8a37[218]);this[_0x8a37[225]]= new RegExp(_0x8a37[226]+this[_0x8a37[25]][_0x8a37[227]][_0x8a37[215]](_0x8a37[49])+_0x8a37[228],_0x8a37[229]);if(this[_0x8a37[25]][_0x8a37[205]]===false){if(this[_0x8a37[25]][_0x8a37[230]]!==false){var h=[_0x8a37[71],_0x8a37[72],_0x8a37[231]];var j=[_0x8a37[232],_0x8a37[229],_0x8a37[233]];if(c[_0x8a37[234]](_0x8a37[56],this[_0x8a37[25]][_0x8a37[230]])===_0x8a37[235]){this[_0x8a37[25]][_0x8a37[230]][_0x8a37[15]](_0x8a37[56]);} ;for(i in h){if(c[_0x8a37[234]](h[i],this[_0x8a37[25]][_0x8a37[230]])!=_0x8a37[235]){this[_0x8a37[25]][_0x8a37[230]][_0x8a37[15]](j[i]);} ;} ;} ;if(this[_0x8a37[25]][_0x8a37[236]]!==false){var l=c[_0x8a37[234]](_0x8a37[56],this[_0x8a37[25]][_0x8a37[236]]);if(l!==_0x8a37[235]){this[_0x8a37[25]][_0x8a37[236]][_0x8a37[237]](l,l);} ;} ;} ;if(this[_0x8a37[239]](_0x8a37[238])||this[_0x8a37[239]](_0x8a37[240])){this[_0x8a37[25]][_0x8a37[241]]=this[_0x8a37[242]](this[_0x8a37[25]][_0x8a37[241]],_0x8a37[50]);} ;this[_0x8a37[25]][_0x8a37[243]]=this[_0x8a37[25]][_0x8a37[245]][this[_0x8a37[25]][_0x8a37[244]]];this[_0x8a37[246]]();} ,toolbarInit:function (e){return {html:{title:e[_0x8a37[43]],func:_0x8a37[247]},formatting:{title:e[_0x8a37[35]],func:_0x8a37[248],dropdown:{p:{title:e[_0x8a37[249]],func:_0x8a37[250]},blockquote:{title:e[_0x8a37[251]],func:_0x8a37[252],className:_0x8a37[253]},pre:{title:e[_0x8a37[254]],func:_0x8a37[250],className:_0x8a37[255]},h1:{title:e[_0x8a37[256]],func:_0x8a37[250],className:_0x8a37[257]},h2:{title:e[_0x8a37[258]],func:_0x8a37[250],className:_0x8a37[259]},h3:{title:e[_0x8a37[260]],func:_0x8a37[250],className:_0x8a37[261]},h4:{title:e[_0x8a37[262]],func:_0x8a37[250],className:_0x8a37[263]},h5:{title:e[_0x8a37[264]],func:_0x8a37[250],className:_0x8a37[265]}}},bold:{title:e[_0x8a37[36]],exec:_0x8a37[36]},italic:{title:e[_0x8a37[37]],exec:_0x8a37[37]},deleted:{title:e[_0x8a37[38]],exec:_0x8a37[266]},underline:{title:e[_0x8a37[51]],exec:_0x8a37[51]},unorderedlist:{title:_0x8a37[267]+e[_0x8a37[39]],exec:_0x8a37[268]},orderedlist:{title:_0x8a37[269]+e[_0x8a37[40]],exec:_0x8a37[270]},outdent:{title:_0x8a37[271]+e[_0x8a37[41]],func:_0x8a37[272]},indent:{title:_0x8a37[273]+e[_0x8a37[42]],func:_0x8a37[274]},image:{title:e[_0x8a37[44]],func:_0x8a37[275]},video:{title:e[_0x8a37[45]],func:_0x8a37[276]},file:{title:e[_0x8a37[31]],func:_0x8a37[277]},table:{title:e[_0x8a37[46]],func:_0x8a37[248],dropdown:{insert_table:{title:e[_0x8a37[278]],func:_0x8a37[279]},separator_drop1:{name:_0x8a37[280]},insert_row_above:{title:e[_0x8a37[281]],func:_0x8a37[282]},insert_row_below:{title:e[_0x8a37[283]],func:_0x8a37[284]},insert_column_left:{title:e[_0x8a37[285]],func:_0x8a37[286]},insert_column_right:{title:e[_0x8a37[287]],func:_0x8a37[288]},separator_drop2:{name:_0x8a37[280]},add_head:{title:e[_0x8a37[289]],func:_0x8a37[290]},delete_head:{title:e[_0x8a37[291]],func:_0x8a37[292]},separator_drop3:{name:_0x8a37[280]},delete_column:{title:e[_0x8a37[293]],func:_0x8a37[294]},delete_row:{title:e[_0x8a37[295]],func:_0x8a37[296]},delete_table:{title:e[_0x8a37[297]],func:_0x8a37[298]}}},link:{title:e[_0x8a37[47]],func:_0x8a37[248],dropdown:{link:{title:e[_0x8a37[299]],func:_0x8a37[300]},unlink:{title:e[_0x8a37[301]],exec:_0x8a37[301]}}},alignment:{title:e[_0x8a37[48]],func:_0x8a37[248],dropdown:{alignleft:{title:e[_0x8a37[302]],func:_0x8a37[303]},aligncenter:{title:e[_0x8a37[304]],func:_0x8a37[305]},alignright:{title:e[_0x8a37[306]],func:_0x8a37[307]},justify:{title:e[_0x8a37[308]],func:_0x8a37[309]}}},alignleft:{title:e[_0x8a37[302]],func:_0x8a37[303]},aligncenter:{title:e[_0x8a37[304]],func:_0x8a37[305]},alignright:{title:e[_0x8a37[306]],func:_0x8a37[307]},alignjustify:{title:e[_0x8a37[308]],func:_0x8a37[309]},horizontalrule:{exec:_0x8a37[310],title:e[_0x8a37[50]]}};} ,callback:function (e,f,g){var h=this[_0x8a37[25]][e+_0x8a37[311]];if(c[_0x8a37[13]](h)){if(f===false){return h[_0x8a37[8]](this,g);} else {return h[_0x8a37[8]](this,f,g);} ;} else {return g;} ;} ,destroy:function (){clearInterval(this[_0x8a37[312]]);c(window)[_0x8a37[314]](_0x8a37[313]);this[_0x8a37[193]][_0x8a37[314]](_0x8a37[315]);this[_0x8a37[192]][_0x8a37[314]](_0x8a37[313])[_0x8a37[316]](_0x8a37[6]);var f=this[_0x8a37[317]]();if(this[_0x8a37[25]][_0x8a37[318]]){this[_0x8a37[320]][_0x8a37[319]](this.$source);this[_0x8a37[320]][_0x8a37[321]]();this[_0x8a37[193]][_0x8a37[322]](f)[_0x8a37[248]]();} else {var e=this[_0x8a37[323]];if(this[_0x8a37[25]][_0x8a37[204]]){e=this[_0x8a37[192]];} ;this[_0x8a37[320]][_0x8a37[319]](e);this[_0x8a37[320]][_0x8a37[321]]();e[_0x8a37[327]](_0x8a37[328])[_0x8a37[327]](_0x8a37[326])[_0x8a37[325]](_0x8a37[324])[_0x8a37[43]](f)[_0x8a37[248]]();} ;if(this[_0x8a37[25]][_0x8a37[329]]){c(this[_0x8a37[25]][_0x8a37[329]])[_0x8a37[43]](_0x8a37[28]);} ;if(this[_0x8a37[25]][_0x8a37[330]]){c(_0x8a37[331]+this[_0x8a37[194]])[_0x8a37[321]]();} ;} ,getObject:function (){return c[_0x8a37[195]]({},this);} ,getEditor:function (){return this[_0x8a37[323]];} ,getBox:function (){return this[_0x8a37[320]];} ,getIframe:function (){return (this[_0x8a37[25]][_0x8a37[204]])?this[_0x8a37[332]]:false;} ,getToolbar:function (){return (this[_0x8a37[333]])?this[_0x8a37[333]]:false;} ,get:function (){return this[_0x8a37[193]][_0x8a37[322]]();} ,getCodeIframe:function (){this[_0x8a37[323]][_0x8a37[325]](_0x8a37[324])[_0x8a37[325]](_0x8a37[334]);var e=this[_0x8a37[337]](this[_0x8a37[332]][_0x8a37[336]]()[_0x8a37[335]]());this[_0x8a37[323]][_0x8a37[339]]({contenteditable:true,dir:this[_0x8a37[25]][_0x8a37[338]]});return e;} ,set:function (e,f,g){e=e.toString();e=e[_0x8a37[341]](/\$/g,_0x8a37[340]);if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[342]](e);} else {this[_0x8a37[343]](e,f);} ;if(e==_0x8a37[28]){g=false;} ;if(g!==false){this[_0x8a37[344]]();} ;} ,setEditor:function (e,f){if(f!==false){e=this[_0x8a37[345]](e);e=this[_0x8a37[346]](e);e=this[_0x8a37[347]](e);e=this[_0x8a37[348]](e,true);if(this[_0x8a37[25]][_0x8a37[205]]===false){e=this[_0x8a37[349]](e);} else {e=e[_0x8a37[341]](/<p(.*?)>([\w\W]*?)<\/p>/gi,_0x8a37[350]);} ;} ;e=e[_0x8a37[341]](/&amp;#36;/g,_0x8a37[351]);e=this[_0x8a37[352]](e);this[_0x8a37[323]][_0x8a37[43]](e);this[_0x8a37[353]]();this[_0x8a37[354]]();this[_0x8a37[355]]();} ,setCodeIframe:function (e){var f=this[_0x8a37[356]]();this[_0x8a37[332]][0][_0x8a37[357]]=_0x8a37[358];e=this[_0x8a37[347]](e);e=this[_0x8a37[348]](e);e=this[_0x8a37[359]](e);f[_0x8a37[360]]();f[_0x8a37[361]](e);f[_0x8a37[362]]();if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[323]]=this[_0x8a37[332]][_0x8a37[336]]()[_0x8a37[363]](_0x8a37[66])[_0x8a37[339]]({contenteditable:true,dir:this[_0x8a37[25]][_0x8a37[338]]});} ;this[_0x8a37[353]]();this[_0x8a37[354]]();this[_0x8a37[355]]();} ,setFullpageOnInit:function (e){e=this[_0x8a37[345]](e,true);e=this[_0x8a37[349]](e);e=this[_0x8a37[352]](e);this[_0x8a37[323]][_0x8a37[43]](e);this[_0x8a37[353]]();this[_0x8a37[354]]();this[_0x8a37[355]]();} ,setSpansVerified:function (){var f=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[364]);var e=_0x8a37[365];c[_0x8a37[19]](f,function (){var g=this[_0x8a37[366]];var j= new RegExp(_0x8a37[367]+this[_0x8a37[368]],_0x8a37[369]);var h=g[_0x8a37[341]](j,_0x8a37[367]+e);j= new RegExp(_0x8a37[370]+this[_0x8a37[368]],_0x8a37[369]);h=h[_0x8a37[341]](j,_0x8a37[370]+e);c(this)[_0x8a37[371]](h);} );} ,setSpansVerifiedHtml:function (e){e=e[_0x8a37[341]](/<span(.*?)>/,_0x8a37[372]);return e[_0x8a37[341]](/<\/span>/,_0x8a37[373]);} ,setNonEditable:function (){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[374])[_0x8a37[339]](_0x8a37[324],false);} ,sync:function (j){var f=_0x8a37[28];this[_0x8a37[375]]();if(this[_0x8a37[25]][_0x8a37[203]]){f=this[_0x8a37[376]]();} else {f=this[_0x8a37[323]][_0x8a37[43]]();} ;f=this[_0x8a37[377]](f);f=this[_0x8a37[378]](f);var h=this[_0x8a37[359]](this[_0x8a37[193]][_0x8a37[322]](),false);var g=this[_0x8a37[359]](f,false);if(h==g){return false;} ;f=f[_0x8a37[341]](/<\/li><(ul|ol)>([\w\W]*?)<\/(ul|ol)>/gi,_0x8a37[379]);if(c[_0x8a37[380]](f)===_0x8a37[381]){f=_0x8a37[28];} ;if(this[_0x8a37[25]][_0x8a37[382]]){var l=[_0x8a37[383],_0x8a37[97],_0x8a37[384],_0x8a37[47],_0x8a37[385],_0x8a37[67]];c[_0x8a37[19]](l,function (e,m){f=f[_0x8a37[341]]( new RegExp(_0x8a37[367]+m+_0x8a37[386],_0x8a37[369]),_0x8a37[367]+m+_0x8a37[387]);} );} ;f=this[_0x8a37[389]](_0x8a37[388],false,f);this[_0x8a37[193]][_0x8a37[322]](f);this[_0x8a37[389]](_0x8a37[390],false,f);if(this[_0x8a37[196]]===false){if( typeof j!=_0x8a37[12]){switch(j[_0x8a37[392]]){case 37:break ;;case 38:break ;;case 39:break ;;case 40:break ;;default:this[_0x8a37[389]](_0x8a37[391],false,f);;} ;} else {this[_0x8a37[389]](_0x8a37[391],false,f);} ;} ;} ,syncClean:function (e){if(!this[_0x8a37[25]][_0x8a37[203]]){e=this[_0x8a37[346]](e);} ;e=c[_0x8a37[380]](e);e=this[_0x8a37[393]](e);e=e[_0x8a37[341]](/&#x200b;/gi,_0x8a37[28]);e=e[_0x8a37[341]](/&#8203;/gi,_0x8a37[28]);e=e[_0x8a37[341]](/<\/a>&nbsp;/gi,_0x8a37[394]);e=e[_0x8a37[341]](/\u200B/g,_0x8a37[28]);if(e==_0x8a37[395]||e==_0x8a37[396]||e==_0x8a37[397]){e=_0x8a37[28];} ;if(this[_0x8a37[25]][_0x8a37[398]]){e=e[_0x8a37[341]](/<a(.*?)rel="nofollow"(.*?)>/gi,_0x8a37[399]);e=e[_0x8a37[341]](/<a(.*?)>/gi,_0x8a37[400]);} ;e=e[_0x8a37[341]](_0x8a37[401],_0x8a37[402]);e=e[_0x8a37[341]](_0x8a37[403],_0x8a37[404]);e=e[_0x8a37[341]](/<(.*?)class="noeditable"(.*?) contenteditable="false"(.*?)>/gi,_0x8a37[405]);e=e[_0x8a37[341]](/ data-tagblock=""/gi,_0x8a37[28]);e=e[_0x8a37[341]](/<br\s?\/?>\n?<\/(P|H[1-6]|LI|ADDRESS|SECTION|HEADER|FOOTER|ASIDE|ARTICLE)>/gi,_0x8a37[406]);e=e[_0x8a37[341]](/<span(.*?)id="redactor-image-box"(.*?)>([\w\W]*?)<img(.*?)><\/span>/gi,_0x8a37[407]);e=e[_0x8a37[341]](/<span(.*?)id="redactor-image-resizer"(.*?)>(.*?)<\/span>/gi,_0x8a37[28]);e=e[_0x8a37[341]](/<span(.*?)id="redactor-image-editter"(.*?)>(.*?)<\/span>/gi,_0x8a37[28]);e=e[_0x8a37[341]](/<(ul|ol)>\s*\t*\n*<\/(ul|ol)>/gi,_0x8a37[28]);if(this[_0x8a37[25]][_0x8a37[408]]){e=e[_0x8a37[341]](/<font(.*?)>([\w\W]*?)<\/font>/gi,_0x8a37[409]);} ;e=e[_0x8a37[341]](/<span(.*?)>([\w\W]*?)<\/span>/gi,_0x8a37[409]);e=e[_0x8a37[341]](/<inline>/gi,_0x8a37[410]);e=e[_0x8a37[341]](/<inline /gi,_0x8a37[411]);e=e[_0x8a37[341]](/<\/inline>/gi,_0x8a37[412]);e=e[_0x8a37[341]](/<span(.*?)class="redactor_placeholder"(.*?)>([\w\W]*?)<\/span>/gi,_0x8a37[28]);e=e[_0x8a37[341]](/<span>([\w\W]*?)<\/span>/gi,_0x8a37[413]);e=e[_0x8a37[341]](/&amp;/gi,_0x8a37[414]);e=e[_0x8a37[341]](/â„¢/gi,_0x8a37[415]);e=e[_0x8a37[341]](/Â©/gi,_0x8a37[416]);e=e[_0x8a37[341]](/â€¦/gi,_0x8a37[417]);e=e[_0x8a37[341]](/â€”/gi,_0x8a37[418]);e=e[_0x8a37[341]](/â€/gi,_0x8a37[419]);e=this[_0x8a37[420]](e);return e;} ,buildStart:function (){this[_0x8a37[421]]=_0x8a37[28];this[_0x8a37[320]]=c(_0x8a37[422]);this[_0x8a37[320]][_0x8a37[200]](_0x8a37[423],100-this[_0x8a37[194]]);if(this[_0x8a37[193]][0][_0x8a37[368]]===_0x8a37[424]){this[_0x8a37[25]][_0x8a37[318]]=true;} ;if(this[_0x8a37[25]][_0x8a37[425]]===false&&this[_0x8a37[426]]()){this[_0x8a37[427]]();} else {this[_0x8a37[428]]();if(this[_0x8a37[25]][_0x8a37[204]]){this[_0x8a37[25]][_0x8a37[429]]=false;this[_0x8a37[430]]();} else {if(this[_0x8a37[25]][_0x8a37[318]]){this[_0x8a37[431]]();} else {this[_0x8a37[432]]();} ;} ;if(!this[_0x8a37[25]][_0x8a37[204]]){this[_0x8a37[433]]();this[_0x8a37[434]]();} ;} ;} ,buildMobile:function (){if(!this[_0x8a37[25]][_0x8a37[318]]){this[_0x8a37[323]]=this[_0x8a37[193]];this[_0x8a37[323]][_0x8a37[435]]();this[_0x8a37[193]]=this[_0x8a37[436]](this.$editor);this[_0x8a37[193]][_0x8a37[322]](this[_0x8a37[421]]);} ;this[_0x8a37[320]][_0x8a37[438]](this.$source)[_0x8a37[437]](this.$source);} ,buildContent:function (){if(this[_0x8a37[25]][_0x8a37[318]]){this[_0x8a37[421]]=c[_0x8a37[380]](this[_0x8a37[193]][_0x8a37[322]]());} else {this[_0x8a37[421]]=c[_0x8a37[380]](this[_0x8a37[193]][_0x8a37[43]]());} ;} ,buildFromTextarea:function (){this[_0x8a37[323]]=c(_0x8a37[439]);this[_0x8a37[320]][_0x8a37[438]](this.$source)[_0x8a37[437]](this.$editor)[_0x8a37[437]](this.$source);this[_0x8a37[440]](this.$editor);this[_0x8a37[441]]();} ,buildFromElement:function (){this[_0x8a37[323]]=this[_0x8a37[193]];this[_0x8a37[193]]=this[_0x8a37[436]](this.$editor);this[_0x8a37[320]][_0x8a37[438]](this.$editor)[_0x8a37[437]](this.$editor)[_0x8a37[437]](this.$source);this[_0x8a37[441]]();} ,buildCodearea:function (e){return c(_0x8a37[444])[_0x8a37[339]](_0x8a37[442],e[_0x8a37[339]](_0x8a37[443]))[_0x8a37[200]](_0x8a37[199],this[_0x8a37[198]]);} ,buildAddClasses:function (e){c[_0x8a37[19]](this[_0x8a37[193]][_0x8a37[317]](0)[_0x8a37[446]][_0x8a37[445]](/\s+/),function (f,g){e[_0x8a37[448]](_0x8a37[447]+g);} );} ,buildEnable:function (){this[_0x8a37[323]][_0x8a37[448]](_0x8a37[328])[_0x8a37[339]]({contenteditable:true,dir:this[_0x8a37[25]][_0x8a37[338]]});this[_0x8a37[193]][_0x8a37[339]](_0x8a37[334],this[_0x8a37[25]][_0x8a37[338]])[_0x8a37[435]]();this[_0x8a37[449]](this[_0x8a37[421]],true,false);} ,buildOptions:function (){var e=this[_0x8a37[323]];if(this[_0x8a37[25]][_0x8a37[204]]){e=this[_0x8a37[332]];} ;if(this[_0x8a37[25]][_0x8a37[450]]){e[_0x8a37[339]](_0x8a37[450],this[_0x8a37[25]][_0x8a37[450]]);} ;if(this[_0x8a37[25]][_0x8a37[451]]){e[_0x8a37[200]](_0x8a37[452],this[_0x8a37[25]][_0x8a37[451]]+_0x8a37[453]);} else {if(this[_0x8a37[239]](_0x8a37[454])&&this[_0x8a37[25]][_0x8a37[205]]){this[_0x8a37[323]][_0x8a37[200]](_0x8a37[452],_0x8a37[455]);} ;} ;if(this[_0x8a37[239]](_0x8a37[454])&&this[_0x8a37[25]][_0x8a37[205]]){this[_0x8a37[323]][_0x8a37[200]](_0x8a37[456],_0x8a37[30]);} ;if(this[_0x8a37[25]][_0x8a37[457]]){this[_0x8a37[25]][_0x8a37[429]]=false;this[_0x8a37[198]]=this[_0x8a37[25]][_0x8a37[457]];} ;if(this[_0x8a37[25]][_0x8a37[458]]){this[_0x8a37[323]][_0x8a37[448]](_0x8a37[326]);} ;if(this[_0x8a37[25]][_0x8a37[459]]){this[_0x8a37[323]][_0x8a37[448]](_0x8a37[460]);} ;if(!this[_0x8a37[25]][_0x8a37[429]]){e[_0x8a37[200]](_0x8a37[199],this[_0x8a37[198]]);} ;} ,buildAfter:function (){this[_0x8a37[196]]=false;if(this[_0x8a37[25]][_0x8a37[461]]){this[_0x8a37[25]][_0x8a37[461]]=this[_0x8a37[462]](this[_0x8a37[25]][_0x8a37[243]]);this[_0x8a37[463]]();} ;this[_0x8a37[464]]();this[_0x8a37[465]]();this[_0x8a37[466]]();if(this[_0x8a37[25]][_0x8a37[467]]){this[_0x8a37[467]]();} ;setTimeout(c[_0x8a37[469]](this[_0x8a37[468]],this),4);if(this[_0x8a37[239]](_0x8a37[454])){try{this[_0x8a37[209]][_0x8a37[471]](_0x8a37[470],false,false);this[_0x8a37[209]][_0x8a37[471]](_0x8a37[472],false,false);} catch(f){} ;} ;if(this[_0x8a37[25]][_0x8a37[473]]){setTimeout(c[_0x8a37[469]](this[_0x8a37[473]],this),100);} ;if(!this[_0x8a37[25]][_0x8a37[474]]){setTimeout(c[_0x8a37[469]](function (){this[_0x8a37[25]][_0x8a37[474]]=true;this[_0x8a37[247]](false);} ,this),200);} ;this[_0x8a37[389]](_0x8a37[21]);} ,buildBindKeyboard:function (){this[_0x8a37[475]]=0;if(this[_0x8a37[25]][_0x8a37[476]]&&this[_0x8a37[25]][_0x8a37[477]]!==false){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[478],c[_0x8a37[469]](this[_0x8a37[479]],this));} ;this[_0x8a37[323]][_0x8a37[480]](_0x8a37[481],c[_0x8a37[469]](this[_0x8a37[355]],this));this[_0x8a37[323]][_0x8a37[480]](_0x8a37[482],c[_0x8a37[469]](this[_0x8a37[483]],this));this[_0x8a37[323]][_0x8a37[480]](_0x8a37[484],c[_0x8a37[469]](this[_0x8a37[485]],this));this[_0x8a37[323]][_0x8a37[480]](_0x8a37[486],c[_0x8a37[469]](this[_0x8a37[487]],this));if(c[_0x8a37[13]](this[_0x8a37[25]][_0x8a37[488]])){this[_0x8a37[193]][_0x8a37[480]](_0x8a37[489],c[_0x8a37[469]](this[_0x8a37[25]][_0x8a37[488]],this));} ;if(c[_0x8a37[13]](this[_0x8a37[25]][_0x8a37[490]])){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[491],c[_0x8a37[469]](this[_0x8a37[25]][_0x8a37[490]],this));} ;var e;c(document)[_0x8a37[493]](function (f){e=c(f[_0x8a37[492]]);} );this[_0x8a37[323]][_0x8a37[480]](_0x8a37[494],c[_0x8a37[469]](function (f){if(!c(e)[_0x8a37[496]](_0x8a37[495])&&c(e)[_0x8a37[499]](_0x8a37[498])[_0x8a37[497]]()==0){this[_0x8a37[500]]=false;if(c[_0x8a37[13]](this[_0x8a37[25]][_0x8a37[501]])){this[_0x8a37[389]](_0x8a37[502],f);} ;} ;} ,this));} ,buildEventDrop:function (j){j=j[_0x8a37[503]]||j;if(window[_0x8a37[504]]===undefined||!j[_0x8a37[505]]){return true;} ;var h=j[_0x8a37[505]][_0x8a37[506]][_0x8a37[20]];if(h==0){return true;} ;j[_0x8a37[507]]();var g=j[_0x8a37[505]][_0x8a37[506]][0];if(this[_0x8a37[25]][_0x8a37[508]]!==false&&this[_0x8a37[25]][_0x8a37[508]][_0x8a37[510]](g[_0x8a37[509]])==-1){return true;} ;this[_0x8a37[511]]();var f=c(_0x8a37[512]);c(document[_0x8a37[66]])[_0x8a37[437]](f);if(this[_0x8a37[25]][_0x8a37[513]]===false){this[_0x8a37[515]](this[_0x8a37[25]][_0x8a37[477]],g,true,f,j,this[_0x8a37[25]][_0x8a37[514]]);} else {this[_0x8a37[516]](g);} ;} ,buildEventPaste:function (g){var h=false;if(this[_0x8a37[239]](_0x8a37[517])&&navigator[_0x8a37[519]][_0x8a37[510]](_0x8a37[518])===-1){var f=this[_0x8a37[239]](_0x8a37[521])[_0x8a37[445]](_0x8a37[520]);if(f[0]<536){h=true;} ;} ;if(h){return true;} ;if(this[_0x8a37[239]](_0x8a37[240])){return true;} ;if(this[_0x8a37[25]][_0x8a37[522]]&&this[_0x8a37[523]](g)){return true;} ;if(this[_0x8a37[25]][_0x8a37[524]]){this[_0x8a37[191]]=true;this[_0x8a37[525]]();if(!this[_0x8a37[500]]){if(this[_0x8a37[25]][_0x8a37[429]]===true&&this[_0x8a37[526]]!==true){this[_0x8a37[323]][_0x8a37[199]](this[_0x8a37[323]][_0x8a37[199]]());this[_0x8a37[527]]=this[_0x8a37[209]][_0x8a37[66]][_0x8a37[528]];} else {this[_0x8a37[527]]=this[_0x8a37[323]][_0x8a37[528]]();} ;} ;var j=this[_0x8a37[529]]();setTimeout(c[_0x8a37[469]](function (){var e=this[_0x8a37[529]]();this[_0x8a37[323]][_0x8a37[437]](j);this[_0x8a37[530]]();var l=this[_0x8a37[531]](e);this[_0x8a37[532]](l);if(this[_0x8a37[25]][_0x8a37[429]]===true&&this[_0x8a37[526]]!==true){this[_0x8a37[323]][_0x8a37[200]](_0x8a37[199],_0x8a37[533]);} ;} ,this),1);} ;} ,buildEventClipboardUpload:function (j){var h=j[_0x8a37[503]]||j;this[_0x8a37[534]]=false;if( typeof (h[_0x8a37[535]])===_0x8a37[12]){return false;} ;if(h[_0x8a37[535]][_0x8a37[536]]){var g=h[_0x8a37[535]][_0x8a37[536]][0][_0x8a37[537]]();if(g!==null){this[_0x8a37[511]]();this[_0x8a37[534]]=true;var f= new FileReader();f[_0x8a37[538]]=c[_0x8a37[469]](this[_0x8a37[539]],this);f[_0x8a37[540]](g);return true;} ;} ;return false;} ,buildEventKeydown:function (o){if(this[_0x8a37[191]]){return false;} ;var s=o[_0x8a37[392]];var f=o[_0x8a37[541]]||o[_0x8a37[542]];var q=this[_0x8a37[543]]();var p=this[_0x8a37[544]]();var j=this[_0x8a37[545]]();var h=false;this[_0x8a37[389]](_0x8a37[546],o);if(this[_0x8a37[239]](_0x8a37[454])&&f&&s===37){o[_0x8a37[507]]();return false;} ;this[_0x8a37[547]](false);if((q&&c(q)[_0x8a37[317]](0)[_0x8a37[368]]===_0x8a37[120])||(p&&c(p)[_0x8a37[317]](0)[_0x8a37[368]]===_0x8a37[120])){h=true;if(s===this[_0x8a37[549]][_0x8a37[548]]){this[_0x8a37[550]](j);} ;} ;if(s===this[_0x8a37[549]][_0x8a37[548]]){if(q&&c(q)[0][_0x8a37[368]]===_0x8a37[87]){this[_0x8a37[550]](q);} ;if(p&&c(p)[0][_0x8a37[368]]===_0x8a37[87]){this[_0x8a37[550]](p);} ;if(q&&c(q)[0][_0x8a37[368]]===_0x8a37[75]&&c(q)[_0x8a37[551]]()[0][_0x8a37[368]]==_0x8a37[87]){this[_0x8a37[550]](q,c(q)[_0x8a37[551]]()[0]);} ;if(p&&c(p)[0][_0x8a37[368]]===_0x8a37[75]&&q&&c(q)[0][_0x8a37[368]]==_0x8a37[87]){this[_0x8a37[550]](p,q);} ;} ;if(f&&!o[_0x8a37[552]]){this[_0x8a37[553]](o,s);} ;if(f&&s===90&&!o[_0x8a37[552]]&&!o[_0x8a37[554]]){o[_0x8a37[507]]();if(this[_0x8a37[25]][_0x8a37[555]][_0x8a37[20]]){this[_0x8a37[556]]();} else {this[_0x8a37[209]][_0x8a37[471]](_0x8a37[557],false,false);} ;return ;} else {if(f&&s===90&&o[_0x8a37[552]]&&!o[_0x8a37[554]]){o[_0x8a37[507]]();if(this[_0x8a37[25]][_0x8a37[558]][_0x8a37[20]]!=0){this[_0x8a37[559]]();} else {this[_0x8a37[209]][_0x8a37[471]](_0x8a37[560],false,false);} ;return ;} ;} ;if(s==32){this[_0x8a37[511]]();} ;if(f&&s===65){this[_0x8a37[511]]();this[_0x8a37[500]]=true;} else {if(s!=this[_0x8a37[549]][_0x8a37[561]]&&!f){this[_0x8a37[500]]=false;} ;} ;if(s==this[_0x8a37[549]][_0x8a37[562]]&&!o[_0x8a37[552]]&&!o[_0x8a37[541]]&&!o[_0x8a37[542]]){var n=this[_0x8a37[563]]();if(n&&n[_0x8a37[564]]===false){sel=this[_0x8a37[565]]();if(sel[_0x8a37[566]]){n[_0x8a37[567]]();} ;} ;if(this[_0x8a37[239]](_0x8a37[238])&&(q[_0x8a37[568]]==1&&(q[_0x8a37[368]]==_0x8a37[86]||q[_0x8a37[368]]==_0x8a37[569]))){o[_0x8a37[507]]();this[_0x8a37[511]]();this[_0x8a37[571]](document[_0x8a37[570]](_0x8a37[383]));this[_0x8a37[389]](_0x8a37[572],o);return false;} ;if(j&&(j[_0x8a37[368]]==_0x8a37[87]||c(j)[_0x8a37[551]]()[0][_0x8a37[368]]==_0x8a37[87])){if(this[_0x8a37[573]]()){if(this[_0x8a37[475]]==1){var m;var r;if(j[_0x8a37[368]]==_0x8a37[87]){r=_0x8a37[383];m=j;} else {r=_0x8a37[56];m=c(j)[_0x8a37[551]]()[0];} ;o[_0x8a37[507]]();this[_0x8a37[574]](m);this[_0x8a37[475]]=0;if(r==_0x8a37[56]){c(j)[_0x8a37[551]]()[_0x8a37[363]](_0x8a37[56])[_0x8a37[575]]()[_0x8a37[321]]();} else {var l=c[_0x8a37[380]](c(j)[_0x8a37[43]]());c(j)[_0x8a37[43]](l[_0x8a37[341]](/<br\s?\/?>$/i,_0x8a37[28]));} ;return ;} else {this[_0x8a37[475]]++;} ;} else {this[_0x8a37[475]]++;} ;} ;if(h===true){return this[_0x8a37[576]](o,p);} else {if(!this[_0x8a37[25]][_0x8a37[205]]){if(j&&this[_0x8a37[25]][_0x8a37[578]][_0x8a37[577]](j[_0x8a37[368]])){this[_0x8a37[511]]();setTimeout(c[_0x8a37[469]](function (){var t=this[_0x8a37[545]]();if(t[_0x8a37[368]]===_0x8a37[85]&&!c(t)[_0x8a37[496]](_0x8a37[328])){var e=c(_0x8a37[579]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[581]);c(t)[_0x8a37[371]](e);this[_0x8a37[582]](e);} ;} ,this),1);} else {if(j===false){this[_0x8a37[511]]();var g=c(_0x8a37[579]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[581]);this[_0x8a37[571]](g[0]);this[_0x8a37[582]](g);this[_0x8a37[389]](_0x8a37[572],o);return false;} ;} ;} ;if(this[_0x8a37[25]][_0x8a37[205]]){if(j&&this[_0x8a37[25]][_0x8a37[578]][_0x8a37[577]](j[_0x8a37[368]])){this[_0x8a37[511]]();setTimeout(c[_0x8a37[469]](function (){var e=this[_0x8a37[545]]();if((e[_0x8a37[368]]===_0x8a37[85]||e[_0x8a37[368]]===_0x8a37[75])&&!c(e)[_0x8a37[496]](_0x8a37[328])){this[_0x8a37[583]](e);} ;} ,this),1);} else {return this[_0x8a37[584]](o);} ;} ;if(j[_0x8a37[368]]==_0x8a37[87]||j[_0x8a37[368]]==_0x8a37[89]){return this[_0x8a37[584]](o);} ;} ;this[_0x8a37[389]](_0x8a37[572],o);} else {if(s===this[_0x8a37[549]][_0x8a37[562]]&&(o[_0x8a37[541]]||o[_0x8a37[552]])){this[_0x8a37[511]]();o[_0x8a37[507]]();this[_0x8a37[585]]();} ;} ;if((s===this[_0x8a37[549]][_0x8a37[586]]||o[_0x8a37[542]]&&s===219)&&this[_0x8a37[25]][_0x8a37[553]]){return this[_0x8a37[587]](o,h,s);} ;if(s===this[_0x8a37[549]][_0x8a37[588]]){this[_0x8a37[589]](p);} ;} ,buildEventKeydownPre:function (h,g){h[_0x8a37[507]]();this[_0x8a37[511]]();var f=c(g)[_0x8a37[551]]()[_0x8a37[590]]();this[_0x8a37[571]](document[_0x8a37[592]](_0x8a37[591]));if(f[_0x8a37[593]](/\s$/)==-1){this[_0x8a37[571]](document[_0x8a37[592]](_0x8a37[591]));} ;this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[572],h);return false;} ,buildEventKeydownTab:function (h,g,f){if(!this[_0x8a37[25]][_0x8a37[594]]){return true;} ;if(this[_0x8a37[595]](this[_0x8a37[317]]())&&this[_0x8a37[25]][_0x8a37[596]]===false){return true;} ;h[_0x8a37[507]]();if(g===true&&!h[_0x8a37[552]]){this[_0x8a37[511]]();this[_0x8a37[571]](document[_0x8a37[592]](_0x8a37[597]));this[_0x8a37[355]]();return false;} else {if(this[_0x8a37[25]][_0x8a37[596]]!==false){this[_0x8a37[511]]();this[_0x8a37[571]](document[_0x8a37[592]](Array(this[_0x8a37[25]][_0x8a37[596]]+1)[_0x8a37[215]](_0x8a37[598])));this[_0x8a37[355]]();return false;} else {if(!h[_0x8a37[552]]){this[_0x8a37[274]]();} else {this[_0x8a37[272]]();} ;} ;} ;return false;} ,buildEventKeydownBackspace:function (f){if( typeof f[_0x8a37[368]]!==_0x8a37[12]&&/^(H[1-6])$/i[_0x8a37[577]](f[_0x8a37[368]])){var e;if(this[_0x8a37[25]][_0x8a37[205]]===false){e=c(_0x8a37[579]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[581]);} else {e=c(_0x8a37[381]+this[_0x8a37[25]][_0x8a37[580]]);} ;c(f)[_0x8a37[371]](e);this[_0x8a37[582]](e);} ;if( typeof f[_0x8a37[599]]!==_0x8a37[12]&&f[_0x8a37[599]]!==null){if(f[_0x8a37[321]]&&f[_0x8a37[568]]===3&&f[_0x8a37[599]][_0x8a37[600]](/[^\u200B]/g)==null){f[_0x8a37[321]]();} ;} ;} ,buildEventKeydownInsertLineBreak:function (f){this[_0x8a37[511]]();f[_0x8a37[507]]();this[_0x8a37[585]]();this[_0x8a37[389]](_0x8a37[572],f);return ;} ,buildEventKeyup:function (m){if(this[_0x8a37[191]]){return false;} ;var f=m[_0x8a37[392]];var h=this[_0x8a37[543]]();var l=this[_0x8a37[544]]();if(!this[_0x8a37[25]][_0x8a37[205]]&&l[_0x8a37[568]]==3&&(h==false||h[_0x8a37[368]]==_0x8a37[601])){var j=c(_0x8a37[579])[_0x8a37[437]](c(l)[_0x8a37[602]]());c(l)[_0x8a37[371]](j);var g=c(j)[_0x8a37[603]]();if( typeof (g[0])!==_0x8a37[12]&&g[0][_0x8a37[368]]==_0x8a37[604]){g[_0x8a37[321]]();} ;this[_0x8a37[605]](j);} ;if((this[_0x8a37[25]][_0x8a37[606]]||this[_0x8a37[25]][_0x8a37[607]]||this[_0x8a37[25]][_0x8a37[608]])&&f===this[_0x8a37[549]][_0x8a37[562]]){this[_0x8a37[609]]();} ;if(f===this[_0x8a37[549]][_0x8a37[610]]||f===this[_0x8a37[549]][_0x8a37[588]]){return this[_0x8a37[611]](m);} ;this[_0x8a37[389]](_0x8a37[612],m);this[_0x8a37[355]](m);} ,buildEventKeyupConverters:function (){this[_0x8a37[615]](this[_0x8a37[25]][_0x8a37[613]],this[_0x8a37[25]][_0x8a37[606]],this[_0x8a37[25]][_0x8a37[607]],this[_0x8a37[25]][_0x8a37[608]],this[_0x8a37[25]][_0x8a37[614]]);setTimeout(c[_0x8a37[469]](function (){if(this[_0x8a37[25]][_0x8a37[607]]){this[_0x8a37[616]]();} ;if(this[_0x8a37[25]][_0x8a37[617]]){this[_0x8a37[617]]();} ;} ,this),5);} ,buildPlugins:function (){if(!this[_0x8a37[25]][_0x8a37[618]]){return ;} ;c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[618]],c[_0x8a37[469]](function (e,f){if(RedactorPlugins[f]){c[_0x8a37[195]](this,RedactorPlugins[f]);if(c[_0x8a37[13]](RedactorPlugins[f][_0x8a37[21]])){this[_0x8a37[21]]();} ;} ;} ,this));} ,iframeStart:function (){this[_0x8a37[619]]();if(this[_0x8a37[25]][_0x8a37[318]]){this[_0x8a37[620]](this.$source);} else {this[_0x8a37[621]]=this[_0x8a37[193]][_0x8a37[435]]();this[_0x8a37[193]]=this[_0x8a37[436]](this.$sourceOld);this[_0x8a37[620]](this.$sourceOld);} ;} ,iframeAppend:function (e){this[_0x8a37[193]][_0x8a37[339]](_0x8a37[334],this[_0x8a37[25]][_0x8a37[338]])[_0x8a37[435]]();this[_0x8a37[320]][_0x8a37[438]](e)[_0x8a37[437]](this.$frame)[_0x8a37[437]](this.$source);} ,iframeCreate:function (){this[_0x8a37[332]]=c(_0x8a37[625])[_0x8a37[624]](_0x8a37[622],c[_0x8a37[469]](function (){if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[356]]();if(this[_0x8a37[421]]===_0x8a37[28]){this[_0x8a37[421]]=this[_0x8a37[25]][_0x8a37[580]];} ;this[_0x8a37[332]][_0x8a37[336]]()[0][_0x8a37[361]](this[_0x8a37[421]]);this[_0x8a37[332]][_0x8a37[336]]()[0][_0x8a37[362]]();var e=setInterval(c[_0x8a37[469]](function (){if(this[_0x8a37[332]][_0x8a37[336]]()[_0x8a37[363]](_0x8a37[66])[_0x8a37[43]]()){clearInterval(e);this[_0x8a37[623]]();} ;} ,this),0);} else {this[_0x8a37[623]]();} ;} ,this));} ,iframeDoc:function (){return this[_0x8a37[332]][0][_0x8a37[626]][_0x8a37[209]];} ,iframePage:function (){var e=this[_0x8a37[627]]();if(e[_0x8a37[628]]){e[_0x8a37[629]](e[_0x8a37[628]]);} ;return e;} ,iframeAddCss:function (e){e=e||this[_0x8a37[25]][_0x8a37[200]];if(this[_0x8a37[630]](e)){this[_0x8a37[332]][_0x8a37[336]]()[_0x8a37[363]](_0x8a37[65])[_0x8a37[437]](_0x8a37[631]+e+_0x8a37[632]);} ;if(c[_0x8a37[633]](e)){c[_0x8a37[19]](e,c[_0x8a37[469]](function (g,f){this[_0x8a37[634]](f);} ,this));} ;} ,iframeLoad:function (){this[_0x8a37[323]]=this[_0x8a37[332]][_0x8a37[336]]()[_0x8a37[363]](_0x8a37[66])[_0x8a37[339]]({contenteditable:true,dir:this[_0x8a37[25]][_0x8a37[338]]});if(this[_0x8a37[323]][0]){this[_0x8a37[209]]=this[_0x8a37[323]][0][_0x8a37[635]];this[_0x8a37[210]]=this[_0x8a37[209]][_0x8a37[636]]||window;} ;this[_0x8a37[634]]();if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[637]](this[_0x8a37[323]][_0x8a37[43]]());} else {this[_0x8a37[449]](this[_0x8a37[421]],true,false);} ;this[_0x8a37[433]]();this[_0x8a37[434]]();} ,placeholderStart:function (e){if(this[_0x8a37[595]](e)){if(this[_0x8a37[192]][_0x8a37[339]](_0x8a37[638])){this[_0x8a37[25]][_0x8a37[638]]=this[_0x8a37[192]][_0x8a37[339]](_0x8a37[638]);} ;if(this[_0x8a37[25]][_0x8a37[638]]!==_0x8a37[28]){this[_0x8a37[25]][_0x8a37[473]]=false;this[_0x8a37[639]]();this[_0x8a37[640]]();return this[_0x8a37[641]]();} ;} else {this[_0x8a37[640]]();} ;return false;} ,placeholderOnFocus:function (){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[642],c[_0x8a37[469]](this[_0x8a37[643]],this));} ,placeholderOnBlur:function (){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[644],c[_0x8a37[469]](this[_0x8a37[645]],this));} ,placeholderGet:function (){return c(_0x8a37[647])[_0x8a37[11]](_0x8a37[6],_0x8a37[646])[_0x8a37[339]](_0x8a37[324],false)[_0x8a37[590]](this[_0x8a37[25]][_0x8a37[638]]);} ,placeholderBlur:function (){var e=this[_0x8a37[317]]();if(this[_0x8a37[595]](e)){this[_0x8a37[639]]();this[_0x8a37[323]][_0x8a37[43]](this[_0x8a37[641]]());} ;} ,placeholderFocus:function (){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[648])[_0x8a37[321]]();var e=_0x8a37[28];if(this[_0x8a37[25]][_0x8a37[205]]===false){e=this[_0x8a37[25]][_0x8a37[649]];} ;this[_0x8a37[323]][_0x8a37[314]](_0x8a37[642]);this[_0x8a37[323]][_0x8a37[43]](e);if(this[_0x8a37[25]][_0x8a37[205]]===false){this[_0x8a37[582]](this[_0x8a37[323]][_0x8a37[335]]()[0]);} else {this[_0x8a37[473]]();} ;this[_0x8a37[355]]();} ,placeholderRemoveFromEditor:function (){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[648])[_0x8a37[321]]();this[_0x8a37[323]][_0x8a37[314]](_0x8a37[642]);} ,placeholderRemoveFromCode:function (e){return e[_0x8a37[341]](/<span class="redactor_placeholder"(.*?)>(.*?)<\/span>/i,_0x8a37[28]);} ,shortcuts:function (g,f){if(!this[_0x8a37[25]][_0x8a37[553]]){if(f===66||f===73){g[_0x8a37[507]]();} ;return false;} ;if(f===77){this[_0x8a37[651]](g,_0x8a37[650]);} else {if(f===66){this[_0x8a37[651]](g,_0x8a37[36]);} else {if(f===73){this[_0x8a37[651]](g,_0x8a37[37]);} else {if(f===74){this[_0x8a37[651]](g,_0x8a37[268]);} else {if(f===75){this[_0x8a37[651]](g,_0x8a37[270]);} else {if(f===72){this[_0x8a37[651]](g,_0x8a37[652]);} else {if(f===76){this[_0x8a37[651]](g,_0x8a37[653]);} ;} ;} ;} ;} ;} ;} ;} ,shortcutsLoad:function (g,f){g[_0x8a37[507]]();this[_0x8a37[471]](f,false);} ,shortcutsLoadFormat:function (g,f){g[_0x8a37[507]]();this[_0x8a37[250]](f);} ,focus:function (){if(!this[_0x8a37[239]](_0x8a37[240])){this[_0x8a37[210]][_0x8a37[655]](c[_0x8a37[469]](this[_0x8a37[654]],this,true),1);} else {this[_0x8a37[323]][_0x8a37[473]]();} ;} ,focusWithSaveScroll:function (){if(this[_0x8a37[239]](_0x8a37[238])){var e=this[_0x8a37[209]][_0x8a37[628]][_0x8a37[528]];} ;this[_0x8a37[323]][_0x8a37[473]]();if(this[_0x8a37[239]](_0x8a37[238])){this[_0x8a37[209]][_0x8a37[628]][_0x8a37[528]]=e;} ;} ,focusEnd:function (){if(!this[_0x8a37[239]](_0x8a37[454])){this[_0x8a37[654]]();} else {if(this[_0x8a37[25]][_0x8a37[205]]===false){var e=this[_0x8a37[323]][_0x8a37[335]]()[_0x8a37[575]]();this[_0x8a37[323]][_0x8a37[473]]();this[_0x8a37[605]](e);} else {this[_0x8a37[654]]();} ;} ;} ,focusSet:function (h,f){this[_0x8a37[323]][_0x8a37[473]]();if( typeof f==_0x8a37[12]){f=this[_0x8a37[323]][0];} ;var e=this[_0x8a37[563]]();e[_0x8a37[656]](f);e[_0x8a37[657]](h||false);var g=this[_0x8a37[565]]();g[_0x8a37[658]]();g[_0x8a37[659]](e);} ,toggle:function (e){if(this[_0x8a37[25]][_0x8a37[474]]){this[_0x8a37[660]](e);} else {this[_0x8a37[661]]();} ;} ,toggleVisual:function (){var e=this[_0x8a37[193]][_0x8a37[435]]()[_0x8a37[322]]();if( typeof this[_0x8a37[662]]!==_0x8a37[12]){this[_0x8a37[662]]=this[_0x8a37[359]](this[_0x8a37[662]],false)!==this[_0x8a37[359]](e,false);} ;if(this[_0x8a37[662]]){if(this[_0x8a37[25]][_0x8a37[203]]&&e===_0x8a37[28]){this[_0x8a37[637]](e);} else {this[_0x8a37[449]](e);if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[466]]();} ;} ;} ;if(this[_0x8a37[25]][_0x8a37[204]]){this[_0x8a37[332]][_0x8a37[248]]();} else {this[_0x8a37[323]][_0x8a37[248]]();} ;if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[323]][_0x8a37[339]](_0x8a37[324],true);} ;this[_0x8a37[193]][_0x8a37[314]](_0x8a37[663]);this[_0x8a37[323]][_0x8a37[473]]();this[_0x8a37[530]]();this[_0x8a37[468]]();this[_0x8a37[664]]();this[_0x8a37[665]](_0x8a37[43]);this[_0x8a37[25]][_0x8a37[474]]=true;} ,toggleCode:function (g){if(g!==false){this[_0x8a37[525]]();} ;var e=null;if(this[_0x8a37[25]][_0x8a37[204]]){e=this[_0x8a37[332]][_0x8a37[199]]();if(this[_0x8a37[25]][_0x8a37[203]]){this[_0x8a37[323]][_0x8a37[325]](_0x8a37[324]);} ;this[_0x8a37[332]][_0x8a37[435]]();} else {e=this[_0x8a37[323]][_0x8a37[666]]();this[_0x8a37[323]][_0x8a37[435]]();} ;var f=this[_0x8a37[193]][_0x8a37[322]]();if(f!==_0x8a37[28]&&this[_0x8a37[25]][_0x8a37[667]]){this[_0x8a37[193]][_0x8a37[322]](this[_0x8a37[668]](f));} ;this[_0x8a37[662]]=f;this[_0x8a37[193]][_0x8a37[199]](e)[_0x8a37[248]]()[_0x8a37[473]]();this[_0x8a37[193]][_0x8a37[480]](_0x8a37[663],this[_0x8a37[669]]);this[_0x8a37[670]]();this[_0x8a37[671]](_0x8a37[43]);this[_0x8a37[25]][_0x8a37[474]]=false;} ,textareaIndenting:function (g){if(g[_0x8a37[549]]===9){var f=c(this);var h=f[_0x8a37[317]](0)[_0x8a37[582]];f[_0x8a37[322]](f[_0x8a37[322]]()[_0x8a37[672]](0,h)+_0x8a37[597]+f[_0x8a37[322]]()[_0x8a37[672]](f[_0x8a37[317]](0)[_0x8a37[605]]));f[_0x8a37[317]](0)[_0x8a37[582]]=f[_0x8a37[317]](0)[_0x8a37[605]]=h+1;return false;} ;} ,autosave:function (){var e=false;this[_0x8a37[312]]=setInterval(c[_0x8a37[469]](function (){var g=this[_0x8a37[317]]();if(e!==g){var f=this[_0x8a37[193]][_0x8a37[339]](_0x8a37[442]);c[_0x8a37[678]]({url:this[_0x8a37[25]][_0x8a37[467]],type:_0x8a37[673],data:_0x8a37[674]+f+_0x8a37[414]+f+_0x8a37[675]+escape(encodeURIComponent(g)),success:c[_0x8a37[469]](function (j){var h=c[_0x8a37[676]](j);if( typeof h[_0x8a37[18]]==_0x8a37[12]){this[_0x8a37[389]](_0x8a37[467],false,h);} else {this[_0x8a37[389]](_0x8a37[677],false,h);} ;e=g;} ,this)});} ;} ,this),this[_0x8a37[25]][_0x8a37[312]]*1000);} ,toolbarBuild:function (){if(this[_0x8a37[426]]()&&this[_0x8a37[25]][_0x8a37[679]][_0x8a37[20]]>0){c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[679]],c[_0x8a37[469]](function (g,h){var f=this[_0x8a37[25]][_0x8a37[241]][_0x8a37[510]](h);this[_0x8a37[25]][_0x8a37[241]][_0x8a37[237]](f,1);} ,this));} ;if(this[_0x8a37[25]][_0x8a37[330]]){this[_0x8a37[25]][_0x8a37[241]]=this[_0x8a37[25]][_0x8a37[680]];} else {if(!this[_0x8a37[25]][_0x8a37[681]]){var e=this[_0x8a37[25]][_0x8a37[241]][_0x8a37[510]](_0x8a37[43]);this[_0x8a37[25]][_0x8a37[241]][_0x8a37[237]](e,1);} ;} ;if(this[_0x8a37[25]][_0x8a37[461]]){c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[461]][_0x8a37[35]][_0x8a37[682]],c[_0x8a37[469]](function (f,g){if(c[_0x8a37[234]](f,this[_0x8a37[25]][_0x8a37[683]])==_0x8a37[235]){delete this[_0x8a37[25]][_0x8a37[461]][_0x8a37[35]][_0x8a37[682]][f];} ;} ,this));} ;if(this[_0x8a37[25]][_0x8a37[241]][_0x8a37[20]]===0){return false;} ;this[_0x8a37[684]]();this[_0x8a37[333]]=c(_0x8a37[686])[_0x8a37[448]](_0x8a37[495])[_0x8a37[339]](_0x8a37[443],_0x8a37[685]+this[_0x8a37[194]]);if(this[_0x8a37[25]][_0x8a37[459]]){this[_0x8a37[333]][_0x8a37[448]](_0x8a37[687]);} ;if(this[_0x8a37[25]][_0x8a37[688]]&&this[_0x8a37[426]]()){this[_0x8a37[333]][_0x8a37[448]](_0x8a37[689]);} ;if(this[_0x8a37[25]][_0x8a37[330]]){this[_0x8a37[690]]=c(_0x8a37[692])[_0x8a37[339]](_0x8a37[443],_0x8a37[691]+this[_0x8a37[194]])[_0x8a37[435]]();this[_0x8a37[690]][_0x8a37[437]](this.$toolbar);c(_0x8a37[66])[_0x8a37[437]](this.$air);} else {if(this[_0x8a37[25]][_0x8a37[329]]){this[_0x8a37[333]][_0x8a37[448]](_0x8a37[693]);c(this[_0x8a37[25]][_0x8a37[329]])[_0x8a37[43]](this.$toolbar);} else {this[_0x8a37[320]][_0x8a37[694]](this.$toolbar);} ;} ;c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[241]],c[_0x8a37[469]](function (g,h){if(this[_0x8a37[25]][_0x8a37[461]][h]){var f=this[_0x8a37[25]][_0x8a37[461]][h];if(this[_0x8a37[25]][_0x8a37[695]]===false&&h===_0x8a37[31]){return true;} ;this[_0x8a37[333]][_0x8a37[437]](c(_0x8a37[697])[_0x8a37[437]](this[_0x8a37[696]](h,f)));} ;} ,this));this[_0x8a37[333]][_0x8a37[363]](_0x8a37[698])[_0x8a37[339]](_0x8a37[450],_0x8a37[235]);if(this[_0x8a37[25]][_0x8a37[208]]){this[_0x8a37[699]]();c(this[_0x8a37[25]][_0x8a37[701]])[_0x8a37[480]](_0x8a37[700],c[_0x8a37[469]](this[_0x8a37[699]],this));} ;if(this[_0x8a37[25]][_0x8a37[702]]){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[703],c[_0x8a37[469]](this[_0x8a37[704]],this));} ;} ,toolbarObserveScroll:function (){var j=c(this[_0x8a37[25]][_0x8a37[701]])[_0x8a37[528]]();var g=0;var h=0;var e=0;if(this[_0x8a37[25]][_0x8a37[701]]===document){g=this[_0x8a37[320]][_0x8a37[706]]()[_0x8a37[705]];} else {g=1;} ;e=g+this[_0x8a37[320]][_0x8a37[199]]()+40;if(j>g){var f=_0x8a37[707];if(this[_0x8a37[25]][_0x8a37[207]]){h=this[_0x8a37[320]][_0x8a37[706]]()[_0x8a37[708]];f=this[_0x8a37[320]][_0x8a37[709]]();this[_0x8a37[333]][_0x8a37[448]](_0x8a37[710]);} ;this[_0x8a37[208]]=true;if(this[_0x8a37[25]][_0x8a37[701]]===document){this[_0x8a37[333]][_0x8a37[200]]({position:_0x8a37[711],width:f,zIndex:10005,top:this[_0x8a37[25]][_0x8a37[712]]+_0x8a37[453],left:h});} else {this[_0x8a37[333]][_0x8a37[200]]({position:_0x8a37[713],width:f,zIndex:10005,top:(this[_0x8a37[25]][_0x8a37[712]]+j)+_0x8a37[453],left:0});} ;if(j<e){this[_0x8a37[333]][_0x8a37[200]](_0x8a37[714],_0x8a37[715]);} else {this[_0x8a37[333]][_0x8a37[200]](_0x8a37[714],_0x8a37[716]);} ;} else {this[_0x8a37[208]]=false;this[_0x8a37[333]][_0x8a37[200]]({position:_0x8a37[717],width:_0x8a37[533],top:0,left:h});if(this[_0x8a37[25]][_0x8a37[207]]){this[_0x8a37[333]][_0x8a37[327]](_0x8a37[710]);} ;} ;} ,airEnable:function (){if(!this[_0x8a37[25]][_0x8a37[330]]){return ;} ;this[_0x8a37[323]][_0x8a37[480]](_0x8a37[703],this,c[_0x8a37[469]](function (g){var j=this[_0x8a37[718]]();if(g[_0x8a37[509]]===_0x8a37[719]&&j!=_0x8a37[28]){this[_0x8a37[720]](g);} ;if(g[_0x8a37[509]]===_0x8a37[612]&&g[_0x8a37[552]]&&j!=_0x8a37[28]){var f=c(this[_0x8a37[722]](this[_0x8a37[565]]()[_0x8a37[721]])),h=f[_0x8a37[706]]();h[_0x8a37[199]]=f[_0x8a37[199]]();this[_0x8a37[720]](h,true);} ;} ,this));} ,airShow:function (l,f){if(!this[_0x8a37[25]][_0x8a37[330]]){return ;} ;var j,h;c(_0x8a37[723])[_0x8a37[435]]();if(f){j=l[_0x8a37[708]];h=l[_0x8a37[705]]+l[_0x8a37[199]]+14;if(this[_0x8a37[25]][_0x8a37[204]]){h+=this[_0x8a37[320]][_0x8a37[724]]()[_0x8a37[705]]-c(this[_0x8a37[209]])[_0x8a37[528]]();j+=this[_0x8a37[320]][_0x8a37[724]]()[_0x8a37[708]];} ;} else {var g=this[_0x8a37[690]][_0x8a37[709]]();j=l[_0x8a37[725]];if(c(this[_0x8a37[209]])[_0x8a37[202]]()<(j+g)){j-=g;} ;h=l[_0x8a37[726]]+14;if(this[_0x8a37[25]][_0x8a37[204]]){h+=this[_0x8a37[320]][_0x8a37[724]]()[_0x8a37[705]];j+=this[_0x8a37[320]][_0x8a37[724]]()[_0x8a37[708]];} else {h+=c(this[_0x8a37[209]])[_0x8a37[528]]();} ;} ;this[_0x8a37[690]][_0x8a37[200]]({left:j+_0x8a37[453],top:h+_0x8a37[453]})[_0x8a37[248]]();this[_0x8a37[727]]();} ,airBindHide:function (){if(!this[_0x8a37[25]][_0x8a37[330]]){return ;} ;var e=c[_0x8a37[469]](function (f){c(f)[_0x8a37[480]](_0x8a37[731],c[_0x8a37[469]](function (g){if(c(g[_0x8a37[492]])[_0x8a37[732]](this.$toolbar)[_0x8a37[20]]===0){this[_0x8a37[690]][_0x8a37[730]](100);this[_0x8a37[733]]();c(f)[_0x8a37[314]](g);} ;} ,this))[_0x8a37[480]](_0x8a37[484],c[_0x8a37[469]](function (g){if(g[_0x8a37[392]]===this[_0x8a37[549]][_0x8a37[728]]){this[_0x8a37[565]]()[_0x8a37[729]]();} ;this[_0x8a37[690]][_0x8a37[730]](100);c(f)[_0x8a37[314]](g);} ,this));} ,this);e(document);if(this[_0x8a37[25]][_0x8a37[204]]){e(this[_0x8a37[209]]);} ;} ,airBindMousemoveHide:function (){if(!this[_0x8a37[25]][_0x8a37[330]]){return ;} ;var e=c[_0x8a37[469]](function (f){c(f)[_0x8a37[480]](_0x8a37[734],c[_0x8a37[469]](function (g){if(c(g[_0x8a37[492]])[_0x8a37[732]](this.$toolbar)[_0x8a37[20]]===0){this[_0x8a37[690]][_0x8a37[730]](100);c(f)[_0x8a37[314]](g);} ;} ,this));} ,this);e(document);if(this[_0x8a37[25]][_0x8a37[204]]){e(this[_0x8a37[209]]);} ;} ,dropdownBuild:function (f,e){c[_0x8a37[19]](e,c[_0x8a37[469]](function (j,h){if(!h[_0x8a37[446]]){h[_0x8a37[446]]=_0x8a37[28];} ;var g;if(h[_0x8a37[442]]===_0x8a37[280]){g=c(_0x8a37[735]);} else {g=c(_0x8a37[736]+h[_0x8a37[446]]+_0x8a37[737]+j+_0x8a37[738]+h[_0x8a37[739]]+_0x8a37[740]);g[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (l){if(l[_0x8a37[507]]){l[_0x8a37[507]]();} ;if(this[_0x8a37[239]](_0x8a37[238])){l[_0x8a37[742]]=false;} ;if(h[_0x8a37[389]]){h[_0x8a37[389]][_0x8a37[8]](this,j,g,h,l);} ;if(h[_0x8a37[743]]){this[_0x8a37[471]](h[_0x8a37[743]],j);} ;if(h[_0x8a37[744]]){this[h[_0x8a37[744]]](j);} ;this[_0x8a37[704]]();if(this[_0x8a37[25]][_0x8a37[330]]){this[_0x8a37[690]][_0x8a37[730]](100);} ;} ,this));} ;f[_0x8a37[437]](g);} ,this));} ,dropdownShow:function (m,q){if(!this[_0x8a37[25]][_0x8a37[474]]){m[_0x8a37[507]]();return false;} ;var n=this[_0x8a37[333]][_0x8a37[363]](_0x8a37[745]+q);var f=this[_0x8a37[746]](q);if(f[_0x8a37[496]](_0x8a37[747])){this[_0x8a37[748]]();} else {this[_0x8a37[748]]();this[_0x8a37[389]](_0x8a37[749],{dropdown:n,key:q,button:f});this[_0x8a37[671]](q);f[_0x8a37[448]](_0x8a37[747]);var r=f[_0x8a37[724]]();if(this[_0x8a37[208]]){r=f[_0x8a37[706]]();} ;var o=n[_0x8a37[202]]();if((r[_0x8a37[708]]+o)>c(document)[_0x8a37[202]]()){r[_0x8a37[708]]-=o;} ;var h=r[_0x8a37[708]]+_0x8a37[453];var j=f[_0x8a37[666]]();var l=_0x8a37[713];var p=j+_0x8a37[453];if(this[_0x8a37[25]][_0x8a37[208]]&&this[_0x8a37[208]]){l=_0x8a37[711];} else {if(!this[_0x8a37[25]][_0x8a37[330]]){p=r[_0x8a37[705]]+j+_0x8a37[453];} ;} ;n[_0x8a37[200]]({position:l,left:h,top:p})[_0x8a37[248]]();this[_0x8a37[389]](_0x8a37[750],{dropdown:n,key:q,button:f});} ;var g=c[_0x8a37[469]](function (s){this[_0x8a37[751]](s,n);} ,this);c(document)[_0x8a37[624]](_0x8a37[741],g);this[_0x8a37[323]][_0x8a37[624]](_0x8a37[741],g);m[_0x8a37[752]]();this[_0x8a37[753]]();} ,dropdownHideAll:function (){this[_0x8a37[333]][_0x8a37[363]](_0x8a37[755])[_0x8a37[327]](_0x8a37[754])[_0x8a37[327]](_0x8a37[747]);c(_0x8a37[756])[_0x8a37[435]]();this[_0x8a37[389]](_0x8a37[751]);} ,dropdownHide:function (g,f){if(!c(g[_0x8a37[492]])[_0x8a37[496]](_0x8a37[747])){f[_0x8a37[327]](_0x8a37[747]);this[_0x8a37[748]]();} ;} ,buttonBuild:function (j,f,e){var g=c(_0x8a37[757]+f[_0x8a37[739]]+_0x8a37[758]+j+_0x8a37[759]);if( typeof e!=_0x8a37[12]){g[_0x8a37[448]](_0x8a37[760]);} ;g[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (l){if(l[_0x8a37[507]]){l[_0x8a37[507]]();} ;if(this[_0x8a37[239]](_0x8a37[238])){l[_0x8a37[742]]=false;} ;if(g[_0x8a37[496]](_0x8a37[761])){return false;} ;if(this[_0x8a37[762]]()===false&&!f[_0x8a37[743]]){this[_0x8a37[753]]();} ;if(f[_0x8a37[743]]){this[_0x8a37[753]]();this[_0x8a37[471]](f[_0x8a37[743]],j);this[_0x8a37[763]]();} else {if(f[_0x8a37[744]]&&f[_0x8a37[744]]!==_0x8a37[248]){this[f[_0x8a37[744]]](j);this[_0x8a37[763]]();} else {if(f[_0x8a37[389]]){f[_0x8a37[389]][_0x8a37[8]](this,j,g,f,l);this[_0x8a37[763]]();} else {if(f[_0x8a37[682]]){this[_0x8a37[749]](l,j);} ;} ;} ;} ;this[_0x8a37[704]](false,j);} ,this));if(f[_0x8a37[682]]){var h=c(_0x8a37[764]+j+_0x8a37[765]);h[_0x8a37[766]](this.$toolbar);this[_0x8a37[767]](h,f[_0x8a37[682]]);} ;return g;} ,buttonGet:function (e){if(!this[_0x8a37[25]][_0x8a37[461]]){return false;} ;return c(this[_0x8a37[333]][_0x8a37[363]](_0x8a37[768]+e));} ,buttonTagToActiveState:function (e,f){this[_0x8a37[25]][_0x8a37[702]][_0x8a37[15]](e);this[_0x8a37[25]][_0x8a37[769]][f]=e;} ,buttonActiveToggle:function (f){var e=this[_0x8a37[746]](f);if(e[_0x8a37[496]](_0x8a37[754])){this[_0x8a37[665]](f);} else {this[_0x8a37[671]](f);} ;} ,buttonActive:function (f){var e=this[_0x8a37[746]](f);e[_0x8a37[448]](_0x8a37[754]);} ,buttonInactive:function (f){var e=this[_0x8a37[746]](f);e[_0x8a37[327]](_0x8a37[754]);} ,buttonInactiveAll:function (e){this[_0x8a37[333]][_0x8a37[363]](_0x8a37[772])[_0x8a37[771]](_0x8a37[770]+e)[_0x8a37[327]](_0x8a37[754]);} ,buttonActiveVisual:function (){this[_0x8a37[333]][_0x8a37[363]](_0x8a37[772])[_0x8a37[771]](_0x8a37[773])[_0x8a37[327]](_0x8a37[761]);} ,buttonInactiveVisual:function (){this[_0x8a37[333]][_0x8a37[363]](_0x8a37[772])[_0x8a37[771]](_0x8a37[773])[_0x8a37[448]](_0x8a37[761]);} ,buttonChangeIcon:function (e,f){this[_0x8a37[746]](e)[_0x8a37[448]](_0x8a37[774]+f);} ,buttonRemoveIcon:function (e,f){this[_0x8a37[746]](e)[_0x8a37[327]](_0x8a37[774]+f);} ,buttonAwesome:function (g,e){var f=this[_0x8a37[746]](g);f[_0x8a37[327]](_0x8a37[760]);f[_0x8a37[448]](_0x8a37[775]);f[_0x8a37[43]](_0x8a37[776]+e+_0x8a37[777]);} ,buttonAdd:function (f,g,j,h){if(!this[_0x8a37[25]][_0x8a37[461]]){return ;} ;var e=this[_0x8a37[696]](f,{title:g,callback:j,dropdown:h},true);this[_0x8a37[333]][_0x8a37[437]](c(_0x8a37[697])[_0x8a37[437]](e));return e;} ,buttonAddFirst:function (f,g,j,h){if(!this[_0x8a37[25]][_0x8a37[461]]){return ;} ;var e=this[_0x8a37[696]](f,{title:g,callback:j,dropdown:h},true);this[_0x8a37[333]][_0x8a37[694]](c(_0x8a37[697])[_0x8a37[437]](e));} ,buttonAddAfter:function (m,f,h,l,j){if(!this[_0x8a37[25]][_0x8a37[461]]){return ;} ;var e=this[_0x8a37[696]](f,{title:h,callback:l,dropdown:j},true);var g=this[_0x8a37[746]](m);if(g[_0x8a37[497]]()!==0){g[_0x8a37[551]]()[_0x8a37[319]](c(_0x8a37[697])[_0x8a37[437]](e));} else {this[_0x8a37[333]][_0x8a37[437]](c(_0x8a37[697])[_0x8a37[437]](e));} ;return e;} ,buttonAddBefore:function (j,f,h,m,l){if(!this[_0x8a37[25]][_0x8a37[461]]){return ;} ;var e=this[_0x8a37[696]](f,{title:h,callback:m,dropdown:l},true);var g=this[_0x8a37[746]](j);if(g[_0x8a37[497]]()!==0){g[_0x8a37[551]]()[_0x8a37[778]](c(_0x8a37[697])[_0x8a37[437]](e));} else {this[_0x8a37[333]][_0x8a37[437]](c(_0x8a37[697])[_0x8a37[437]](e));} ;return e;} ,buttonRemove:function (e){var f=this[_0x8a37[746]](e);f[_0x8a37[321]]();} ,buttonActiveObserver:function (h,l){var f=this[_0x8a37[543]]();this[_0x8a37[779]](l);if(h===false&&l!==_0x8a37[43]){if(c[_0x8a37[234]](l,this[_0x8a37[25]][_0x8a37[702]])!=-1){this[_0x8a37[780]](l);} ;return ;} ;if(f&&f[_0x8a37[368]]===_0x8a37[781]){this[_0x8a37[333]][_0x8a37[363]](_0x8a37[783])[_0x8a37[590]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[782]]);} else {this[_0x8a37[333]][_0x8a37[363]](_0x8a37[783])[_0x8a37[590]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[299]]);} ;c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[769]],c[_0x8a37[469]](function (e,m){if(c(f)[_0x8a37[732]](e,this[_0x8a37[323]][_0x8a37[317]]()[0])[_0x8a37[20]]!=0){this[_0x8a37[671]](m);} ;} ,this));var g=c(f)[_0x8a37[732]](this[_0x8a37[25]][_0x8a37[785]].toString()[_0x8a37[784]](),this[_0x8a37[323]][0]);if(g[_0x8a37[20]]){var j=g[_0x8a37[200]](_0x8a37[786]);switch(j){case _0x8a37[787]:this[_0x8a37[671]](_0x8a37[54]);break ;;case _0x8a37[788]:this[_0x8a37[671]](_0x8a37[53]);break ;;case _0x8a37[55]:this[_0x8a37[671]](_0x8a37[789]);break ;;default:this[_0x8a37[671]](_0x8a37[52]);break ;;} ;} ;} ,execPasteFrag:function (f){var l=this[_0x8a37[565]]();if(l[_0x8a37[790]]&&l[_0x8a37[566]]){var e=this[_0x8a37[563]]();e[_0x8a37[567]]();var g=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);g[_0x8a37[791]]=f;var n=this[_0x8a37[209]][_0x8a37[792]](),j,h;while((j=g[_0x8a37[794]])){h=n[_0x8a37[793]](j);} ;var m=n[_0x8a37[794]];e[_0x8a37[571]](n);if(h){e=e[_0x8a37[795]]();e[_0x8a37[796]](h);e[_0x8a37[657]](true);} ;l[_0x8a37[658]]();l[_0x8a37[659]](e);} ;} ,exec:function (f,g,e){if(f===_0x8a37[797]&&this[_0x8a37[239]](_0x8a37[238])){g=_0x8a37[367]+g+_0x8a37[798];} ;if(f===_0x8a37[799]&&this[_0x8a37[239]](_0x8a37[238])){if(!this[_0x8a37[800]]()){this[_0x8a37[753]]();this[_0x8a37[209]][_0x8a37[803]][_0x8a37[802]]()[_0x8a37[801]](g);} else {this[_0x8a37[804]](g);} ;} else {this[_0x8a37[209]][_0x8a37[471]](f,false,g);} ;if(e!==false){this[_0x8a37[355]]();} ;this[_0x8a37[389]](_0x8a37[471],f,g);} ,execCommand:function (g,h,f){if(!this[_0x8a37[25]][_0x8a37[474]]){this[_0x8a37[193]][_0x8a37[473]]();return false;} ;if(g===_0x8a37[36]||g===_0x8a37[37]||g===_0x8a37[51]||g===_0x8a37[266]){this[_0x8a37[511]]();} ;if(g===_0x8a37[652]||g===_0x8a37[653]){var e=this[_0x8a37[543]]();if(e[_0x8a37[368]]===_0x8a37[805]||e[_0x8a37[368]]===_0x8a37[806]){this[_0x8a37[807]](e);} ;} ;if(g===_0x8a37[799]){this[_0x8a37[808]](h,f);this[_0x8a37[389]](_0x8a37[471],g,h);return ;} ;if(this[_0x8a37[809]](_0x8a37[120])&&!this[_0x8a37[25]][_0x8a37[810]]){return false;} ;if(g===_0x8a37[268]||g===_0x8a37[270]){return this[_0x8a37[811]](g,h);} ;if(g===_0x8a37[301]){return this[_0x8a37[812]](g,h);} ;this[_0x8a37[743]](g,h,f);if(g===_0x8a37[310]){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[97])[_0x8a37[325]](_0x8a37[443]);} ;} ,execUnlink:function (f,g){this[_0x8a37[511]]();var e=this[_0x8a37[809]](_0x8a37[781]);if(e){c(e)[_0x8a37[371]](c(e)[_0x8a37[590]]());this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[471],f,g);return ;} ;} ,execLists:function (j,h){this[_0x8a37[511]]();var q=this[_0x8a37[543]]();var n=c(q)[_0x8a37[732]](_0x8a37[813]);if(!this[_0x8a37[814]](n)&&n[_0x8a37[497]]()!=0){n=false;} ;var m=false;if(n&&n[_0x8a37[20]]){m=true;var p=n[0][_0x8a37[368]];if((j===_0x8a37[268]&&p===_0x8a37[815])||(j===_0x8a37[270]&&p===_0x8a37[816])){m=false;} ;} ;this[_0x8a37[525]]();if(m){var f=this[_0x8a37[817]]();var g=this[_0x8a37[818]](f);if( typeof f[0]!=_0x8a37[12]&&f[_0x8a37[20]]>1&&f[0][_0x8a37[568]]==3){g[_0x8a37[819]](this[_0x8a37[545]]());} ;var l=_0x8a37[28],r=_0x8a37[28];c[_0x8a37[19]](g,c[_0x8a37[469]](function (v,w){if(w[_0x8a37[368]]==_0x8a37[119]){var u=c(w);var t=u[_0x8a37[602]]();t[_0x8a37[363]](_0x8a37[118],_0x8a37[113])[_0x8a37[321]]();if(this[_0x8a37[25]][_0x8a37[205]]===false){l+=this[_0x8a37[337]](c(_0x8a37[579])[_0x8a37[437]](t[_0x8a37[336]]()));} else {l+=t[_0x8a37[43]]()+_0x8a37[381];} ;if(v==0){u[_0x8a37[448]](_0x8a37[821])[_0x8a37[820]]();r=this[_0x8a37[337]](u);} else {u[_0x8a37[321]]();} ;} ;} ,this));html=this[_0x8a37[323]][_0x8a37[43]]()[_0x8a37[341]](r,_0x8a37[370]+p+_0x8a37[798]+l+_0x8a37[367]+p+_0x8a37[798]);this[_0x8a37[323]][_0x8a37[43]](html);this[_0x8a37[323]][_0x8a37[363]](p+_0x8a37[822])[_0x8a37[321]]();} else {var e=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[115]);this[_0x8a37[209]][_0x8a37[471]](j);var q=this[_0x8a37[543]]();var n=c(q)[_0x8a37[732]](_0x8a37[813]);if(e[_0x8a37[497]]()!=0){n[_0x8a37[824]](_0x8a37[823]);} ;if(n[_0x8a37[20]]){var o=n[_0x8a37[551]]();if(this[_0x8a37[814]](o)&&o[0][_0x8a37[368]]!=_0x8a37[119]&&this[_0x8a37[825]](o[0])){o[_0x8a37[371]](o[_0x8a37[336]]());} ;} ;if(this[_0x8a37[239]](_0x8a37[454])){this[_0x8a37[323]][_0x8a37[473]]();} ;} ;this[_0x8a37[530]]();this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[471],j,h);return ;} ,indentingIndent:function (){this[_0x8a37[826]](_0x8a37[42]);} ,indentingOutdent:function (){this[_0x8a37[826]](_0x8a37[41]);} ,indentingStart:function (h){this[_0x8a37[511]]();if(h===_0x8a37[42]){var j=this[_0x8a37[545]]();this[_0x8a37[525]]();if(j&&j[_0x8a37[368]]==_0x8a37[119]){var o=this[_0x8a37[543]]();var l=c(o)[_0x8a37[732]](_0x8a37[813]);var n=l[0][_0x8a37[368]];var f=this[_0x8a37[818]]();c[_0x8a37[19]](f,function (t,u){if(u[_0x8a37[368]]==_0x8a37[119]){var r=c(u)[_0x8a37[827]]();if(r[_0x8a37[497]]()!=0&&r[0][_0x8a37[368]]==_0x8a37[119]){var q=r[_0x8a37[335]](_0x8a37[828]);if(q[_0x8a37[497]]()==0){r[_0x8a37[437]](c(_0x8a37[367]+n+_0x8a37[798])[_0x8a37[437]](u));} else {q[_0x8a37[437]](u);} ;} ;} ;} );} else {if(j===false&&this[_0x8a37[25]][_0x8a37[205]]===true){this[_0x8a37[743]](_0x8a37[829],_0x8a37[57]);var p=this[_0x8a37[545]]();var j=c(_0x8a37[830])[_0x8a37[43]](c(p)[_0x8a37[43]]());c(p)[_0x8a37[371]](j);var g=this[_0x8a37[832]](c(j)[_0x8a37[200]](_0x8a37[831]))+this[_0x8a37[25]][_0x8a37[833]];c(j)[_0x8a37[200]](_0x8a37[831],g+_0x8a37[453]);} else {var e=this[_0x8a37[818]]();c[_0x8a37[19]](e,c[_0x8a37[469]](function (r,s){var q=false;if(s[_0x8a37[368]]===_0x8a37[86]){return ;} ;if(c[_0x8a37[234]](s[_0x8a37[368]],this[_0x8a37[25]][_0x8a37[785]])!==-1){q=c(s);} else {q=c(s)[_0x8a37[732]](this[_0x8a37[25]][_0x8a37[785]].toString()[_0x8a37[784]](),this[_0x8a37[323]][0]);} ;var t=this[_0x8a37[832]](q[_0x8a37[200]](_0x8a37[831]))+this[_0x8a37[25]][_0x8a37[833]];q[_0x8a37[200]](_0x8a37[831],t+_0x8a37[453]);} ,this));} ;} ;this[_0x8a37[530]]();} else {this[_0x8a37[525]]();var j=this[_0x8a37[545]]();if(j&&j[_0x8a37[368]]==_0x8a37[119]){var f=this[_0x8a37[818]]();var m=0;this[_0x8a37[834]](j,m,f);} else {var e=this[_0x8a37[818]]();c[_0x8a37[19]](e,c[_0x8a37[469]](function (r,s){var q=false;if(c[_0x8a37[234]](s[_0x8a37[368]],this[_0x8a37[25]][_0x8a37[785]])!==-1){q=c(s);} else {q=c(s)[_0x8a37[732]](this[_0x8a37[25]][_0x8a37[785]].toString()[_0x8a37[784]](),this[_0x8a37[323]][0]);} ;var t=this[_0x8a37[832]](q[_0x8a37[200]](_0x8a37[831]))-this[_0x8a37[25]][_0x8a37[833]];if(t<=0){if(this[_0x8a37[25]][_0x8a37[205]]===true&& typeof (q[_0x8a37[11]](_0x8a37[835]))!==_0x8a37[12]){q[_0x8a37[371]](q[_0x8a37[43]]());} else {q[_0x8a37[200]](_0x8a37[831],_0x8a37[28]);this[_0x8a37[836]](q,_0x8a37[69]);} ;} else {q[_0x8a37[200]](_0x8a37[831],t+_0x8a37[453]);} ;} ,this));} ;this[_0x8a37[530]]();} ;this[_0x8a37[355]]();} ,insideOutdent:function (e,g,f){if(e&&e[_0x8a37[368]]==_0x8a37[119]){var h=c(e)[_0x8a37[551]]()[_0x8a37[551]]();if(h[_0x8a37[497]]()!=0&&h[0][_0x8a37[368]]==_0x8a37[119]){h[_0x8a37[319]](e);} else {if( typeof f[g]!=_0x8a37[12]){e=f[g];g++;this[_0x8a37[834]](e,g,f);} else {this[_0x8a37[471]](_0x8a37[268]);} ;} ;} ;} ,alignmentLeft:function (){this[_0x8a37[838]](_0x8a37[28],_0x8a37[837]);} ,alignmentRight:function (){this[_0x8a37[838]](_0x8a37[787],_0x8a37[839]);} ,alignmentCenter:function (){this[_0x8a37[838]](_0x8a37[788],_0x8a37[840]);} ,alignmentJustify:function (){this[_0x8a37[838]](_0x8a37[55],_0x8a37[841]);} ,alignmentSet:function (f,h){this[_0x8a37[511]]();if(this[_0x8a37[842]]()){this[_0x8a37[209]][_0x8a37[471]](h,false,false);return true;} ;this[_0x8a37[525]]();var j=this[_0x8a37[545]]();if(!j&&this[_0x8a37[25]][_0x8a37[205]]){this[_0x8a37[743]](_0x8a37[797],_0x8a37[107]);var e=this[_0x8a37[545]]();var j=c(_0x8a37[830])[_0x8a37[43]](c(e)[_0x8a37[43]]());c(e)[_0x8a37[371]](j);c(j)[_0x8a37[200]](_0x8a37[786],f);this[_0x8a37[836]](j,_0x8a37[69]);if(f==_0x8a37[28]&& typeof (c(j)[_0x8a37[11]](_0x8a37[835]))!==_0x8a37[12]){c(j)[_0x8a37[371]](c(j)[_0x8a37[43]]());} ;} else {var g=this[_0x8a37[818]]();c[_0x8a37[19]](g,c[_0x8a37[469]](function (m,n){var l=false;if(c[_0x8a37[234]](n[_0x8a37[368]],this[_0x8a37[25]][_0x8a37[785]])!==-1){l=c(n);} else {l=c(n)[_0x8a37[732]](this[_0x8a37[25]][_0x8a37[785]].toString()[_0x8a37[784]](),this[_0x8a37[323]][0]);} ;if(l){l[_0x8a37[200]](_0x8a37[786],f);this[_0x8a37[836]](l,_0x8a37[69]);} ;} ,this));} ;this[_0x8a37[530]]();this[_0x8a37[355]]();} ,cleanEmpty:function (e){var f=this[_0x8a37[843]](e);if(f!==false){return f;} ;if(this[_0x8a37[25]][_0x8a37[205]]===false){if(e===_0x8a37[28]){e=this[_0x8a37[25]][_0x8a37[649]];} else {if(e[_0x8a37[593]](/^<hr\s?\/?>$/gi)!==-1){e=_0x8a37[844]+this[_0x8a37[25]][_0x8a37[649]];} ;} ;} ;return e;} ,cleanConverters:function (e){if(this[_0x8a37[25]][_0x8a37[845]]){e=e[_0x8a37[341]](/<div(.*?)>([\w\W]*?)<\/div>/gi,_0x8a37[846]);} ;if(this[_0x8a37[25]][_0x8a37[206]]){e=this[_0x8a37[847]](e);} ;return e;} ,cleanConvertProtected:function (e){if(this[_0x8a37[25]][_0x8a37[848]]){e=e[_0x8a37[341]](/\{\{(.*?)\}\}/gi,_0x8a37[849]);e=e[_0x8a37[341]](/\{(.*?)\}/gi,_0x8a37[850]);} ;e=e[_0x8a37[341]](/<script(.*?)>([\w\W]*?)<\/script>/gi,_0x8a37[851]);e=e[_0x8a37[341]](/<style(.*?)>([\w\W]*?)<\/style>/gi,_0x8a37[852]);e=e[_0x8a37[341]](/<form(.*?)>([\w\W]*?)<\/form>/gi,_0x8a37[853]);if(this[_0x8a37[25]][_0x8a37[854]]){e=e[_0x8a37[341]](/<\?php([\w\W]*?)\?>/gi,_0x8a37[855]);} else {e=e[_0x8a37[341]](/<\?php([\w\W]*?)\?>/gi,_0x8a37[28]);} ;return e;} ,cleanReConvertProtected:function (e){if(this[_0x8a37[25]][_0x8a37[848]]){e=e[_0x8a37[341]](/<!-- template double (.*?) -->/gi,_0x8a37[856]);e=e[_0x8a37[341]](/<!-- template (.*?) -->/gi,_0x8a37[857]);} ;e=e[_0x8a37[341]](/<title type="text\/javascript" style="display: none;" class="redactor-script-tag"(.*?)>([\w\W]*?)<\/title>/gi,_0x8a37[858]);e=e[_0x8a37[341]](/<section(.*?) style="display: none;" rel="redactor-style-tag">([\w\W]*?)<\/section>/gi,_0x8a37[859]);e=e[_0x8a37[341]](/<section(.*?)rel="redactor-form-tag"(.*?)>([\w\W]*?)<\/section>/gi,_0x8a37[860]);if(this[_0x8a37[25]][_0x8a37[854]]){e=e[_0x8a37[341]](/<section style="display: none;" rel="redactor-php-tag">([\w\W]*?)<\/section>/gi,_0x8a37[861]);} ;return e;} ,cleanRemoveSpaces:function (f,e){if(e!==false){var e=[];var h=f[_0x8a37[600]](/<(pre|style|script|title)(.*?)>([\w\W]*?)<\/(pre|style|script|title)>/gi);if(h===null){h=[];} ;if(this[_0x8a37[25]][_0x8a37[854]]){var g=f[_0x8a37[600]](/<\?php([\w\W]*?)\?>/gi);if(g){h=c[_0x8a37[862]](h,g);} ;} ;if(h){c[_0x8a37[19]](h,function (j,l){f=f[_0x8a37[341]](l,_0x8a37[863]+j);e[_0x8a37[15]](l);} );} ;} ;f=f[_0x8a37[341]](/\n/g,_0x8a37[864]);f=f[_0x8a37[341]](/[\t]*/g,_0x8a37[28]);f=f[_0x8a37[341]](/\n\s*\n/g,_0x8a37[591]);f=f[_0x8a37[341]](/^[\s\n]*/g,_0x8a37[864]);f=f[_0x8a37[341]](/[\s\n]*$/g,_0x8a37[864]);f=f[_0x8a37[341]](/>\s{2,}</g,_0x8a37[865]);f=this[_0x8a37[866]](f,e);f=f[_0x8a37[341]](/\n\n/g,_0x8a37[591]);return f;} ,cleanReplacer:function (f,e){if(e===false){return f;} ;c[_0x8a37[19]](e,function (g,h){f=f[_0x8a37[341]](_0x8a37[863]+g,h);} );return f;} ,cleanRemoveEmptyTags:function (h){h=h[_0x8a37[341]](/<span>([\w\W]*?)<\/span>/gi,_0x8a37[413]);h=h[_0x8a37[341]](/[\u200B-\u200D\uFEFF]/g,_0x8a37[28]);var j=[_0x8a37[867],_0x8a37[868],_0x8a37[869]];var g=[_0x8a37[870],_0x8a37[871],_0x8a37[872],_0x8a37[873],_0x8a37[874],_0x8a37[875],_0x8a37[876],_0x8a37[877],_0x8a37[878],_0x8a37[879],_0x8a37[880],_0x8a37[881],_0x8a37[395],_0x8a37[397],_0x8a37[882],_0x8a37[883],_0x8a37[884]];if(this[_0x8a37[25]][_0x8a37[885]]){g=g[_0x8a37[886]](j);} else {g=j;} ;var e=g[_0x8a37[20]];for(var f=0;f<e;++f){h=h[_0x8a37[341]]( new RegExp(g[f],_0x8a37[369]),_0x8a37[28]);} ;return h;} ,cleanParagraphy:function (l){l=c[_0x8a37[380]](l);if(this[_0x8a37[25]][_0x8a37[205]]===true){return l;} ;if(l===_0x8a37[28]||l===_0x8a37[395]){return this[_0x8a37[25]][_0x8a37[649]];} ;l=l+_0x8a37[591];if(this[_0x8a37[25]][_0x8a37[885]]===false){return l;} ;var n=[];var j=l[_0x8a37[600]](/<(table|div|pre|object)(.*?)>([\w\W]*?)<\/(table|div|pre|object)>/gi);if(!j){j=[];} ;var m=l[_0x8a37[600]](/<!--([\w\W]*?)-->/gi);if(m){j=c[_0x8a37[862]](j,m);} ;if(this[_0x8a37[25]][_0x8a37[854]]){var f=l[_0x8a37[600]](/<section(.*?)rel="redactor-php-tag">([\w\W]*?)<\/section>/gi);if(f){j=c[_0x8a37[862]](j,f);} ;} ;if(j){c[_0x8a37[19]](j,function (p,q){n[p]=q;l=l[_0x8a37[341]](q,_0x8a37[887]+p+_0x8a37[888]);} );} ;l=l[_0x8a37[341]](/<br \/>\s*<br \/>/gi,_0x8a37[889]);function h(s,p,q){return l[_0x8a37[341]]( new RegExp(s,p),q);} ;var e=_0x8a37[890];l=h(_0x8a37[891]+e+_0x8a37[892],_0x8a37[369],_0x8a37[893]);l=h(_0x8a37[894]+e+_0x8a37[895],_0x8a37[369],_0x8a37[896]);l=h(_0x8a37[897],_0x8a37[898],_0x8a37[591]);l=h(_0x8a37[899],_0x8a37[898],_0x8a37[591]);l=h(_0x8a37[900],_0x8a37[898],_0x8a37[889]);var o=l[_0x8a37[445]]( new RegExp(_0x8a37[901],_0x8a37[898]),-1);l=_0x8a37[28];for(var g in o){if(o[_0x8a37[902]](g)){if(o[g][_0x8a37[593]](_0x8a37[887])==-1){o[g]=o[g][_0x8a37[341]](/<p>\n\t<\/p>/gi,_0x8a37[28]);o[g]=o[g][_0x8a37[341]](/<p><\/p>/gi,_0x8a37[28]);if(o[g]!=_0x8a37[28]){l+=_0x8a37[579]+o[g][_0x8a37[341]](/^\n+|\n+$/g,_0x8a37[28])+_0x8a37[581];} ;} else {l+=o[g];} ;} ;} ;l=h(_0x8a37[903],_0x8a37[369],_0x8a37[579]);l=h(_0x8a37[904],_0x8a37[369],_0x8a37[581]);l=h(_0x8a37[905],_0x8a37[369],_0x8a37[28]);l=h(_0x8a37[906],_0x8a37[369],_0x8a37[907]);l=h(_0x8a37[908]+e+_0x8a37[909],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[910],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[911]+e+_0x8a37[892],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[912]+e+_0x8a37[913],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[912]+e+_0x8a37[914],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[915],_0x8a37[369],_0x8a37[413]);l=h(_0x8a37[916],_0x8a37[369],_0x8a37[581]);l=h(_0x8a37[917],_0x8a37[369],_0x8a37[697]);l=h(_0x8a37[918],_0x8a37[369],_0x8a37[919]);l=h(_0x8a37[920],_0x8a37[369],_0x8a37[919]);l=h(_0x8a37[921],_0x8a37[369],_0x8a37[579]);l=h(_0x8a37[922],_0x8a37[369],_0x8a37[923]);l=h(_0x8a37[924],_0x8a37[369],_0x8a37[925]);l=h(_0x8a37[926],_0x8a37[369],_0x8a37[927]);l=h(_0x8a37[928],_0x8a37[369],_0x8a37[28]);c[_0x8a37[19]](n,function (p,q){l=l[_0x8a37[341]](_0x8a37[887]+p+_0x8a37[929],q);} );return c[_0x8a37[380]](l);} ,cleanConvertInlineTags:function (e,h){var f=_0x8a37[71];if(this[_0x8a37[25]][_0x8a37[930]]===_0x8a37[232]){f=_0x8a37[232];} ;var g=_0x8a37[72];if(this[_0x8a37[25]][_0x8a37[931]]===_0x8a37[229]){g=_0x8a37[229];} ;e=e[_0x8a37[341]](/<span style="font-style: italic;">([\w\W]*?)<\/span>/gi,_0x8a37[367]+g+_0x8a37[932]+g+_0x8a37[798]);e=e[_0x8a37[341]](/<span style="font-weight: bold;">([\w\W]*?)<\/span>/gi,_0x8a37[367]+f+_0x8a37[932]+f+_0x8a37[798]);if(this[_0x8a37[25]][_0x8a37[930]]===_0x8a37[71]){e=e[_0x8a37[341]](/<b>([\w\W]*?)<\/b>/gi,_0x8a37[933]);} else {e=e[_0x8a37[341]](/<strong>([\w\W]*?)<\/strong>/gi,_0x8a37[934]);} ;if(this[_0x8a37[25]][_0x8a37[931]]===_0x8a37[72]){e=e[_0x8a37[341]](/<i>([\w\W]*?)<\/i>/gi,_0x8a37[935]);} else {e=e[_0x8a37[341]](/<em>([\w\W]*?)<\/em>/gi,_0x8a37[936]);} ;if(h!==true){e=e[_0x8a37[341]](/<strike>([\w\W]*?)<\/strike>/gi,_0x8a37[937]);} else {e=e[_0x8a37[341]](/<del>([\w\W]*?)<\/del>/gi,_0x8a37[938]);} ;return e;} ,cleanStripTags:function (g){if(g==_0x8a37[28]|| typeof g==_0x8a37[12]){return g;} ;var h=false;if(this[_0x8a37[25]][_0x8a37[230]]!==false){h=true;} ;var e=h===true?this[_0x8a37[25]][_0x8a37[230]]:this[_0x8a37[25]][_0x8a37[236]];var f=/<\/?([a-z][a-z0-9]*)\b[^>]*>/gi;g=g[_0x8a37[341]](f,function (l,j){if(h===true){return c[_0x8a37[234]](j[_0x8a37[784]](),e)>_0x8a37[235]?l:_0x8a37[28];} else {return c[_0x8a37[234]](j[_0x8a37[784]](),e)>_0x8a37[235]?_0x8a37[28]:l;} ;} );g=this[_0x8a37[348]](g);return g;} ,cleanSavePreCode:function (e,f){var g=e[_0x8a37[600]](/<(pre|code)(.*?)>([\w\W]*?)<\/(pre|code)>/gi);if(g!==null){c[_0x8a37[19]](g,c[_0x8a37[469]](function (j,l){var h=l[_0x8a37[600]](/<(pre|code)(.*?)>([\w\W]*?)<\/(pre|code)>/i);h[3]=h[3][_0x8a37[341]](/&nbsp;/g,_0x8a37[864]);if(f!==false){h[3]=this[_0x8a37[939]](h[3]);} ;h[3]=h[3][_0x8a37[341]](/\$/g,_0x8a37[340]);e=e[_0x8a37[341]](l,_0x8a37[367]+h[1]+h[2]+_0x8a37[798]+h[3]+_0x8a37[370]+h[1]+_0x8a37[798]);} ,this));} ;return e;} ,cleanEncodeEntities:function (e){e=String(e)[_0x8a37[341]](/&amp;/g,_0x8a37[414])[_0x8a37[341]](/&lt;/g,_0x8a37[367])[_0x8a37[341]](/&gt;/g,_0x8a37[798])[_0x8a37[341]](/&quot;/g,_0x8a37[940]);return e[_0x8a37[341]](/&/g,_0x8a37[944])[_0x8a37[341]](/</g,_0x8a37[943])[_0x8a37[341]](/>/g,_0x8a37[942])[_0x8a37[341]](/"/g,_0x8a37[941]);} ,cleanUnverified:function (){var e=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[945]);e[_0x8a37[949]](_0x8a37[948])[_0x8a37[200]](_0x8a37[947],_0x8a37[28])[_0x8a37[200]](_0x8a37[946],_0x8a37[28]);e[_0x8a37[949]](_0x8a37[950])[_0x8a37[200]](_0x8a37[947],_0x8a37[28]);e[_0x8a37[200]](_0x8a37[946],_0x8a37[28]);c[_0x8a37[19]](e,c[_0x8a37[469]](function (f,g){this[_0x8a37[836]](g,_0x8a37[69]);} ,this));this[_0x8a37[323]][_0x8a37[363]](_0x8a37[952])[_0x8a37[336]]()[_0x8a37[951]]();this[_0x8a37[323]][_0x8a37[363]](_0x8a37[953])[_0x8a37[325]](_0x8a37[69]);} ,cleanHtml:function (f){var j=0,m=f[_0x8a37[20]],l=0,e=null,g=null,p=_0x8a37[28],h=_0x8a37[28],o=_0x8a37[28];this[_0x8a37[954]]=0;for(;j<m;j++){l=j;if(-1==f[_0x8a37[955]](j)[_0x8a37[510]](_0x8a37[367])){h+=f[_0x8a37[955]](j);return this[_0x8a37[956]](h);} ;while(l<m&&f[_0x8a37[957]](l)!=_0x8a37[367]){l++;} ;if(j!=l){o=f[_0x8a37[955]](j,l-j);if(!o[_0x8a37[600]](/^\s{2,}$/g)){if(_0x8a37[591]==h[_0x8a37[957]](h[_0x8a37[20]]-1)){h+=this[_0x8a37[958]]();} else {if(_0x8a37[591]==o[_0x8a37[957]](0)){h+=_0x8a37[591]+this[_0x8a37[958]]();o=o[_0x8a37[341]](/^\s+/,_0x8a37[28]);} ;} ;h+=o;} ;if(o[_0x8a37[600]](/\n/)){h+=_0x8a37[591]+this[_0x8a37[958]]();} ;} ;e=l;while(l<m&&_0x8a37[798]!=f[_0x8a37[957]](l)){l++;} ;p=f[_0x8a37[955]](e,l-e);j=l;var n;if(_0x8a37[959]==p[_0x8a37[955]](1,3)){if(!p[_0x8a37[600]](/--$/)){while(_0x8a37[960]!=f[_0x8a37[955]](l,3)){l++;} ;l+=2;p=f[_0x8a37[955]](e,l-e);j=l;} ;if(_0x8a37[591]!=h[_0x8a37[957]](h[_0x8a37[20]]-1)){h+=_0x8a37[591];} ;h+=this[_0x8a37[958]]();h+=p+_0x8a37[961];} else {if(_0x8a37[962]==p[1]){h=this[_0x8a37[963]](p+_0x8a37[798],h);} else {if(_0x8a37[964]==p[1]){h+=p+_0x8a37[961];} else {if(n=p[_0x8a37[600]](/^<(script|style|pre)/i)){n[1]=n[1][_0x8a37[784]]();p=this[_0x8a37[965]](p);h=this[_0x8a37[963]](p,h);g=String(f[_0x8a37[955]](j+1))[_0x8a37[784]]()[_0x8a37[510]](_0x8a37[370]+n[1]);if(g){o=f[_0x8a37[955]](j+1,g);j+=g;h+=o;} ;} else {p=this[_0x8a37[965]](p);h=this[_0x8a37[963]](p,h);} ;} ;} ;} ;} ;return this[_0x8a37[956]](h);} ,cleanGetTabs:function (){var f=_0x8a37[28];for(var e=0;e<this[_0x8a37[954]];e++){f+=_0x8a37[597];} ;return f;} ,cleanFinish:function (e){e=e[_0x8a37[341]](/\n\s*\n/g,_0x8a37[591]);e=e[_0x8a37[341]](/^[\s\n]*/,_0x8a37[28]);e=e[_0x8a37[341]](/[\s\n]*$/,_0x8a37[28]);e=e[_0x8a37[341]](/<script(.*?)>\n<\/script>/gi,_0x8a37[966]);this[_0x8a37[954]]=0;return e;} ,cleanTag:function (f){var h=_0x8a37[28];f=f[_0x8a37[341]](/\n/g,_0x8a37[864]);f=f[_0x8a37[341]](/\s{2,}/g,_0x8a37[864]);f=f[_0x8a37[341]](/^\s+|\s+$/g,_0x8a37[864]);var g=_0x8a37[28];if(f[_0x8a37[600]](/\/$/)){g=_0x8a37[967];f=f[_0x8a37[341]](/\/+$/,_0x8a37[28]);} ;var e;while(e=/\s*([^= ]+)(?:=((['"']).*?\3|[^ ]+))?/[_0x8a37[743]](f)){if(e[2]){h+=e[1][_0x8a37[784]]()+_0x8a37[675]+e[2];} else {if(e[1]){h+=e[1][_0x8a37[784]]();} ;} ;h+=_0x8a37[864];f=f[_0x8a37[955]](e[0][_0x8a37[20]]);} ;return h[_0x8a37[341]](/\s*$/,_0x8a37[28])+g+_0x8a37[798];} ,placeTag:function (e,g){var f=e[_0x8a37[600]](this[_0x8a37[222]]);if(e[_0x8a37[600]](this[_0x8a37[212]])||f){g=g[_0x8a37[341]](/\s*$/,_0x8a37[28]);g+=_0x8a37[591];} ;if(f&&_0x8a37[967]==e[_0x8a37[957]](1)){this[_0x8a37[954]]--;} ;if(_0x8a37[591]==g[_0x8a37[957]](g[_0x8a37[20]]-1)){g+=this[_0x8a37[958]]();} ;if(f&&_0x8a37[967]!=e[_0x8a37[957]](1)){this[_0x8a37[954]]++;} ;g+=e;if(e[_0x8a37[600]](this[_0x8a37[219]])||e[_0x8a37[600]](this[_0x8a37[222]])){g=g[_0x8a37[341]](/ *$/,_0x8a37[28]);g+=_0x8a37[591];} ;return g;} ,formatEmpty:function (j){var f=c[_0x8a37[380]](this[_0x8a37[323]][_0x8a37[43]]());if(this[_0x8a37[25]][_0x8a37[205]]){if(f==_0x8a37[28]){j[_0x8a37[507]]();this[_0x8a37[323]][_0x8a37[43]](_0x8a37[28]);this[_0x8a37[473]]();} ;} else {f=f[_0x8a37[341]](/<br\s?\/?>/i,_0x8a37[28]);var h=f[_0x8a37[341]](/<p>\s?<\/p>/gi,_0x8a37[28]);if(f===_0x8a37[28]||h===_0x8a37[28]){j[_0x8a37[507]]();var g=c(this[_0x8a37[25]][_0x8a37[649]])[_0x8a37[317]](0);this[_0x8a37[323]][_0x8a37[43]](g);this[_0x8a37[473]]();} ;} ;this[_0x8a37[355]]();} ,formatBlocks:function (e){this[_0x8a37[511]]();var f=this[_0x8a37[818]]();this[_0x8a37[525]]();c[_0x8a37[19]](f,c[_0x8a37[469]](function (g,j){if(j[_0x8a37[368]]!==_0x8a37[119]){var h=c(j)[_0x8a37[551]]();if(e===_0x8a37[56]){if((j[_0x8a37[368]]===_0x8a37[75]&&h[_0x8a37[497]]()!=0&&h[0][_0x8a37[368]]===_0x8a37[87])||j[_0x8a37[368]]===_0x8a37[87]){this[_0x8a37[252]]();return ;} else {if(this[_0x8a37[25]][_0x8a37[205]]){if(j&&j[_0x8a37[368]][_0x8a37[593]](/H[1-6]/)==0){c(j)[_0x8a37[371]](j[_0x8a37[791]]+_0x8a37[381]);} else {return ;} ;} else {this[_0x8a37[829]](e,j);} ;} ;} else {this[_0x8a37[829]](e,j);} ;} ;} ,this));this[_0x8a37[530]]();this[_0x8a37[355]]();} ,formatBlock:function (e,j){if(j===false){j=this[_0x8a37[545]]();} ;if(j===false&&this[_0x8a37[25]][_0x8a37[205]]===true){this[_0x8a37[471]](_0x8a37[797],e);return true;} ;var h=_0x8a37[28];if(e!==_0x8a37[58]){h=c(j)[_0x8a37[336]]();} else {h=c(j)[_0x8a37[43]]();if(c[_0x8a37[380]](h)===_0x8a37[28]){h=_0x8a37[968];} ;} ;if(j[_0x8a37[368]]===_0x8a37[120]){e=_0x8a37[56];} ;if(this[_0x8a37[25]][_0x8a37[205]]===true&&e===_0x8a37[56]){c(j)[_0x8a37[371]](c(_0x8a37[969])[_0x8a37[437]](h)[_0x8a37[43]]()+_0x8a37[381]);} else {var f=this[_0x8a37[543]]();var g=c(_0x8a37[367]+e+_0x8a37[798])[_0x8a37[437]](h);c(j)[_0x8a37[371]](g);if(f&&f[_0x8a37[368]]==_0x8a37[86]){c(g)[_0x8a37[824]](_0x8a37[823]);} ;} ;} ,formatChangeTag:function (g,e,f){if(f!==false){this[_0x8a37[525]]();} ;var h=c(_0x8a37[367]+e+_0x8a37[970]);c(g)[_0x8a37[371]](function (){return h[_0x8a37[437]](c(this)[_0x8a37[336]]());} );if(f!==false){this[_0x8a37[530]]();} ;return h;} ,formatQuote:function (){this[_0x8a37[511]]();if(this[_0x8a37[25]][_0x8a37[205]]===false){this[_0x8a37[525]]();var e=this[_0x8a37[818]]();var p=false;var u=e[_0x8a37[20]];if(e){var m=_0x8a37[28];var v=_0x8a37[28];var h=false;var r=true;c[_0x8a37[19]](e,function (w,x){if(x[_0x8a37[368]]!==_0x8a37[75]){r=false;} ;} );c[_0x8a37[19]](e,c[_0x8a37[469]](function (w,x){if(x[_0x8a37[368]]===_0x8a37[87]){this[_0x8a37[829]](_0x8a37[56],x,false);} else {if(x[_0x8a37[368]]===_0x8a37[75]){p=c(x)[_0x8a37[551]]();if(p[0][_0x8a37[368]]==_0x8a37[87]){var y=c(p)[_0x8a37[335]](_0x8a37[56])[_0x8a37[497]]();if(y==1){c(p)[_0x8a37[371]](x);} else {if(y==u){h=_0x8a37[57];m+=this[_0x8a37[337]](x);} else {h=_0x8a37[43];m+=this[_0x8a37[337]](x);if(w==0){c(x)[_0x8a37[448]](_0x8a37[821])[_0x8a37[820]]();v=this[_0x8a37[337]](x);} else {c(x)[_0x8a37[321]]();} ;} ;} ;} else {if(r===false||e[_0x8a37[20]]==1){this[_0x8a37[829]](_0x8a37[57],x,false);} else {h=_0x8a37[971];m+=this[_0x8a37[337]](x);} ;} ;} else {if(x[_0x8a37[368]]!==_0x8a37[119]){this[_0x8a37[829]](_0x8a37[57],x,false);} ;} ;} ;} ,this));if(h){if(h==_0x8a37[971]){c(e[0])[_0x8a37[371]](_0x8a37[972]+m+_0x8a37[927]);c(e)[_0x8a37[321]]();} else {if(h==_0x8a37[57]){c(p)[_0x8a37[371]](m);} else {if(h==_0x8a37[43]){var o=this[_0x8a37[323]][_0x8a37[43]]()[_0x8a37[341]](v,_0x8a37[927]+m+_0x8a37[972]);this[_0x8a37[323]][_0x8a37[43]](o);this[_0x8a37[323]][_0x8a37[363]](_0x8a37[57])[_0x8a37[19]](function (){if(c[_0x8a37[380]](c(this)[_0x8a37[43]]())==_0x8a37[28]){c(this)[_0x8a37[321]]();} ;} );} ;} ;} ;} ;} ;this[_0x8a37[530]]();} else {var j=this[_0x8a37[545]]();if(j[_0x8a37[368]]===_0x8a37[87]){this[_0x8a37[525]]();var o=c[_0x8a37[380]](c(j)[_0x8a37[43]]());var s=c[_0x8a37[380]](this[_0x8a37[973]]());o=o[_0x8a37[341]](/<span(.*?)id="selection-marker(.*?)<\/span>/gi,_0x8a37[28]);if(o==s){c(j)[_0x8a37[371]](c(j)[_0x8a37[43]]()+_0x8a37[381]);} else {this[_0x8a37[975]](_0x8a37[974]);var l=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[974]);l[_0x8a37[820]]();var q=this[_0x8a37[323]][_0x8a37[43]]()[_0x8a37[341]](_0x8a37[976],_0x8a37[977]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412]+s+_0x8a37[972]);this[_0x8a37[323]][_0x8a37[43]](q);l[_0x8a37[321]]();this[_0x8a37[323]][_0x8a37[363]](_0x8a37[57])[_0x8a37[19]](function (){if(c[_0x8a37[380]](c(this)[_0x8a37[43]]())==_0x8a37[28]){c(this)[_0x8a37[321]]();} ;} );} ;this[_0x8a37[530]]();this[_0x8a37[323]][_0x8a37[363]](_0x8a37[978])[_0x8a37[339]](_0x8a37[443],false);} else {var g=this[_0x8a37[979]](_0x8a37[57]);var o=c(g)[_0x8a37[43]]();var t=[_0x8a37[118],_0x8a37[113],_0x8a37[46],_0x8a37[117],_0x8a37[100],_0x8a37[101],_0x8a37[102],_0x8a37[108]];c[_0x8a37[19]](t,function (w,x){o=o[_0x8a37[341]]( new RegExp(_0x8a37[367]+x+_0x8a37[980],_0x8a37[369]),_0x8a37[28]);o=o[_0x8a37[341]]( new RegExp(_0x8a37[370]+x+_0x8a37[798],_0x8a37[369]),_0x8a37[28]);} );var f=this[_0x8a37[25]][_0x8a37[227]];c[_0x8a37[19]](f,function (w,x){o=o[_0x8a37[341]]( new RegExp(_0x8a37[367]+x+_0x8a37[980],_0x8a37[369]),_0x8a37[28]);o=o[_0x8a37[341]]( new RegExp(_0x8a37[370]+x+_0x8a37[798],_0x8a37[369]),_0x8a37[381]);} );c(g)[_0x8a37[43]](o);this[_0x8a37[981]](g);var n=c(g)[_0x8a37[603]]();if(n[_0x8a37[497]]()!=0&&n[0][_0x8a37[368]]===_0x8a37[604]){n[_0x8a37[321]]();} ;} ;} ;this[_0x8a37[355]]();} ,blockRemoveAttr:function (e,g){var f=this[_0x8a37[818]]();c(f)[_0x8a37[325]](e);this[_0x8a37[355]]();} ,blockSetAttr:function (e,g){var f=this[_0x8a37[818]]();c(f)[_0x8a37[339]](e,g);this[_0x8a37[355]]();} ,blockRemoveStyle:function (f){var e=this[_0x8a37[818]]();c(e)[_0x8a37[200]](f,_0x8a37[28]);this[_0x8a37[836]](e,_0x8a37[69]);this[_0x8a37[355]]();} ,blockSetStyle:function (g,f){var e=this[_0x8a37[818]]();c(e)[_0x8a37[200]](g,f);this[_0x8a37[355]]();} ,blockRemoveClass:function (f){var e=this[_0x8a37[818]]();c(e)[_0x8a37[327]](f);this[_0x8a37[836]](e,_0x8a37[982]);this[_0x8a37[355]]();} ,blockSetClass:function (f){var e=this[_0x8a37[818]]();c(e)[_0x8a37[448]](f);this[_0x8a37[355]]();} ,inlineRemoveClass:function (e){this[_0x8a37[525]]();this[_0x8a37[983]](function (f){c(f)[_0x8a37[327]](e);this[_0x8a37[836]](f,_0x8a37[982]);} );this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineSetClass:function (e){var f=this[_0x8a37[544]]();if(!c(f)[_0x8a37[496]](e)){this[_0x8a37[984]](_0x8a37[448],e);} ;} ,inlineRemoveStyle:function (e){this[_0x8a37[525]]();this[_0x8a37[983]](function (f){c(f)[_0x8a37[200]](e,_0x8a37[28]);this[_0x8a37[836]](f,_0x8a37[69]);} );this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineSetStyle:function (f,e){this[_0x8a37[984]](_0x8a37[200],f,e);} ,inlineRemoveAttr:function (e){this[_0x8a37[525]]();var g=this[_0x8a37[563]](),h=this[_0x8a37[722]](),f=this[_0x8a37[817]]();if(g[_0x8a37[564]]||g[_0x8a37[985]]===g[_0x8a37[986]]&&h){f=c(h);} ;c(f)[_0x8a37[325]](e);this[_0x8a37[987]]();this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineSetAttr:function (e,f){this[_0x8a37[984]](_0x8a37[339],e,f);} ,inlineMethods:function (h,e,j){this[_0x8a37[511]]();this[_0x8a37[525]]();var f=this[_0x8a37[563]]();var g=this[_0x8a37[722]]();if((f[_0x8a37[564]]||f[_0x8a37[985]]===f[_0x8a37[986]])&&g&&!this[_0x8a37[825]](g)){c(g)[h](e,j);} else {this[_0x8a37[209]][_0x8a37[471]](_0x8a37[988],false,4);var l=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[989]);c[_0x8a37[19]](l,c[_0x8a37[469]](function (m,n){this[_0x8a37[990]](h,n,e,j);} ,this));} ;this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineSetMethods:function (j,o,g,l){var m=c(o)[_0x8a37[551]](),e;var n=this[_0x8a37[718]]();var h=c(m)[_0x8a37[590]]();var f=n==h;if(f&&m&&m[0][_0x8a37[368]]===_0x8a37[991]&&m[0][_0x8a37[992]][_0x8a37[20]]!=0){e=m;c(o)[_0x8a37[371]](c(o)[_0x8a37[43]]());} else {e=c(_0x8a37[993])[_0x8a37[437]](c(o)[_0x8a37[336]]());c(o)[_0x8a37[371]](e);} ;c(e)[j](g,l);return e;} ,inlineEachNodes:function (j){var f=this[_0x8a37[563]](),g=this[_0x8a37[722]](),e=this[_0x8a37[817]](),h;if(f[_0x8a37[564]]||f[_0x8a37[985]]===f[_0x8a37[986]]&&g){e=c(g);h=true;} ;c[_0x8a37[19]](e,c[_0x8a37[469]](function (m,o){if(!h&&o[_0x8a37[368]]!==_0x8a37[991]){var l=this[_0x8a37[718]]();var p=c(o)[_0x8a37[551]]()[_0x8a37[590]]();var n=l==p;if(n&&o[_0x8a37[994]][_0x8a37[368]]===_0x8a37[991]&&!c(o[_0x8a37[994]])[_0x8a37[496]](_0x8a37[328])){o=o[_0x8a37[994]];} else {return ;} ;} ;j[_0x8a37[8]](this,o);} ,this));} ,inlineUnwrapSpan:function (){var e=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[365]);c[_0x8a37[19]](e,c[_0x8a37[469]](function (g,h){var f=c(h);if(f[_0x8a37[339]](_0x8a37[982])===undefined&&f[_0x8a37[339]](_0x8a37[69])===undefined){f[_0x8a37[336]]()[_0x8a37[951]]();} ;} ,this));} ,inlineFormat:function (e){this[_0x8a37[525]]();this[_0x8a37[209]][_0x8a37[471]](_0x8a37[988],false,4);var g=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[989]);var f;c[_0x8a37[19]](g,function (h,l){var j=c(_0x8a37[367]+e+_0x8a37[970])[_0x8a37[437]](c(l)[_0x8a37[336]]());c(l)[_0x8a37[371]](j);f=j;} );this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineRemoveFormat:function (e){this[_0x8a37[525]]();var f=e[_0x8a37[995]]();var g=this[_0x8a37[817]]();var h=c(this[_0x8a37[543]]())[_0x8a37[551]]();c[_0x8a37[19]](g,function (j,l){if(l[_0x8a37[368]]===f){this[_0x8a37[807]](l);} ;} );if(h&&h[0][_0x8a37[368]]===f){this[_0x8a37[807]](h);} ;this[_0x8a37[530]]();this[_0x8a37[355]]();} ,inlineRemoveFormatReplace:function (e){c(e)[_0x8a37[371]](c(e)[_0x8a37[336]]());} ,insertHtml:function (g,j){var m=this[_0x8a37[544]]();var h=m[_0x8a37[994]];this[_0x8a37[753]]();this[_0x8a37[511]]();var e=c(_0x8a37[969])[_0x8a37[437]](c[_0x8a37[996]](g));g=e[_0x8a37[43]]();g=this[_0x8a37[378]](g);e=c(_0x8a37[969])[_0x8a37[437]](c[_0x8a37[996]](g));var f=this[_0x8a37[545]]();if(e[_0x8a37[336]]()[_0x8a37[20]]==1){var l=e[_0x8a37[336]]()[0][_0x8a37[368]];if(l!=_0x8a37[75]&&l==f[_0x8a37[368]]||l==_0x8a37[120]){e=c(_0x8a37[969])[_0x8a37[437]](g);} ;} ;if(this[_0x8a37[25]][_0x8a37[205]]){g=g[_0x8a37[341]](/<p(.*?)>([\w\W]*?)<\/p>/gi,_0x8a37[350]);} ;if(!this[_0x8a37[25]][_0x8a37[205]]&&e[_0x8a37[336]]()[_0x8a37[20]]==1&&e[_0x8a37[336]]()[0][_0x8a37[568]]==3&&(this[_0x8a37[997]]()[_0x8a37[20]]>2||(!m||m[_0x8a37[368]]==_0x8a37[601]&&!h||h[_0x8a37[368]]==_0x8a37[121]))){g=_0x8a37[579]+g+_0x8a37[581];} ;g=this[_0x8a37[998]](g);if(e[_0x8a37[336]]()[_0x8a37[20]]>1&&f||e[_0x8a37[336]]()[_0x8a37[1000]](_0x8a37[999])){if(this[_0x8a37[239]](_0x8a37[238])){if(!this[_0x8a37[800]]()){this[_0x8a37[209]][_0x8a37[803]][_0x8a37[802]]()[_0x8a37[801]](g);} else {this[_0x8a37[804]](g);} ;} else {this[_0x8a37[209]][_0x8a37[471]](_0x8a37[799],false,g);} ;} else {this[_0x8a37[1001]](g,false);} ;if(this[_0x8a37[500]]){this[_0x8a37[210]][_0x8a37[655]](c[_0x8a37[469]](function (){if(!this[_0x8a37[25]][_0x8a37[205]]){this[_0x8a37[605]](this[_0x8a37[323]][_0x8a37[336]]()[_0x8a37[575]]());} else {this[_0x8a37[1002]]();} ;} ,this),1);} ;this[_0x8a37[468]]();this[_0x8a37[353]]();if(j!==false){this[_0x8a37[355]]();} ;} ,insertHtmlAdvanced:function (f,l){f=this[_0x8a37[998]](f);var m=this[_0x8a37[565]]();if(m[_0x8a37[790]]&&m[_0x8a37[566]]){var e=m[_0x8a37[790]](0);e[_0x8a37[567]]();var g=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);g[_0x8a37[791]]=f;var n=this[_0x8a37[209]][_0x8a37[792]](),j,h;while((j=g[_0x8a37[794]])){h=n[_0x8a37[793]](j);} ;e[_0x8a37[571]](n);if(h){e=e[_0x8a37[795]]();e[_0x8a37[796]](h);e[_0x8a37[657]](true);m[_0x8a37[658]]();m[_0x8a37[659]](e);} ;} ;if(l!==false){this[_0x8a37[355]]();} ;} ,insertBeforeCursor:function (f){f=this[_0x8a37[998]](f);var g=c(f);var j=document[_0x8a37[570]](_0x8a37[364]);j[_0x8a37[791]]=_0x8a37[1003];var e=this[_0x8a37[563]]();e[_0x8a37[571]](j);e[_0x8a37[571]](g[0]);e[_0x8a37[657]](false);var h=this[_0x8a37[565]]();h[_0x8a37[658]]();h[_0x8a37[659]](e);this[_0x8a37[355]]();} ,insertText:function (f){var e=c(c[_0x8a37[996]](f));if(e[_0x8a37[20]]){f=e[_0x8a37[590]]();} ;this[_0x8a37[753]]();if(this[_0x8a37[239]](_0x8a37[238])&&!this[_0x8a37[800]]()){this[_0x8a37[209]][_0x8a37[803]][_0x8a37[802]]()[_0x8a37[801]](f);} else {this[_0x8a37[209]][_0x8a37[471]](_0x8a37[799],false,f);} ;this[_0x8a37[355]]();} ,insertNode:function (j){j=j[0]||j;if(j[_0x8a37[368]]==_0x8a37[1004]){var e=_0x8a37[365];var f=j[_0x8a37[366]];var h= new RegExp(_0x8a37[367]+j[_0x8a37[368]],_0x8a37[229]);var g=f[_0x8a37[341]](h,_0x8a37[367]+e);h= new RegExp(_0x8a37[370]+j[_0x8a37[368]],_0x8a37[229]);g=g[_0x8a37[341]](h,_0x8a37[370]+e);j=c(g)[0];} ;var l=this[_0x8a37[565]]();if(l[_0x8a37[790]]&&l[_0x8a37[566]]){range=l[_0x8a37[790]](0);range[_0x8a37[567]]();range[_0x8a37[571]](j);range[_0x8a37[1005]](j);range[_0x8a37[796]](j);l[_0x8a37[658]]();l[_0x8a37[659]](range);} ;} ,insertNodeToCaretPositionFromPoint:function (l,j){var g;var f=l[_0x8a37[725]],n=l[_0x8a37[726]];if(this[_0x8a37[209]][_0x8a37[1006]]){var m=this[_0x8a37[209]][_0x8a37[1006]](f,n);g=this[_0x8a37[563]]();g[_0x8a37[1008]](m[_0x8a37[1007]],m[_0x8a37[706]]);g[_0x8a37[657]](true);g[_0x8a37[571]](j);} else {if(this[_0x8a37[209]][_0x8a37[1009]]){g=this[_0x8a37[209]][_0x8a37[1009]](f,n);g[_0x8a37[571]](j);} else {if( typeof document[_0x8a37[66]][_0x8a37[1010]]!=_0x8a37[12]){g=this[_0x8a37[209]][_0x8a37[66]][_0x8a37[1010]]();g[_0x8a37[1011]](f,n);var h=g[_0x8a37[1012]]();h[_0x8a37[1011]](f,n);g[_0x8a37[1014]](_0x8a37[1013],h);g[_0x8a37[114]]();} ;} ;} ;} ,insertAfterLastElement:function (e,f){if( typeof (f)!=_0x8a37[12]){e=f;} ;if(this[_0x8a37[573]]()){if(this[_0x8a37[25]][_0x8a37[205]]){var h=c(_0x8a37[969])[_0x8a37[437]](c[_0x8a37[380]](this[_0x8a37[323]][_0x8a37[43]]()))[_0x8a37[336]]();var g=h[_0x8a37[575]]()[0];if(g[_0x8a37[368]]==_0x8a37[1004]&&g[_0x8a37[791]]==_0x8a37[28]){g=h[_0x8a37[827]]()[0];} ;if(this[_0x8a37[337]](g)!=this[_0x8a37[337]](e)){return false;} ;} else {if(this[_0x8a37[323]][_0x8a37[336]]()[_0x8a37[575]]()[0]!==e){return false;} ;} ;this[_0x8a37[574]](e);} ;} ,insertingAfterLastElement:function (e){this[_0x8a37[511]]();if(this[_0x8a37[25]][_0x8a37[205]]===false){var f=c(this[_0x8a37[25]][_0x8a37[649]]);c(e)[_0x8a37[319]](f);this[_0x8a37[582]](f);} else {var f=c(_0x8a37[1015]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412],this[_0x8a37[209]])[0];c(e)[_0x8a37[319]](f);c(f)[_0x8a37[319]](this[_0x8a37[25]][_0x8a37[580]]);this[_0x8a37[530]]();this[_0x8a37[323]][_0x8a37[363]](_0x8a37[978])[_0x8a37[325]](_0x8a37[443]);} ;} ,insertLineBreak:function (g){this[_0x8a37[525]]();var f=_0x8a37[381];if(g==true){f=_0x8a37[1016];} ;if(this[_0x8a37[239]](_0x8a37[454])){var j=c(_0x8a37[410])[_0x8a37[43]](this[_0x8a37[25]][_0x8a37[580]]);this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1017])[_0x8a37[778]](f)[_0x8a37[778]](j)[_0x8a37[778]](this[_0x8a37[25]][_0x8a37[580]]);this[_0x8a37[1018]](j[0]);j[_0x8a37[321]]();this[_0x8a37[1019]]();} else {var h=this[_0x8a37[543]]();if(h&&h[_0x8a37[368]]===_0x8a37[781]){var n=this[_0x8a37[1020]](h);var m=c[_0x8a37[380]](c(h)[_0x8a37[590]]())[_0x8a37[341]](/\n\r\n/g,_0x8a37[28]);var e=m[_0x8a37[20]];if(n==e){this[_0x8a37[1019]]();var l=c(_0x8a37[1015]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412],this[_0x8a37[209]])[0];c(h)[_0x8a37[319]](l);c(l)[_0x8a37[778]](f+(this[_0x8a37[239]](_0x8a37[517])?this[_0x8a37[25]][_0x8a37[580]]:_0x8a37[28]));this[_0x8a37[530]]();return true;} ;} ;this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1017])[_0x8a37[778]](f+(this[_0x8a37[239]](_0x8a37[517])?this[_0x8a37[25]][_0x8a37[580]]:_0x8a37[28]));this[_0x8a37[530]]();} ;} ,insertDoubleLineBreak:function (){this[_0x8a37[585]](true);} ,replaceLineBreak:function (e){var f=c(_0x8a37[381]+this[_0x8a37[25]][_0x8a37[580]]);c(e)[_0x8a37[371]](f);this[_0x8a37[582]](f);} ,pasteClean:function (j){j=this[_0x8a37[389]](_0x8a37[1021],false,j);if(this[_0x8a37[239]](_0x8a37[238])){var h=c[_0x8a37[380]](j);if(h[_0x8a37[593]](/^<a(.*?)>(.*?)<\/a>$/i)==0){j=j[_0x8a37[341]](/^<a(.*?)>(.*?)<\/a>$/i,_0x8a37[409]);} ;} ;if(this[_0x8a37[25]][_0x8a37[1022]]){var h=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);j=j[_0x8a37[341]](/<br>|<\/H[1-6]>|<\/p>|<\/div>/gi,_0x8a37[591]);h[_0x8a37[791]]=j;j=h[_0x8a37[1023]]||h[_0x8a37[1024]];j=c[_0x8a37[380]](j);j=j[_0x8a37[341]](_0x8a37[591],_0x8a37[381]);j=this[_0x8a37[847]](j);this[_0x8a37[1025]](j);return false;} ;var f=false;if(this[_0x8a37[809]](_0x8a37[86])){f=true;var g=this[_0x8a37[25]][_0x8a37[227]];g[_0x8a37[15]](_0x8a37[117]);g[_0x8a37[15]](_0x8a37[46]);c[_0x8a37[19]](g,function (m,n){j=j[_0x8a37[341]]( new RegExp(_0x8a37[367]+n+_0x8a37[980],_0x8a37[369]),_0x8a37[28]);j=j[_0x8a37[341]]( new RegExp(_0x8a37[370]+n+_0x8a37[798],_0x8a37[369]),_0x8a37[381]);} );} ;if(this[_0x8a37[809]](_0x8a37[120])){j=this[_0x8a37[1026]](j);this[_0x8a37[1025]](j);return true;} ;j=j[_0x8a37[341]](/<img(.*?)v:shapes=(.*?)>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<p(.*?)class="MsoListParagraphCxSpFirst"([\w\W]*?)<\/p>/gi,_0x8a37[1027]);j=j[_0x8a37[341]](/<p(.*?)class="MsoListParagraphCxSpMiddle"([\w\W]*?)<\/p>/gi,_0x8a37[1028]);j=j[_0x8a37[341]](/<p(.*?)class="MsoListParagraphCxSpLast"([\w\W]*?)<\/p>/gi,_0x8a37[1029]);j=j[_0x8a37[341]](/<p(.*?)class="MsoListParagraph"([\w\W]*?)<\/p>/gi,_0x8a37[1030]);j=j[_0x8a37[341]](/Â·/g,_0x8a37[28]);j=j[_0x8a37[341]](/<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/gi,_0x8a37[28]);if(this[_0x8a37[25]][_0x8a37[1031]]===true){j=j[_0x8a37[341]](/(&nbsp;){2,}/gi,_0x8a37[1032]);j=j[_0x8a37[341]](/&nbsp;/gi,_0x8a37[864]);} ;j=j[_0x8a37[341]](/<b\sid="internal-source-marker(.*?)">([\w\W]*?)<\/b>/gi,_0x8a37[409]);j=j[_0x8a37[341]](/<b(.*?)id="docs-internal-guid(.*?)">([\w\W]*?)<\/b>/gi,_0x8a37[1033]);j=this[_0x8a37[346]](j);j=j[_0x8a37[341]](/<td>\u200b*<\/td>/gi,_0x8a37[1034]);j=j[_0x8a37[341]](/<td>&nbsp;<\/td>/gi,_0x8a37[1034]);j=j[_0x8a37[341]](/<td><br><\/td>/gi,_0x8a37[1034]);j=j[_0x8a37[341]](/<td(.*?)colspan="(.*?)"(.*?)>([\w\W]*?)<\/td>/gi,_0x8a37[1035]);j=j[_0x8a37[341]](/<td(.*?)rowspan="(.*?)"(.*?)>([\w\W]*?)<\/td>/gi,_0x8a37[1036]);j=j[_0x8a37[341]](/<a(.*?)href="(.*?)"(.*?)>([\w\W]*?)<\/a>/gi,_0x8a37[1037]);j=j[_0x8a37[341]](/<iframe(.*?)>([\w\W]*?)<\/iframe>/gi,_0x8a37[1038]);j=j[_0x8a37[341]](/<video(.*?)>([\w\W]*?)<\/video>/gi,_0x8a37[1039]);j=j[_0x8a37[341]](/<audio(.*?)>([\w\W]*?)<\/audio>/gi,_0x8a37[1040]);j=j[_0x8a37[341]](/<embed(.*?)>([\w\W]*?)<\/embed>/gi,_0x8a37[1041]);j=j[_0x8a37[341]](/<object(.*?)>([\w\W]*?)<\/object>/gi,_0x8a37[1042]);j=j[_0x8a37[341]](/<param(.*?)>/gi,_0x8a37[1043]);j=j[_0x8a37[341]](/<img(.*?)>/gi,_0x8a37[1044]);j=j[_0x8a37[341]](/ class="(.*?)"/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<(\w+)([\w\W]*?)>/gi,_0x8a37[1045]);if(this[_0x8a37[25]][_0x8a37[205]]){j=j[_0x8a37[341]](/<strong><\/strong>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<u><\/u>/gi,_0x8a37[28]);if(this[_0x8a37[25]][_0x8a37[408]]){j=j[_0x8a37[341]](/<font(.*?)>([\w\W]*?)<\/font>/gi,_0x8a37[409]);} ;j=j[_0x8a37[341]](/<[^\/>][^>]*>(\s*|\t*|\n*|&nbsp;|<br>)<\/[^>]+>/gi,_0x8a37[381]);} else {j=j[_0x8a37[341]](/<[^\/>][^>]*>(\s*|\t*|\n*|&nbsp;|<br>)<\/[^>]+>/gi,_0x8a37[28]);} ;j=j[_0x8a37[341]](/<div>\s*?\t*?\n*?(<ul>|<ol>|<p>)/gi,_0x8a37[413]);j=j[_0x8a37[341]](/\[td colspan="(.*?)"\]([\w\W]*?)\[\/td\]/gi,_0x8a37[1046]);j=j[_0x8a37[341]](/\[td rowspan="(.*?)"\]([\w\W]*?)\[\/td\]/gi,_0x8a37[1047]);j=j[_0x8a37[341]](/\[td\]/gi,_0x8a37[1048]);j=j[_0x8a37[341]](/\[a href="(.*?)"\]([\w\W]*?)\[\/a\]/gi,_0x8a37[1049]);j=j[_0x8a37[341]](/\[iframe(.*?)\]([\w\W]*?)\[\/iframe\]/gi,_0x8a37[1050]);j=j[_0x8a37[341]](/\[video(.*?)\]([\w\W]*?)\[\/video\]/gi,_0x8a37[1051]);j=j[_0x8a37[341]](/\[audio(.*?)\]([\w\W]*?)\[\/audio\]/gi,_0x8a37[1052]);j=j[_0x8a37[341]](/\[embed(.*?)\]([\w\W]*?)\[\/embed\]/gi,_0x8a37[1053]);j=j[_0x8a37[341]](/\[object(.*?)\]([\w\W]*?)\[\/object\]/gi,_0x8a37[1054]);j=j[_0x8a37[341]](/\[param(.*?)\]/gi,_0x8a37[1055]);j=j[_0x8a37[341]](/\[img(.*?)\]/gi,_0x8a37[1056]);if(this[_0x8a37[25]][_0x8a37[845]]){j=j[_0x8a37[341]](/<div(.*?)>([\w\W]*?)<\/div>/gi,_0x8a37[1057]);j=j[_0x8a37[341]](/<\/div><p>/gi,_0x8a37[579]);j=j[_0x8a37[341]](/<\/p><\/div>/gi,_0x8a37[581]);j=j[_0x8a37[341]](/<p><\/p>/gi,_0x8a37[1058]);} else {j=j[_0x8a37[341]](/<div><\/div>/gi,_0x8a37[1058]);} ;if(this[_0x8a37[809]](_0x8a37[119])){j=j[_0x8a37[341]](/<p>([\w\W]*?)<\/p>/gi,_0x8a37[1059]);} else {if(f===false){j=this[_0x8a37[847]](j);} ;} ;j=j[_0x8a37[341]](/<span(.*?)>([\w\W]*?)<\/span>/gi,_0x8a37[409]);j=j[_0x8a37[341]](/<img>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<[^\/>][^>][^img|param|source|td][^<]*>(\s*|\t*|\n*| |<br>)<\/[^>]+>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/\n{3,}/gi,_0x8a37[591]);j=j[_0x8a37[341]](/<p><p>/gi,_0x8a37[579]);j=j[_0x8a37[341]](/<\/p><\/p>/gi,_0x8a37[581]);j=j[_0x8a37[341]](/<li>(\s*|\t*|\n*)<p>/gi,_0x8a37[697]);j=j[_0x8a37[341]](/<\/p>(\s*|\t*|\n*)<\/li>/gi,_0x8a37[919]);if(this[_0x8a37[25]][_0x8a37[205]]===true){j=j[_0x8a37[341]](/<p(.*?)>([\w\W]*?)<\/p>/gi,_0x8a37[350]);} ;j=j[_0x8a37[341]](/<[^\/>][^>][^img|param|source|td][^<]*>(\s*|\t*|\n*| |<br>)<\/[^>]+>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<img src="webkit-fake-url\:\/\/(.*?)"(.*?)>/gi,_0x8a37[28]);j=j[_0x8a37[341]](/<td(.*?)>(\s*|\t*|\n*)<p>([\w\W]*?)<\/p>(\s*|\t*|\n*)<\/td>/gi,_0x8a37[1060]);if(this[_0x8a37[25]][_0x8a37[845]]){j=j[_0x8a37[341]](/<div(.*?)>([\w\W]*?)<\/div>/gi,_0x8a37[409]);j=j[_0x8a37[341]](/<div(.*?)>([\w\W]*?)<\/div>/gi,_0x8a37[409]);} ;this[_0x8a37[1061]]=false;if(this[_0x8a37[239]](_0x8a37[454])){if(this[_0x8a37[25]][_0x8a37[522]]){var l=j[_0x8a37[600]](/<img src="data:image(.*?)"(.*?)>/gi);if(l!==null){this[_0x8a37[1061]]=l;for(k in l){var e=l[k][_0x8a37[341]](_0x8a37[1062],_0x8a37[1063]+k+_0x8a37[1064]);j=j[_0x8a37[341]](l[k],e);} ;} ;} ;while(/<br>$/gi[_0x8a37[577]](j)){j=j[_0x8a37[341]](/<br>$/gi,_0x8a37[28]);} ;} ;j=j[_0x8a37[341]](/<p>â€¢([\w\W]*?)<\/p>/gi,_0x8a37[1065]);if(this[_0x8a37[239]](_0x8a37[238])){while(/<font>([\w\W]*?)<\/font>/gi[_0x8a37[577]](j)){j=j[_0x8a37[341]](/<font>([\w\W]*?)<\/font>/gi,_0x8a37[413]);} ;} ;if(f===false){j=j[_0x8a37[341]](/<td(.*?)>([\w\W]*?)<p(.*?)>([\w\W]*?)<\/td>/gi,_0x8a37[1066]);j=j[_0x8a37[341]](/<td(.*?)>([\w\W]*?)<\/p>([\w\W]*?)<\/td>/gi,_0x8a37[1067]);j=j[_0x8a37[341]](/<td(.*?)>([\w\W]*?)<p(.*?)>([\w\W]*?)<\/td>/gi,_0x8a37[1066]);j=j[_0x8a37[341]](/<td(.*?)>([\w\W]*?)<\/p>([\w\W]*?)<\/td>/gi,_0x8a37[1067]);} ;j=j[_0x8a37[341]](/\n/g,_0x8a37[864]);j=j[_0x8a37[341]](/<p>\n?<li>/gi,_0x8a37[697]);this[_0x8a37[1025]](j);} ,pastePre:function (f){f=f[_0x8a37[341]](/<br>|<\/H[1-6]>|<\/p>|<\/div>/gi,_0x8a37[591]);var e=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);e[_0x8a37[791]]=f;return this[_0x8a37[939]](e[_0x8a37[1023]]||e[_0x8a37[1024]]);} ,pasteInsert:function (e){e=this[_0x8a37[389]](_0x8a37[1068],false,e);if(this[_0x8a37[500]]){this[_0x8a37[323]][_0x8a37[43]](e);this[_0x8a37[733]]();this[_0x8a37[1002]]();this[_0x8a37[355]]();} else {this[_0x8a37[808]](e);} ;this[_0x8a37[500]]=false;setTimeout(c[_0x8a37[469]](function (){this[_0x8a37[191]]=false;if(this[_0x8a37[239]](_0x8a37[454])){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1069])[_0x8a37[321]]();} ;if(this[_0x8a37[1061]]!==false){this[_0x8a37[1070]]();} ;} ,this),100);if(this[_0x8a37[25]][_0x8a37[429]]&&this[_0x8a37[526]]!==true){c(this[_0x8a37[209]][_0x8a37[66]])[_0x8a37[528]](this[_0x8a37[527]]);} else {this[_0x8a37[323]][_0x8a37[528]](this[_0x8a37[527]]);} ;} ,pasteClipboardAppendFields:function (e){if(this[_0x8a37[25]][_0x8a37[1071]]!==false&& typeof this[_0x8a37[25]][_0x8a37[1071]]===_0x8a37[1072]){c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[1071]],c[_0x8a37[469]](function (g,f){if(f!=null&&f.toString()[_0x8a37[510]](_0x8a37[1073])===0){f=c(f)[_0x8a37[322]]();} ;e[g]=f;} ,this));} ;return e;} ,pasteClipboardUploadMozilla:function (){var e=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1074]);c[_0x8a37[19]](e,c[_0x8a37[469]](function (j,l){var g=c(l);var f=l[_0x8a37[357]][_0x8a37[445]](_0x8a37[1075]);var h={contentType:f[0][_0x8a37[445]](_0x8a37[1077])[0][_0x8a37[445]](_0x8a37[1076])[1],data:f[1]};h=this[_0x8a37[1078]](h);c[_0x8a37[673]](this[_0x8a37[25]][_0x8a37[1079]],h,c[_0x8a37[469]](function (n){var m=( typeof n===_0x8a37[10]?c[_0x8a37[676]](n):n);g[_0x8a37[339]](_0x8a37[357],m[_0x8a37[1080]]);g[_0x8a37[325]](_0x8a37[1081]);this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[477],g,m);} ,this));} ,this));} ,pasteClipboardUpload:function (j){var g=j[_0x8a37[492]][_0x8a37[1082]];var f=g[_0x8a37[445]](_0x8a37[1075]);var h={contentType:f[0][_0x8a37[445]](_0x8a37[1077])[0][_0x8a37[445]](_0x8a37[1076])[1],data:f[1]};if(this[_0x8a37[25]][_0x8a37[522]]){h=this[_0x8a37[1078]](h);c[_0x8a37[673]](this[_0x8a37[25]][_0x8a37[1079]],h,c[_0x8a37[469]](function (m){var l=( typeof m===_0x8a37[10]?c[_0x8a37[676]](m):m);var e=_0x8a37[1083]+l[_0x8a37[1080]]+_0x8a37[1084];this[_0x8a37[471]](_0x8a37[799],e,false);var n=c(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1085]));if(n[_0x8a37[20]]){n[_0x8a37[325]](_0x8a37[443]);} else {n=false;} ;this[_0x8a37[355]]();if(n){this[_0x8a37[389]](_0x8a37[477],n,l);} ;} ,this));} else {this[_0x8a37[808]](_0x8a37[1083]+g+_0x8a37[632]);} ;} ,bufferSet:function (e,f){if(e!==undefined||e===false){this[_0x8a37[25]][_0x8a37[555]][_0x8a37[15]](e);} else {if(f!==false){this[_0x8a37[525]]();} ;this[_0x8a37[25]][_0x8a37[555]][_0x8a37[15]](this[_0x8a37[323]][_0x8a37[43]]());this[_0x8a37[1019]](_0x8a37[555]);} ;} ,bufferUndo:function (){if(this[_0x8a37[25]][_0x8a37[555]][_0x8a37[20]]===0){this[_0x8a37[753]]();return ;} ;this[_0x8a37[525]]();this[_0x8a37[25]][_0x8a37[558]][_0x8a37[15]](this[_0x8a37[323]][_0x8a37[43]]());this[_0x8a37[530]](false,true);this[_0x8a37[323]][_0x8a37[43]](this[_0x8a37[25]][_0x8a37[555]][_0x8a37[1086]]());this[_0x8a37[530]]();setTimeout(c[_0x8a37[469]](this[_0x8a37[468]],this),100);} ,bufferRedo:function (){if(this[_0x8a37[25]][_0x8a37[558]][_0x8a37[20]]===0){this[_0x8a37[753]]();return false;} ;this[_0x8a37[525]]();this[_0x8a37[25]][_0x8a37[555]][_0x8a37[15]](this[_0x8a37[323]][_0x8a37[43]]());this[_0x8a37[530]](false,true);this[_0x8a37[323]][_0x8a37[43]](this[_0x8a37[25]][_0x8a37[558]][_0x8a37[1086]]());this[_0x8a37[530]](true);setTimeout(c[_0x8a37[469]](this[_0x8a37[468]],this),4);} ,observeStart:function (){this[_0x8a37[616]]();if(this[_0x8a37[25]][_0x8a37[617]]){this[_0x8a37[617]]();} ;} ,observeLinks:function (){this[_0x8a37[323]][_0x8a37[363]](_0x8a37[698])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](this[_0x8a37[1087]],this));this[_0x8a37[323]][_0x8a37[480]](_0x8a37[1088],c[_0x8a37[469]](function (f){this[_0x8a37[1089]](f);} ,this));c(document)[_0x8a37[480]](_0x8a37[1088],c[_0x8a37[469]](function (f){this[_0x8a37[1089]](f);} ,this));} ,observeImages:function (){if(this[_0x8a37[25]][_0x8a37[616]]===false){return false;} ;this[_0x8a37[323]][_0x8a37[363]](_0x8a37[384])[_0x8a37[19]](c[_0x8a37[469]](function (e,f){if(this[_0x8a37[239]](_0x8a37[238])){c(f)[_0x8a37[339]](_0x8a37[1090],_0x8a37[480]);} ;this[_0x8a37[1091]](f);} ,this));} ,linkObserver:function (h){var j=c(h[_0x8a37[492]]);if(j[_0x8a37[497]]()==0||j[0][_0x8a37[368]]!==_0x8a37[781]){return ;} ;var m=j[_0x8a37[706]]();if(this[_0x8a37[25]][_0x8a37[204]]){var g=this[_0x8a37[332]][_0x8a37[706]]();m[_0x8a37[705]]=g[_0x8a37[705]]+(m[_0x8a37[705]]-c(this[_0x8a37[209]])[_0x8a37[528]]());m[_0x8a37[708]]+=g[_0x8a37[708]];} ;var p=c(_0x8a37[1092]);var f=j[_0x8a37[339]](_0x8a37[1093]);if(f===undefined){f=_0x8a37[28];} ;if(f[_0x8a37[20]]>24){f=f[_0x8a37[672]](0,24)+_0x8a37[1094];} ;var l=c(_0x8a37[1095]+j[_0x8a37[339]](_0x8a37[1093])+_0x8a37[1096]+f+_0x8a37[740])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (q){this[_0x8a37[1089]](false);} ,this));var n=c(_0x8a37[1097]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1098]]+_0x8a37[740])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (q){q[_0x8a37[507]]();this[_0x8a37[300]]();this[_0x8a37[1089]](false);} ,this));var o=c(_0x8a37[1097]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[301]]+_0x8a37[740])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (q){q[_0x8a37[507]]();this[_0x8a37[471]](_0x8a37[301]);this[_0x8a37[1089]](false);} ,this));p[_0x8a37[437]](l);p[_0x8a37[437]](_0x8a37[1099]);p[_0x8a37[437]](n);p[_0x8a37[437]](_0x8a37[1099]);p[_0x8a37[437]](o);p[_0x8a37[200]]({top:(m[_0x8a37[705]]+20)+_0x8a37[453],left:m[_0x8a37[708]]+_0x8a37[453]});c(_0x8a37[1100])[_0x8a37[321]]();c(_0x8a37[66])[_0x8a37[437]](p);} ,linkObserverTooltipClose:function (f){if(f!==false&&f[_0x8a37[492]][_0x8a37[368]]==_0x8a37[781]){return false;} ;c(_0x8a37[1100])[_0x8a37[321]]();} ,getSelection:function (){if(!this[_0x8a37[25]][_0x8a37[1101]]){return this[_0x8a37[209]][_0x8a37[565]]();} else {if(!this[_0x8a37[25]][_0x8a37[204]]){return rangy[_0x8a37[565]]();} else {return rangy[_0x8a37[565]](this[_0x8a37[332]][0]);} ;} ;} ,getRange:function (){if(!this[_0x8a37[25]][_0x8a37[1101]]){if(this[_0x8a37[209]][_0x8a37[565]]){var e=this[_0x8a37[565]]();if(e[_0x8a37[790]]&&e[_0x8a37[566]]){return e[_0x8a37[790]](0);} ;} ;return this[_0x8a37[209]][_0x8a37[802]]();} else {if(!this[_0x8a37[25]][_0x8a37[204]]){return rangy[_0x8a37[802]]();} else {return rangy[_0x8a37[802]](this[_0x8a37[627]]());} ;} ;} ,selectionElement:function (e){this[_0x8a37[1102]](e);} ,selectionStart:function (e){this[_0x8a37[1103]](e[0]||e,0,null,0);} ,selectionEnd:function (e){this[_0x8a37[1103]](e[0]||e,1,null,1);} ,selectionSet:function (o,n,m,j){if(m==null){m=o;} ;if(j==null){j=n;} ;var h=this[_0x8a37[565]]();if(!h){return ;} ;if(o[_0x8a37[368]]==_0x8a37[75]&&o[_0x8a37[791]]==_0x8a37[28]){o[_0x8a37[791]]=this[_0x8a37[25]][_0x8a37[580]];} ;if(o[_0x8a37[368]]==_0x8a37[604]&&this[_0x8a37[25]][_0x8a37[205]]===false){var g=c(this[_0x8a37[25]][_0x8a37[649]])[0];c(o)[_0x8a37[371]](g);o=g;m=o;} ;var f=this[_0x8a37[563]]();f[_0x8a37[1008]](o,n);f[_0x8a37[1104]](m,j);try{h[_0x8a37[658]]();} catch(l){} ;h[_0x8a37[659]](f);} ,selectionWrap:function (e){e=e[_0x8a37[784]]();var h=this[_0x8a37[545]]();if(h){var j=this[_0x8a37[1105]](h,e);this[_0x8a37[355]]();return j;} ;var g=this[_0x8a37[565]]();var f=g[_0x8a37[790]](0);var j=document[_0x8a37[570]](e);j[_0x8a37[793]](f[_0x8a37[1106]]());f[_0x8a37[571]](j);this[_0x8a37[981]](j);return j;} ,selectionAll:function (){var e=this[_0x8a37[563]]();e[_0x8a37[656]](this[_0x8a37[323]][0]);var f=this[_0x8a37[565]]();f[_0x8a37[658]]();f[_0x8a37[659]](e);} ,selectionRemove:function (){this[_0x8a37[565]]()[_0x8a37[658]]();} ,getCaretOffset:function (h){var e=0;var g=this[_0x8a37[563]]();var f=g[_0x8a37[795]]();f[_0x8a37[656]](h);f[_0x8a37[1104]](g[_0x8a37[986]],g[_0x8a37[2]]);e=c[_0x8a37[380]](f.toString())[_0x8a37[20]];return e;} ,getCaretOffsetRange:function (){return  new d(this[_0x8a37[565]]()[_0x8a37[790]](0));} ,setCaret:function (h,f,m){if( typeof m===_0x8a37[12]){m=f;} ;h=h[0]||h;var o=this[_0x8a37[563]]();o[_0x8a37[656]](h);var p=this[_0x8a37[1107]](h);var l=false;var e=0,q;if(p[_0x8a37[20]]==1&&f){o[_0x8a37[1008]](p[0],f);o[_0x8a37[1104]](p[0],m);} else {for(var n=0,j;j=p[n++];){q=e+j[_0x8a37[20]];if(!l&&f>=e&&(f<q||(f==q&&n<p[_0x8a37[20]]))){o[_0x8a37[1008]](j,f-e);l=true;} ;if(l&&m<=q){o[_0x8a37[1104]](j,m-e);break ;} ;e=q;} ;} ;var g=this[_0x8a37[565]]();g[_0x8a37[658]]();g[_0x8a37[659]](o);} ,setCaretAfter:function (h){this[_0x8a37[323]][_0x8a37[473]]();h=h[0]||h;var f=this[_0x8a37[209]][_0x8a37[802]]();var m=1;var e=-1;f[_0x8a37[1008]](h,m);f[_0x8a37[1104]](h,e+2);var g=this[_0x8a37[210]][_0x8a37[565]]();var j=this[_0x8a37[209]][_0x8a37[802]]();var l=this[_0x8a37[209]][_0x8a37[592]](_0x8a37[1003]);c(h)[_0x8a37[319]](l);j[_0x8a37[796]](l);g[_0x8a37[658]]();g[_0x8a37[659]](j);c(l)[_0x8a37[321]]();} ,getTextNodesIn:function (j){var h=[];if(j[_0x8a37[568]]==3){h[_0x8a37[15]](j);} else {var g=j[_0x8a37[1108]];for(var f=0,e=g[_0x8a37[20]];f<e;++f){h[_0x8a37[15]][_0x8a37[14]](h,this[_0x8a37[1107]](g[f]));} ;} ;return h;} ,getCurrent:function (){var e=false;var f=this[_0x8a37[565]]();if(f&&f[_0x8a37[566]]>0){e=f[_0x8a37[790]](0)[_0x8a37[985]];} ;return this[_0x8a37[814]](e);} ,getParent:function (e){e=e||this[_0x8a37[544]]();if(e){return this[_0x8a37[814]](c(e)[_0x8a37[551]]()[0]);} else {return false;} ;} ,getBlock:function (e){if( typeof e===_0x8a37[12]){e=this[_0x8a37[544]]();} ;while(e){if(this[_0x8a37[825]](e)){if(c(e)[_0x8a37[496]](_0x8a37[328])){return false;} ;return e;} ;e=e[_0x8a37[994]];} ;return false;} ,getBlocks:function (f){var g=[];if( typeof f==_0x8a37[12]){var e=this[_0x8a37[563]]();if(e&&e[_0x8a37[564]]===true){return [this[_0x8a37[545]]()];} ;var f=this[_0x8a37[817]](e);} ;c[_0x8a37[19]](f,c[_0x8a37[469]](function (h,j){if(this[_0x8a37[25]][_0x8a37[204]]===false&&c(j)[_0x8a37[499]](_0x8a37[1109])[_0x8a37[497]]()==0){return false;} ;if(this[_0x8a37[825]](j)){g[_0x8a37[15]](j);} ;} ,this));if(g[_0x8a37[20]]===0){g=[this[_0x8a37[545]]()];} ;return g;} ,nodeTestBlocks:function (e){return e[_0x8a37[568]]==1&&this[_0x8a37[225]][_0x8a37[577]](e[_0x8a37[1110]]);} ,tagTestBlock:function (e){return this[_0x8a37[225]][_0x8a37[577]](e);} ,getNodes:function (g,e){if( typeof g==_0x8a37[12]||g==false){var g=this[_0x8a37[563]]();} ;if(g&&g[_0x8a37[564]]===true){if( typeof e===_0x8a37[12]&&this[_0x8a37[1111]](e)){var m=this[_0x8a37[545]]();if(m[_0x8a37[368]]==e){return [m];} else {return [];} ;} else {return [this[_0x8a37[544]]()];} ;} ;var f=[],l=[];var j=this[_0x8a37[209]][_0x8a37[565]]();if(!j[_0x8a37[1112]]){f=this[_0x8a37[997]](j[_0x8a37[790]](0));} ;c[_0x8a37[19]](f,c[_0x8a37[469]](function (n,o){if(this[_0x8a37[25]][_0x8a37[204]]===false&&c(o)[_0x8a37[499]](_0x8a37[1109])[_0x8a37[497]]()==0){return false;} ;if( typeof e===_0x8a37[12]){if(c[_0x8a37[380]](o[_0x8a37[1023]])!=_0x8a37[28]){l[_0x8a37[15]](o);} ;} else {if(o[_0x8a37[368]]==e){l[_0x8a37[15]](o);} ;} ;} ,this));if(l[_0x8a37[20]]==0){if( typeof e===_0x8a37[12]&&this[_0x8a37[1111]](e)){var m=this[_0x8a37[545]]();if(m[_0x8a37[368]]==e){return l[_0x8a37[15]](m);} else {return [];} ;} else {l[_0x8a37[15]](this[_0x8a37[544]]());} ;} ;var h=l[l[_0x8a37[20]]-1];if(this[_0x8a37[825]](h)){l=l[_0x8a37[9]](0,-1);} ;return l;} ,getElement:function (e){if(!e){e=this[_0x8a37[544]]();} ;while(e){if(e[_0x8a37[568]]==1){if(c(e)[_0x8a37[496]](_0x8a37[328])){return false;} ;return e;} ;e=e[_0x8a37[994]];} ;return false;} ,getRangeSelectedNodes:function (f){f=f||this[_0x8a37[563]]();var g=f[_0x8a37[985]];var e=f[_0x8a37[986]];if(g==e){return [g];} ;var h=[];while(g&&g!=e){h[_0x8a37[15]](g=this[_0x8a37[1113]](g));} ;g=f[_0x8a37[985]];while(g&&g!=f[_0x8a37[1114]]){h[_0x8a37[819]](g);g=g[_0x8a37[994]];} ;return h;} ,nextNode:function (e){if(e[_0x8a37[1115]]()){return e[_0x8a37[794]];} else {while(e&&!e[_0x8a37[1116]]){e=e[_0x8a37[994]];} ;if(!e){return null;} ;return e[_0x8a37[1116]];} ;} ,getSelectionText:function (){return this[_0x8a37[565]]().toString();} ,getSelectionHtml:function (){var h=_0x8a37[28];var j=this[_0x8a37[565]]();if(j[_0x8a37[566]]){var f=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);var e=j[_0x8a37[566]];for(var g=0;g<e;++g){f[_0x8a37[793]](j[_0x8a37[790]](g)[_0x8a37[1117]]());} ;h=f[_0x8a37[791]];} ;return this[_0x8a37[377]](h);} ,selectionSave:function (){if(!this[_0x8a37[762]]()){this[_0x8a37[753]]();} ;if(!this[_0x8a37[25]][_0x8a37[1101]]){this[_0x8a37[1118]](this[_0x8a37[563]]());} else {this[_0x8a37[211]]=rangy[_0x8a37[1119]]();} ;} ,selectionCreateMarker:function (h,e){if(!h){return ;} ;var g=c(_0x8a37[1120]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412],this[_0x8a37[209]])[0];var f=c(_0x8a37[1121]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412],this[_0x8a37[209]])[0];if(h[_0x8a37[564]]===true){this[_0x8a37[1122]](h,g,true);} else {this[_0x8a37[1122]](h,g,true);this[_0x8a37[1122]](h,f,false);} ;this[_0x8a37[211]]=this[_0x8a37[323]][_0x8a37[43]]();this[_0x8a37[530]](false,false);} ,selectionSetMarker:function (e,g,f){var h=e[_0x8a37[795]]();h[_0x8a37[657]](f);h[_0x8a37[571]](g);h[_0x8a37[1123]]();} ,selectionRestore:function (h,e){if(!this[_0x8a37[25]][_0x8a37[1101]]){if(h===true&&this[_0x8a37[211]]){this[_0x8a37[323]][_0x8a37[43]](this[_0x8a37[211]]);} ;var g=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[978]);var f=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1124]);if(this[_0x8a37[239]](_0x8a37[454])){this[_0x8a37[323]][_0x8a37[473]]();} else {if(!this[_0x8a37[762]]()){this[_0x8a37[753]]();} ;} ;if(g[_0x8a37[20]]!=0&&f[_0x8a37[20]]!=0){this[_0x8a37[1103]](g[0],0,f[0],0);} else {if(g[_0x8a37[20]]!=0){this[_0x8a37[1103]](g[0],0,null,0);} ;} ;if(e!==false){this[_0x8a37[1019]]();this[_0x8a37[211]]=false;} ;} else {rangy[_0x8a37[1125]](this[_0x8a37[211]]);} ;} ,selectionRemoveMarkers:function (e){if(!this[_0x8a37[25]][_0x8a37[1101]]){c[_0x8a37[19]](this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1126]),function (){var f=c[_0x8a37[380]](c(this)[_0x8a37[43]]()[_0x8a37[341]](/[^\u0000-\u1C7F]/g,_0x8a37[28]));if(f==_0x8a37[28]){c(this)[_0x8a37[321]]();} else {c(this)[_0x8a37[325]](_0x8a37[982])[_0x8a37[325]](_0x8a37[443]);} ;} );} else {rangy[_0x8a37[1127]](this[_0x8a37[211]]);} ;} ,tableShow:function (){this[_0x8a37[525]]();this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[46]],this[_0x8a37[25]][_0x8a37[1128]],300,c[_0x8a37[469]](function (){c(_0x8a37[1130])[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1129]],this));setTimeout(function (){c(_0x8a37[1131])[_0x8a37[473]]();} ,200);} ,this));} ,tableInsert:function (){this[_0x8a37[511]](false,false);var r=c(_0x8a37[1131])[_0x8a37[322]](),f=c(_0x8a37[1133])[_0x8a37[322]](),n=c(_0x8a37[1134]),e=Math[_0x8a37[1136]](Math[_0x8a37[1135]]()*99999),p=c(_0x8a37[1137]+e+_0x8a37[1138]),g,l,m,o;for(g=0;g<r;g++){l=c(_0x8a37[878]);for(m=0;m<f;m++){o=c(_0x8a37[823]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[1139]);if(g===0&&m===0){o[_0x8a37[437]](_0x8a37[1015]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412]);} ;c(l)[_0x8a37[437]](o);} ;p[_0x8a37[437]](l);} ;n[_0x8a37[437]](p);var h=n[_0x8a37[43]]();this[_0x8a37[1140]]();this[_0x8a37[530]]();var j=this[_0x8a37[545]]()||this[_0x8a37[544]]();if(j&&j[_0x8a37[368]]!=_0x8a37[601]){if(j[_0x8a37[368]]==_0x8a37[119]){var j=c(j)[_0x8a37[732]](_0x8a37[828]);} ;c(j)[_0x8a37[319]](h);} else {this[_0x8a37[1001]](h,false);} ;this[_0x8a37[530]]();var q=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1141]+e);this[_0x8a37[704]]();q[_0x8a37[363]](_0x8a37[1142])[_0x8a37[321]]();q[_0x8a37[325]](_0x8a37[443]);this[_0x8a37[355]]();} ,tableDeleteTable:function (){var e=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](e)){return false;} ;if(e[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();e[_0x8a37[321]]();this[_0x8a37[355]]();} ,tableDeleteRow:function (){var g=this[_0x8a37[543]]();var e=c(g)[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](e)){return false;} ;if(e[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();var j=c(g)[_0x8a37[732]](_0x8a37[117]);var f=j[_0x8a37[827]]()[_0x8a37[20]]?j[_0x8a37[827]]():j[_0x8a37[603]]();if(f[_0x8a37[20]]){var h=f[_0x8a37[335]](_0x8a37[115])[_0x8a37[1143]]();if(h[_0x8a37[20]]){h[_0x8a37[694]](_0x8a37[1015]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412]);} ;} ;j[_0x8a37[321]]();this[_0x8a37[530]]();this[_0x8a37[355]]();} ,tableDeleteColumn:function (){var h=this[_0x8a37[543]]();var g=c(h)[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](g)){return false;} ;if(g[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();var e=c(h)[_0x8a37[732]](_0x8a37[115]);if(!(e[_0x8a37[1000]](_0x8a37[115]))){e=e[_0x8a37[732]](_0x8a37[115]);} ;var f=e[_0x8a37[317]](0)[_0x8a37[1144]];g[_0x8a37[363]](_0x8a37[117])[_0x8a37[19]](c[_0x8a37[469]](function (j,l){var m=f-1<0?f+1:f-1;if(j===0){c(l)[_0x8a37[363]](_0x8a37[115])[_0x8a37[1145]](m)[_0x8a37[694]](_0x8a37[1015]+this[_0x8a37[25]][_0x8a37[580]]+_0x8a37[412]);} ;c(l)[_0x8a37[363]](_0x8a37[115])[_0x8a37[1145]](f)[_0x8a37[321]]();} ,this));this[_0x8a37[530]]();this[_0x8a37[355]]();} ,tableAddHead:function (){var e=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](e)){return false;} ;if(e[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();if(e[_0x8a37[363]](_0x8a37[101])[_0x8a37[497]]()!==0){this[_0x8a37[292]]();} else {var f=e[_0x8a37[363]](_0x8a37[117])[_0x8a37[1143]]()[_0x8a37[602]]();f[_0x8a37[363]](_0x8a37[115])[_0x8a37[43]](this[_0x8a37[25]][_0x8a37[580]]);$thead=c(_0x8a37[1146]);$thead[_0x8a37[437]](f);e[_0x8a37[694]]($thead);this[_0x8a37[355]]();} ;} ,tableDeleteHead:function (){var e=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](e)){return false;} ;var f=e[_0x8a37[363]](_0x8a37[101]);if(f[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();f[_0x8a37[321]]();this[_0x8a37[355]]();} ,tableAddRowAbove:function (){this[_0x8a37[1147]](_0x8a37[778]);} ,tableAddRowBelow:function (){this[_0x8a37[1147]](_0x8a37[319]);} ,tableAddColumnLeft:function (){this[_0x8a37[1148]](_0x8a37[778]);} ,tableAddColumnRight:function (){this[_0x8a37[1148]](_0x8a37[319]);} ,tableAddRow:function (f){var e=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](e)){return false;} ;if(e[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();var g=c(this[_0x8a37[543]]())[_0x8a37[732]](_0x8a37[117]);var h=g[_0x8a37[602]]();h[_0x8a37[363]](_0x8a37[115])[_0x8a37[43]](this[_0x8a37[25]][_0x8a37[580]]);if(f===_0x8a37[319]){g[_0x8a37[319]](h);} else {g[_0x8a37[778]](h);} ;this[_0x8a37[355]]();} ,tableAddColumn:function (j){var h=this[_0x8a37[543]]();var g=c(h)[_0x8a37[732]](_0x8a37[46]);if(!this[_0x8a37[814]](g)){return false;} ;if(g[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[511]]();var f=0;var l=this[_0x8a37[544]]();var m=c(l)[_0x8a37[732]](_0x8a37[117]);var e=c(l)[_0x8a37[732]](_0x8a37[115]);m[_0x8a37[363]](_0x8a37[115])[_0x8a37[19]](c[_0x8a37[469]](function (n,o){if(c(o)[0]===e[0]){f=n;} ;} ,this));g[_0x8a37[363]](_0x8a37[117])[_0x8a37[19]](c[_0x8a37[469]](function (n,p){var o=c(p)[_0x8a37[363]](_0x8a37[115])[_0x8a37[1145]](f);var q=o[_0x8a37[602]]();q[_0x8a37[43]](this[_0x8a37[25]][_0x8a37[580]]);j===_0x8a37[319]?o[_0x8a37[319]](q):o[_0x8a37[778]](q);} ,this));this[_0x8a37[355]]();} ,videoShow:function (){this[_0x8a37[525]]();this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[45]],this[_0x8a37[25]][_0x8a37[1149]],600,c[_0x8a37[469]](function (){c(_0x8a37[1151])[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1150]],this));setTimeout(function (){c(_0x8a37[1152])[_0x8a37[473]]();} ,200);} ,this));} ,videoInsert:function (){var e=c(_0x8a37[1152])[_0x8a37[322]]();e=this[_0x8a37[346]](e);this[_0x8a37[530]]();var f=this[_0x8a37[545]]()||this[_0x8a37[544]]();if(f){c(f)[_0x8a37[319]](e);} else {this[_0x8a37[1001]](e,false);} ;this[_0x8a37[355]]();this[_0x8a37[1140]]();} ,linkShow:function (){this[_0x8a37[525]]();var e=c[_0x8a37[469]](function (){this[_0x8a37[1153]]=false;var m=this[_0x8a37[565]]();var f=_0x8a37[28],o=_0x8a37[28],n=_0x8a37[28];var l=this[_0x8a37[543]]();var j=c(l)[_0x8a37[551]]()[_0x8a37[317]](0);if(j&&j[_0x8a37[368]]===_0x8a37[781]){l=j;} ;if(l&&l[_0x8a37[368]]===_0x8a37[781]){f=l[_0x8a37[1093]];o=c(l)[_0x8a37[590]]();n=l[_0x8a37[492]];this[_0x8a37[1153]]=l;} else {o=m.toString();} ;c(_0x8a37[1154])[_0x8a37[322]](o);var h=self[_0x8a37[1155]][_0x8a37[1093]][_0x8a37[341]](/\/$/i,_0x8a37[28]);f=f[_0x8a37[341]](h,_0x8a37[28]);f=f[_0x8a37[341]](/^\/#/,_0x8a37[1073]);f=f[_0x8a37[341]](_0x8a37[1156],_0x8a37[28]);if(this[_0x8a37[25]][_0x8a37[613]]===false){var g= new RegExp(_0x8a37[1157]+self[_0x8a37[1155]][_0x8a37[1158]],_0x8a37[229]);f=f[_0x8a37[341]](g,_0x8a37[28]);} ;c(_0x8a37[1159])[_0x8a37[322]](f);if(n===_0x8a37[1160]){c(_0x8a37[1163])[_0x8a37[1162]](_0x8a37[1161],true);} ;this[_0x8a37[1164]]=false;c(_0x8a37[1166])[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1165]],this));setTimeout(function (){c(_0x8a37[1159])[_0x8a37[473]]();} ,200);} ,this);this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[47]],this[_0x8a37[25]][_0x8a37[1167]],460,e);} ,linkProcess:function (){if(this[_0x8a37[1164]]){return ;} ;this[_0x8a37[1164]]=true;var l=_0x8a37[28],n=_0x8a37[28];var h=c(_0x8a37[1159])[_0x8a37[322]]();var m=c(_0x8a37[1154])[_0x8a37[322]]();if(h[_0x8a37[593]](_0x8a37[1168])!=-1){h=_0x8a37[1156]+h;} else {if(h[_0x8a37[593]](_0x8a37[1073])!=0){if(c(_0x8a37[1163])[_0x8a37[1162]](_0x8a37[1161])){l=_0x8a37[1169];n=_0x8a37[1160];} ;var j=_0x8a37[1170];var g= new RegExp(_0x8a37[1157]+j,_0x8a37[229]);var f= new RegExp(_0x8a37[1171]+j,_0x8a37[229]);if(h[_0x8a37[593]](g)==-1&&h[_0x8a37[593]](f)==0&&this[_0x8a37[25]][_0x8a37[613]]){h=this[_0x8a37[25]][_0x8a37[613]]+h;} ;} ;} ;m=m[_0x8a37[341]](/<|>/g,_0x8a37[28]);var e=_0x8a37[1032];if(this[_0x8a37[239]](_0x8a37[454])){e=_0x8a37[1032];} ;this[_0x8a37[1172]](_0x8a37[1095]+h+_0x8a37[940]+l+_0x8a37[798]+m+_0x8a37[740]+e,c[_0x8a37[380]](m),h,n);} ,linkInsert:function (e,j,f,h){this[_0x8a37[530]]();if(j!==_0x8a37[28]){if(this[_0x8a37[1153]]){this[_0x8a37[511]]();c(this[_0x8a37[1153]])[_0x8a37[590]](j)[_0x8a37[339]](_0x8a37[1093],f);if(h!==_0x8a37[28]){c(this[_0x8a37[1153]])[_0x8a37[339]](_0x8a37[492],h);} else {c(this[_0x8a37[1153]])[_0x8a37[325]](_0x8a37[492]);} ;} else {var g=c(e)[_0x8a37[448]](_0x8a37[1173]);this[_0x8a37[743]](_0x8a37[799],this[_0x8a37[337]](g),false);var f=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1174]);f[_0x8a37[325]](_0x8a37[69])[_0x8a37[327]](_0x8a37[1173])[_0x8a37[19]](function (){if(this[_0x8a37[446]]==_0x8a37[28]){c(this)[_0x8a37[325]](_0x8a37[982]);} ;} );} ;this[_0x8a37[355]]();} ;setTimeout(c[_0x8a37[469]](function (){if(this[_0x8a37[25]][_0x8a37[617]]){this[_0x8a37[617]]();} ;} ,this),5);this[_0x8a37[1140]]();} ,fileShow:function (){this[_0x8a37[525]]();var e=c[_0x8a37[469]](function (){var f=this[_0x8a37[565]]();var g=_0x8a37[28];if(this[_0x8a37[842]]()){g=f[_0x8a37[590]];} else {g=f.toString();} ;c(_0x8a37[1175])[_0x8a37[322]](g);if(!this[_0x8a37[426]]()&&!this[_0x8a37[1176]]()){this[_0x8a37[1181]](_0x8a37[1177],{url:this[_0x8a37[25]][_0x8a37[695]],uploadFields:this[_0x8a37[25]][_0x8a37[1071]],success:c[_0x8a37[469]](this[_0x8a37[1178]],this),error:c[_0x8a37[469]](function (j,h){this[_0x8a37[389]](_0x8a37[1179],h);} ,this),uploadParam:this[_0x8a37[25]][_0x8a37[1180]]});} ;this[_0x8a37[1183]](_0x8a37[1182],{auto:true,url:this[_0x8a37[25]][_0x8a37[695]],success:c[_0x8a37[469]](this[_0x8a37[1178]],this),error:c[_0x8a37[469]](function (j,h){this[_0x8a37[389]](_0x8a37[1179],h);} ,this)});} ,this);this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[31]],this[_0x8a37[25]][_0x8a37[1184]],500,e);} ,fileCallback:function (f){this[_0x8a37[530]]();if(f!==false){var h=c(_0x8a37[1175])[_0x8a37[322]]();if(h===_0x8a37[28]){h=f[_0x8a37[1185]];} ;var g=_0x8a37[1095]+f[_0x8a37[1080]]+_0x8a37[1186]+h+_0x8a37[740];if(this[_0x8a37[239]](_0x8a37[517])&&!!this[_0x8a37[210]][_0x8a37[1187]]){g=g+_0x8a37[1032];} ;this[_0x8a37[471]](_0x8a37[799],g,false);var e=c(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1188]));if(e[_0x8a37[497]]()!=0){e[_0x8a37[325]](_0x8a37[443]);} else {e=false;} ;this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[695],e,f);} ;this[_0x8a37[1140]]();} ,imageShow:function (){this[_0x8a37[525]]();var e=c[_0x8a37[469]](function (){if(this[_0x8a37[25]][_0x8a37[1189]]){c[_0x8a37[1202]](this[_0x8a37[25]][_0x8a37[1189]],c[_0x8a37[469]](function (l){var g={},j=0;c[_0x8a37[19]](l,c[_0x8a37[469]](function (n,o){if( typeof o[_0x8a37[1190]]!==_0x8a37[12]){j++;g[o[_0x8a37[1190]]]=j;} ;} ,this));var h=false;c[_0x8a37[19]](l,c[_0x8a37[469]](function (q,r){var p=_0x8a37[28];if( typeof r[_0x8a37[739]]!==_0x8a37[12]){p=r[_0x8a37[739]];} ;var n=0;if(!c[_0x8a37[1191]](g)&& typeof r[_0x8a37[1190]]!==_0x8a37[12]){n=g[r[_0x8a37[1190]]];if(h===false){h=_0x8a37[1192]+n;} ;} ;var o=c(_0x8a37[1083]+r[_0x8a37[1193]]+_0x8a37[1194]+n+_0x8a37[1195]+r[_0x8a37[44]]+_0x8a37[1196]+p+_0x8a37[632]);c(_0x8a37[1197])[_0x8a37[437]](o);c(o)[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1198]],this));} ,this));if(!c[_0x8a37[1191]](g)){c(_0x8a37[1192])[_0x8a37[435]]();c(h)[_0x8a37[248]]();var m=function (n){c(_0x8a37[1192])[_0x8a37[435]]();c(_0x8a37[1192]+c(n[_0x8a37[492]])[_0x8a37[322]]())[_0x8a37[248]]();} ;var f=c(_0x8a37[1199]);c[_0x8a37[19]](g,function (o,n){f[_0x8a37[437]](c(_0x8a37[1200]+n+_0x8a37[738]+o+_0x8a37[1201]));} );c(_0x8a37[1197])[_0x8a37[778]](f);f[_0x8a37[391]](m);} ;} ,this));} else {c(_0x8a37[1203])[_0x8a37[321]]();} ;if(this[_0x8a37[25]][_0x8a37[477]]||this[_0x8a37[25]][_0x8a37[513]]){if(!this[_0x8a37[426]]()&&!this[_0x8a37[1176]]()&&this[_0x8a37[25]][_0x8a37[513]]===false){if(c(_0x8a37[1177])[_0x8a37[20]]){this[_0x8a37[1181]](_0x8a37[1177],{url:this[_0x8a37[25]][_0x8a37[477]],uploadFields:this[_0x8a37[25]][_0x8a37[1071]],success:c[_0x8a37[469]](this[_0x8a37[1204]],this),error:c[_0x8a37[469]](function (g,f){this[_0x8a37[389]](_0x8a37[1205],f);} ,this),uploadParam:this[_0x8a37[25]][_0x8a37[514]]});} ;} ;if(this[_0x8a37[25]][_0x8a37[513]]===false){this[_0x8a37[1183]](_0x8a37[1182],{auto:true,url:this[_0x8a37[25]][_0x8a37[477]],success:c[_0x8a37[469]](this[_0x8a37[1204]],this),error:c[_0x8a37[469]](function (g,f){this[_0x8a37[389]](_0x8a37[1205],f);} ,this)});} else {c(_0x8a37[1177])[_0x8a37[480]](_0x8a37[1206],c[_0x8a37[469]](this[_0x8a37[1207]],this));} ;} else {c(_0x8a37[1208])[_0x8a37[435]]();if(!this[_0x8a37[25]][_0x8a37[1189]]){c(_0x8a37[1209])[_0x8a37[321]]();c(_0x8a37[1210])[_0x8a37[248]]();} else {c(_0x8a37[1211])[_0x8a37[321]]();c(_0x8a37[1203])[_0x8a37[448]](_0x8a37[1212]);c(_0x8a37[1213])[_0x8a37[248]]();} ;} ;if(!this[_0x8a37[25]][_0x8a37[1214]]&&(this[_0x8a37[25]][_0x8a37[477]]||this[_0x8a37[25]][_0x8a37[1189]])){c(_0x8a37[1215])[_0x8a37[435]]();} ;c(_0x8a37[1217])[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1216]],this));if(!this[_0x8a37[25]][_0x8a37[477]]&&!this[_0x8a37[25]][_0x8a37[1189]]){setTimeout(function (){c(_0x8a37[1218])[_0x8a37[473]]();} ,200);} ;} ,this);this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[44]],this[_0x8a37[25]][_0x8a37[1219]],610,e);} ,imageEdit:function (g){var e=g;var f=e[_0x8a37[551]]()[_0x8a37[551]]();var h=c[_0x8a37[469]](function (){c(_0x8a37[1221])[_0x8a37[322]](e[_0x8a37[339]](_0x8a37[1220]));c(_0x8a37[1222])[_0x8a37[339]](_0x8a37[1093],e[_0x8a37[339]](_0x8a37[357]));if(e[_0x8a37[200]](_0x8a37[1223])==_0x8a37[1224]&&e[_0x8a37[200]](_0x8a37[1225])==_0x8a37[1226]){c(_0x8a37[1227])[_0x8a37[322]](_0x8a37[788]);} else {c(_0x8a37[1227])[_0x8a37[322]](e[_0x8a37[200]](_0x8a37[1225]));} ;if(c(f)[_0x8a37[317]](0)[_0x8a37[368]]===_0x8a37[781]){c(_0x8a37[1218])[_0x8a37[322]](c(f)[_0x8a37[339]](_0x8a37[1093]));if(c(f)[_0x8a37[339]](_0x8a37[492])==_0x8a37[1160]){c(_0x8a37[1163])[_0x8a37[1162]](_0x8a37[1161],true);} ;} ;c(_0x8a37[1229])[_0x8a37[741]](c[_0x8a37[469]](function (){this[_0x8a37[1228]](e);} ,this));c(_0x8a37[1231])[_0x8a37[741]](c[_0x8a37[469]](function (){this[_0x8a37[1230]](e);} ,this));} ,this);this[_0x8a37[1132]](this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1098]],this[_0x8a37[25]][_0x8a37[1232]],380,h);} ,imageRemove:function (h){var e=c(h)[_0x8a37[551]]()[_0x8a37[551]]();var g=c(h)[_0x8a37[551]]();var f=false;if(e[_0x8a37[20]]&&e[0][_0x8a37[368]]===_0x8a37[781]){f=true;c(e)[_0x8a37[321]]();} else {if(g[_0x8a37[20]]&&g[0][_0x8a37[368]]===_0x8a37[781]){f=true;c(g)[_0x8a37[321]]();} else {c(h)[_0x8a37[321]]();} ;} ;if(g[_0x8a37[20]]&&g[0][_0x8a37[368]]===_0x8a37[75]){this[_0x8a37[753]]();if(f===false){this[_0x8a37[582]](g);} ;} ;this[_0x8a37[389]](_0x8a37[1233],h);this[_0x8a37[1140]]();this[_0x8a37[355]]();} ,imageSave:function (h){var f=c(h);var g=f[_0x8a37[551]]();f[_0x8a37[339]](_0x8a37[1220],c(_0x8a37[1221])[_0x8a37[322]]());var n=c(_0x8a37[1227])[_0x8a37[322]]();var l=_0x8a37[28];this[_0x8a37[547]](false);if(n===_0x8a37[708]){l=_0x8a37[1234]+this[_0x8a37[25]][_0x8a37[1235]]+_0x8a37[864]+this[_0x8a37[25]][_0x8a37[1235]]+_0x8a37[1236];f[_0x8a37[200]]({"\x66\x6C\x6F\x61\x74":_0x8a37[708],margin:l});} else {if(n===_0x8a37[787]){l=_0x8a37[1237]+this[_0x8a37[25]][_0x8a37[1235]]+_0x8a37[864]+this[_0x8a37[25]][_0x8a37[1235]]+_0x8a37[28];f[_0x8a37[200]]({"\x66\x6C\x6F\x61\x74":_0x8a37[787],margin:l});} else {if(n===_0x8a37[788]){f[_0x8a37[200]]({"\x66\x6C\x6F\x61\x74":_0x8a37[28],display:_0x8a37[1224],margin:_0x8a37[533]});} else {f[_0x8a37[200]]({"\x66\x6C\x6F\x61\x74":_0x8a37[28],display:_0x8a37[28],margin:_0x8a37[28]});} ;} ;} ;var j=c[_0x8a37[380]](c(_0x8a37[1218])[_0x8a37[322]]());if(j!==_0x8a37[28]){var m=false;if(c(_0x8a37[1163])[_0x8a37[1162]](_0x8a37[1161])){m=true;} ;if(g[_0x8a37[317]](0)[_0x8a37[368]]!==_0x8a37[781]){var e=c(_0x8a37[1095]+j+_0x8a37[738]+this[_0x8a37[337]](h)+_0x8a37[740]);if(m){e[_0x8a37[339]](_0x8a37[492],_0x8a37[1160]);} ;f[_0x8a37[371]](e);} else {g[_0x8a37[339]](_0x8a37[1093],j);if(m){g[_0x8a37[339]](_0x8a37[492],_0x8a37[1160]);} else {g[_0x8a37[325]](_0x8a37[492]);} ;} ;} else {if(g[_0x8a37[317]](0)[_0x8a37[368]]===_0x8a37[781]){g[_0x8a37[371]](this[_0x8a37[337]](h));} ;} ;this[_0x8a37[1140]]();this[_0x8a37[616]]();this[_0x8a37[355]]();} ,imageResizeHide:function (g){if(g!==false&&c(g[_0x8a37[492]])[_0x8a37[551]]()[_0x8a37[497]]()!=0&&c(g[_0x8a37[492]])[_0x8a37[551]]()[0][_0x8a37[443]]===_0x8a37[1238]){return false;} ;var f=this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1239]);if(f[_0x8a37[497]]()==0){return false;} ;this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1240])[_0x8a37[321]]();f[_0x8a37[363]](_0x8a37[384])[_0x8a37[200]]({marginTop:f[0][_0x8a37[69]][_0x8a37[1241]],marginBottom:f[0][_0x8a37[69]][_0x8a37[1242]],marginLeft:f[0][_0x8a37[69]][_0x8a37[1243]],marginRight:f[0][_0x8a37[69]][_0x8a37[1244]]});f[_0x8a37[200]](_0x8a37[1245],_0x8a37[28]);f[_0x8a37[363]](_0x8a37[384])[_0x8a37[200]](_0x8a37[1246],_0x8a37[28]);f[_0x8a37[371]](function (){return c(this)[_0x8a37[336]]();} );c(document)[_0x8a37[314]](_0x8a37[1247]);this[_0x8a37[323]][_0x8a37[314]](_0x8a37[1247]);this[_0x8a37[323]][_0x8a37[314]](_0x8a37[1248]);this[_0x8a37[355]]();} ,imageResize:function (f){var e=c(f);e[_0x8a37[480]](_0x8a37[493],c[_0x8a37[469]](function (){this[_0x8a37[547]](false);} ,this));e[_0x8a37[480]](_0x8a37[1249],c[_0x8a37[469]](function (){this[_0x8a37[323]][_0x8a37[480]](_0x8a37[1250],c[_0x8a37[469]](function (){setTimeout(c[_0x8a37[469]](function (){this[_0x8a37[616]]();this[_0x8a37[323]][_0x8a37[314]](_0x8a37[1250]);this[_0x8a37[355]]();} ,this),1);} ,this));} ,this));e[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (l){if(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1239])[_0x8a37[497]]()!=0){return false;} ;var n=false,q,p,m=e[_0x8a37[202]]()/e[_0x8a37[199]](),o=20,j=10;var g=this[_0x8a37[1251]](e);var h=false;g[_0x8a37[480]](_0x8a37[493],function (r){h=true;r[_0x8a37[507]]();m=e[_0x8a37[202]]()/e[_0x8a37[199]]();q=Math[_0x8a37[1253]](r[_0x8a37[1252]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[708]]);p=Math[_0x8a37[1253]](r[_0x8a37[1254]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[705]]);} );c(this[_0x8a37[209]][_0x8a37[66]])[_0x8a37[480]](_0x8a37[1255],c[_0x8a37[469]](function (v){if(h){var s=Math[_0x8a37[1253]](v[_0x8a37[1252]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[708]])-q;var r=Math[_0x8a37[1253]](v[_0x8a37[1254]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[705]])-p;var u=e[_0x8a37[199]]();var w=parseInt(u,10)+r;var t=Math[_0x8a37[1253]](w*m);if(t>o){e[_0x8a37[202]](t);if(t<100){this[_0x8a37[1260]][_0x8a37[200]]({marginTop:_0x8a37[1256],marginLeft:_0x8a37[1257],fontSize:_0x8a37[1258],padding:_0x8a37[1259]});} else {this[_0x8a37[1260]][_0x8a37[200]]({marginTop:_0x8a37[1261],marginLeft:_0x8a37[1262],fontSize:_0x8a37[1263],padding:_0x8a37[1264]});} ;} ;q=Math[_0x8a37[1253]](v[_0x8a37[1252]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[708]]);p=Math[_0x8a37[1253]](v[_0x8a37[1254]]-e[_0x8a37[1145]](0)[_0x8a37[706]]()[_0x8a37[705]]);this[_0x8a37[355]]();} ;} ,this))[_0x8a37[480]](_0x8a37[719],function (){h=false;} );this[_0x8a37[323]][_0x8a37[480]](_0x8a37[1248],c[_0x8a37[469]](function (s){var r=s[_0x8a37[392]];if(this[_0x8a37[549]][_0x8a37[588]]==r||this[_0x8a37[549]][_0x8a37[610]]==r){this[_0x8a37[511]](false,false);this[_0x8a37[547]](false);this[_0x8a37[1228]](e);} ;} ,this));c(document)[_0x8a37[480]](_0x8a37[1247],c[_0x8a37[469]](this[_0x8a37[547]],this));this[_0x8a37[323]][_0x8a37[480]](_0x8a37[1247],c[_0x8a37[469]](this[_0x8a37[547]],this));} ,this));} ,imageResizeControls:function (f){var g=c(_0x8a37[1265]);g[_0x8a37[200]]({position:_0x8a37[717],display:_0x8a37[1266],lineHeight:0,outline:_0x8a37[1267],"\x66\x6C\x6F\x61\x74":f[_0x8a37[200]](_0x8a37[1225])});g[_0x8a37[339]](_0x8a37[324],false);if(f[0][_0x8a37[69]][_0x8a37[1245]]!=_0x8a37[533]){g[_0x8a37[200]]({marginTop:f[0][_0x8a37[69]][_0x8a37[1241]],marginBottom:f[0][_0x8a37[69]][_0x8a37[1242]],marginLeft:f[0][_0x8a37[69]][_0x8a37[1243]],marginRight:f[0][_0x8a37[69]][_0x8a37[1244]]});f[_0x8a37[200]](_0x8a37[1245],_0x8a37[28]);} else {g[_0x8a37[200]]({display:_0x8a37[1224],margin:_0x8a37[533]});} ;f[_0x8a37[200]](_0x8a37[1246],0.5)[_0x8a37[319]](g);this[_0x8a37[1260]]=c(_0x8a37[1268]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1098]]+_0x8a37[412]);this[_0x8a37[1260]][_0x8a37[200]]({position:_0x8a37[713],zIndex:5,top:_0x8a37[1269],left:_0x8a37[1269],marginTop:_0x8a37[1261],marginLeft:_0x8a37[1262],lineHeight:1,backgroundColor:_0x8a37[1270],color:_0x8a37[1271],fontSize:_0x8a37[1263],padding:_0x8a37[1264],cursor:_0x8a37[1272]});this[_0x8a37[1260]][_0x8a37[339]](_0x8a37[324],false);this[_0x8a37[1260]][_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](function (){this[_0x8a37[1273]](f);} ,this));g[_0x8a37[437]](this[_0x8a37[1260]]);var e=c(_0x8a37[1274]);e[_0x8a37[200]]({position:_0x8a37[713],zIndex:2,lineHeight:1,cursor:_0x8a37[1275],bottom:_0x8a37[1276],right:_0x8a37[1277],border:_0x8a37[1278],backgroundColor:_0x8a37[1270],width:_0x8a37[1279],height:_0x8a37[1279]});e[_0x8a37[339]](_0x8a37[324],false);g[_0x8a37[437]](e);g[_0x8a37[437]](f);return e;} ,imageThumbClick:function (h){var f=_0x8a37[1280]+c(h[_0x8a37[492]])[_0x8a37[339]](_0x8a37[1281])+_0x8a37[1282]+c(h[_0x8a37[492]])[_0x8a37[339]](_0x8a37[739])+_0x8a37[632];var g=this[_0x8a37[543]]();if(this[_0x8a37[25]][_0x8a37[206]]&&c(g)[_0x8a37[732]](_0x8a37[103])[_0x8a37[497]]()==0){f=_0x8a37[579]+f+_0x8a37[581];} ;this[_0x8a37[1283]](f,true);} ,imageCallbackLink:function (){var f=c(_0x8a37[1218])[_0x8a37[322]]();if(f!==_0x8a37[28]){var e=_0x8a37[1280]+f+_0x8a37[632];if(this[_0x8a37[25]][_0x8a37[205]]===false){e=_0x8a37[579]+e+_0x8a37[581];} ;this[_0x8a37[1283]](e,true);} else {this[_0x8a37[1140]]();} ;} ,imageCallback:function (e){this[_0x8a37[1283]](e);} ,imageInsert:function (f,h){this[_0x8a37[530]]();if(f!==false){var e=_0x8a37[28];if(h!==true){e=_0x8a37[1280]+f[_0x8a37[1080]]+_0x8a37[632];var g=this[_0x8a37[543]]();if(this[_0x8a37[25]][_0x8a37[206]]&&c(g)[_0x8a37[732]](_0x8a37[103])[_0x8a37[497]]()==0){e=_0x8a37[579]+e+_0x8a37[581];} ;} else {e=f;} ;this[_0x8a37[471]](_0x8a37[799],e,false);var j=c(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1284]));if(j[_0x8a37[20]]){j[_0x8a37[325]](_0x8a37[443]);} else {j=false;} ;this[_0x8a37[355]]();h!==true&&this[_0x8a37[389]](_0x8a37[477],j,f);} ;this[_0x8a37[1140]]();this[_0x8a37[616]]();} ,modalTemplatesInit:function (){c[_0x8a37[195]](this[_0x8a37[25]],{modal_file:String()+_0x8a37[1285]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1185]]+_0x8a37[1286]+this[_0x8a37[25]][_0x8a37[1180]]+_0x8a37[1287],modal_image_edit:String()+_0x8a37[1288]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[739]]+_0x8a37[1289]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[47]]+_0x8a37[1290]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1291]]+_0x8a37[1292]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1293]]+_0x8a37[1294]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1226]]+_0x8a37[1295]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[708]]+_0x8a37[1296]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[788]]+_0x8a37[1297]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[787]]+_0x8a37[1298]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1299]]+_0x8a37[1300]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1301]]+_0x8a37[1302]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1303]]+_0x8a37[1304],modal_image:String()+_0x8a37[1305]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1306]]+_0x8a37[1307]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1308]]+_0x8a37[1309]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[47]]+_0x8a37[1310]+this[_0x8a37[25]][_0x8a37[514]]+_0x8a37[1311]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1312]]+_0x8a37[1313]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1301]]+_0x8a37[1314]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1315]]+_0x8a37[1304],modal_link:String()+_0x8a37[1316]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[590]]+_0x8a37[1317]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1291]]+_0x8a37[1318]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1301]]+_0x8a37[1319]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1315]]+_0x8a37[1304],modal_table:String()+_0x8a37[1320]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1321]]+_0x8a37[1322]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1323]]+_0x8a37[1324]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1301]]+_0x8a37[1325]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1315]]+_0x8a37[1304],modal_video:String()+_0x8a37[1326]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1327]]+_0x8a37[1328]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1301]]+_0x8a37[1329]+this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1315]]+_0x8a37[1304]});} ,modalInit:function (o,l,f,p){var m=c(_0x8a37[1330]);if(!m[_0x8a37[20]]){this[_0x8a37[1331]]=m=c(_0x8a37[1332]);c(_0x8a37[66])[_0x8a37[694]](this.$overlay);} ;if(this[_0x8a37[25]][_0x8a37[1333]]){m[_0x8a37[248]]()[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](this[_0x8a37[1140]],this));} ;var h=c(_0x8a37[1334]);if(!h[_0x8a37[20]]){this[_0x8a37[1335]]=h=c(_0x8a37[1336]);c(_0x8a37[66])[_0x8a37[437]](this.$modal);} ;c(_0x8a37[1337])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](this[_0x8a37[1140]],this));this[_0x8a37[1338]]=c[_0x8a37[469]](function (q){if(q[_0x8a37[549]]===this[_0x8a37[549]][_0x8a37[728]]){this[_0x8a37[1140]]();return false;} ;} ,this);c(document)[_0x8a37[612]](this[_0x8a37[1338]]);this[_0x8a37[323]][_0x8a37[612]](this[_0x8a37[1338]]);this[_0x8a37[1339]]=false;if(l[_0x8a37[510]](_0x8a37[1073])==0){this[_0x8a37[1339]]=c(l);c(_0x8a37[1340])[_0x8a37[820]]()[_0x8a37[437]](this[_0x8a37[1339]][_0x8a37[43]]());this[_0x8a37[1339]][_0x8a37[43]](_0x8a37[28]);} else {c(_0x8a37[1340])[_0x8a37[820]]()[_0x8a37[437]](l);} ;h[_0x8a37[363]](_0x8a37[1341])[_0x8a37[43]](o);if( typeof c[_0x8a37[7]][_0x8a37[1342]]!==_0x8a37[12]){h[_0x8a37[1342]]({handle:_0x8a37[1341]});h[_0x8a37[363]](_0x8a37[1341])[_0x8a37[200]](_0x8a37[1343],_0x8a37[1344]);} ;var e=c(_0x8a37[1209]);if(e[_0x8a37[20]]){var j=this;e[_0x8a37[363]](_0x8a37[698])[_0x8a37[19]](function (q,r){q++;c(r)[_0x8a37[480]](_0x8a37[741],function (t){t[_0x8a37[507]]();e[_0x8a37[363]](_0x8a37[698])[_0x8a37[327]](_0x8a37[1212]);c(this)[_0x8a37[448]](_0x8a37[1212]);c(_0x8a37[1208])[_0x8a37[435]]();c(_0x8a37[1345]+q)[_0x8a37[248]]();c(_0x8a37[1346])[_0x8a37[322]](q);if(j[_0x8a37[426]]()===false){var s=h[_0x8a37[1347]]();h[_0x8a37[200]](_0x8a37[1348],_0x8a37[1349]+(s+10)/2+_0x8a37[453]);} ;} );} );} ;h[_0x8a37[363]](_0x8a37[1350])[_0x8a37[480]](_0x8a37[741],c[_0x8a37[469]](this[_0x8a37[1140]],this));var n=h[_0x8a37[363]](_0x8a37[1351]);var g=n[_0x8a37[497]]();if(g>0){c(n)[_0x8a37[200]](_0x8a37[202],(f/g)+_0x8a37[453]);} ;if(this[_0x8a37[25]][_0x8a37[429]]===true){this[_0x8a37[1352]]=this[_0x8a37[209]][_0x8a37[66]][_0x8a37[528]];} else {this[_0x8a37[1352]]=this[_0x8a37[323]][_0x8a37[528]]();} ;if(this[_0x8a37[426]]()===false){h[_0x8a37[200]]({position:_0x8a37[711],top:_0x8a37[1353],left:_0x8a37[1269],width:f+_0x8a37[453],marginLeft:_0x8a37[1349]+(f/2)+_0x8a37[453]})[_0x8a37[248]]();this[_0x8a37[1354]]=c(document[_0x8a37[66]])[_0x8a37[200]](_0x8a37[1355]);c(document[_0x8a37[66]])[_0x8a37[200]](_0x8a37[1355],_0x8a37[716]);} else {h[_0x8a37[200]]({position:_0x8a37[711],width:_0x8a37[707],height:_0x8a37[707],top:_0x8a37[1356],left:_0x8a37[1356],margin:_0x8a37[1356],minHeight:_0x8a37[1357]})[_0x8a37[248]]();} ;if( typeof p===_0x8a37[1358]){p();} ;setTimeout(c[_0x8a37[469]](function (){this[_0x8a37[389]](_0x8a37[1359]);} ,this),11);c(document)[_0x8a37[314]](_0x8a37[1360]);if(this[_0x8a37[426]]()===false){setTimeout(function (){var q=h[_0x8a37[1347]]();h[_0x8a37[200]]({top:_0x8a37[1269],height:_0x8a37[533],minHeight:_0x8a37[533],marginTop:_0x8a37[1349]+(q+10)/2+_0x8a37[453]});} ,10);} ;h[_0x8a37[363]](_0x8a37[1363])[_0x8a37[1362]](function (q){if(q[_0x8a37[392]]===13){h[_0x8a37[363]](_0x8a37[1361])[_0x8a37[741]]();q[_0x8a37[507]]();} ;} );} ,modalClose:function (){c(_0x8a37[1337])[_0x8a37[314]](_0x8a37[741],this[_0x8a37[1140]]);c(_0x8a37[1334])[_0x8a37[730]](_0x8a37[1364],c[_0x8a37[469]](function (){var e=c(_0x8a37[1340]);if(this[_0x8a37[1339]]!==false){this[_0x8a37[1339]][_0x8a37[43]](e[_0x8a37[43]]());this[_0x8a37[1339]]=false;} ;e[_0x8a37[43]](_0x8a37[28]);if(this[_0x8a37[25]][_0x8a37[1333]]){c(_0x8a37[1330])[_0x8a37[435]]()[_0x8a37[314]](_0x8a37[741],this[_0x8a37[1140]]);} ;c(document)[_0x8a37[1365]](_0x8a37[612],this[_0x8a37[1338]]);this[_0x8a37[323]][_0x8a37[1365]](_0x8a37[612],this[_0x8a37[1338]]);this[_0x8a37[530]]();if(this[_0x8a37[25]][_0x8a37[429]]&&this[_0x8a37[1352]]){c(this[_0x8a37[209]][_0x8a37[66]])[_0x8a37[528]](this[_0x8a37[1352]]);} else {if(this[_0x8a37[25]][_0x8a37[429]]===false&&this[_0x8a37[1352]]){this[_0x8a37[323]][_0x8a37[528]](this[_0x8a37[1352]]);} ;} ;this[_0x8a37[389]](_0x8a37[1366]);} ,this));if(this[_0x8a37[426]]()===false){c(document[_0x8a37[66]])[_0x8a37[200]](_0x8a37[1355],this[_0x8a37[1354]]?this[_0x8a37[1354]]:_0x8a37[715]);} ;return false;} ,modalSetTab:function (e){c(_0x8a37[1208])[_0x8a37[435]]();c(_0x8a37[1209])[_0x8a37[363]](_0x8a37[698])[_0x8a37[327]](_0x8a37[1212])[_0x8a37[1145]](e-1)[_0x8a37[448]](_0x8a37[1212]);c(_0x8a37[1345]+e)[_0x8a37[248]]();} ,s3handleFileSelect:function (l){var h=l[_0x8a37[492]][_0x8a37[506]];for(var g=0,j;j=h[g];g++){this[_0x8a37[516]](j);} ;} ,s3uploadFile:function (e){this[_0x8a37[1368]](e,c[_0x8a37[469]](function (f){this[_0x8a37[1367]](e,f);} ,this));} ,s3executeOnSignedUrl:function (e,h){var f= new XMLHttpRequest();var g=_0x8a37[964];if(this[_0x8a37[25]][_0x8a37[513]][_0x8a37[593]](/\?/)!=_0x8a37[235]){g=_0x8a37[414];} ;f[_0x8a37[360]](_0x8a37[1369],this[_0x8a37[25]][_0x8a37[513]]+g+_0x8a37[674]+e[_0x8a37[442]]+_0x8a37[1370]+e[_0x8a37[509]],true);if(f[_0x8a37[1371]]){f[_0x8a37[1371]](_0x8a37[1372]);} ;f[_0x8a37[1373]]=function (j){if(this[_0x8a37[1374]]==4&&this[_0x8a37[1375]]==200){c(_0x8a37[1377])[_0x8a37[1376]]();h(decodeURIComponent(this[_0x8a37[1378]]));} else {if(this[_0x8a37[1374]]==4&&this[_0x8a37[1375]]!=200){} ;} ;} ;f[_0x8a37[1379]]();} ,s3createCORSRequest:function (g,e){var f= new XMLHttpRequest();if(_0x8a37[1380] in f){f[_0x8a37[360]](g,e,true);} else {if( typeof XDomainRequest!=_0x8a37[12]){f= new XDomainRequest();f[_0x8a37[360]](g,e);} else {f=null;} ;} ;return f;} ,s3uploadToS3:function (f,e){var g=this[_0x8a37[1382]](_0x8a37[1381],e);if(!g){} else {g[_0x8a37[538]]=c[_0x8a37[469]](function (){if(g[_0x8a37[1375]]==200){c(_0x8a37[1383])[_0x8a37[435]]();var l=e[_0x8a37[445]](_0x8a37[964]);if(!l[0]){return false;} ;this[_0x8a37[530]]();var h=_0x8a37[28];h=_0x8a37[1280]+l[0]+_0x8a37[632];if(this[_0x8a37[25]][_0x8a37[206]]){h=_0x8a37[579]+h+_0x8a37[581];} ;this[_0x8a37[471]](_0x8a37[799],h,false);var j=c(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1284]));if(j[_0x8a37[20]]){j[_0x8a37[325]](_0x8a37[443]);} else {j=false;} ;this[_0x8a37[355]]();this[_0x8a37[389]](_0x8a37[477],j,false);this[_0x8a37[1140]]();this[_0x8a37[616]]();} else {} ;} ,this);g[_0x8a37[1384]]=function (){} ;g[_0x8a37[1306]][_0x8a37[1385]]=function (h){} ;g[_0x8a37[1387]](_0x8a37[1386],f[_0x8a37[509]]);g[_0x8a37[1387]](_0x8a37[1388],_0x8a37[1389]);g[_0x8a37[1379]](f);} ;} ,uploadInit:function (g,e){this[_0x8a37[1390]]={url:false,success:false,error:false,start:false,trigger:false,auto:false,input:false};c[_0x8a37[195]](this[_0x8a37[1390]],e);var f=c(_0x8a37[1073]+g);if(f[_0x8a37[20]]&&f[0][_0x8a37[368]]===_0x8a37[1391]){this[_0x8a37[1390]][_0x8a37[385]]=f;this[_0x8a37[1392]]=c(f[0][_0x8a37[110]]);} else {this[_0x8a37[1392]]=f;} ;this[_0x8a37[1393]]=this[_0x8a37[1392]][_0x8a37[339]](_0x8a37[1394]);if(this[_0x8a37[1390]][_0x8a37[533]]){c(this[_0x8a37[1390]][_0x8a37[385]])[_0x8a37[391]](c[_0x8a37[469]](function (h){this[_0x8a37[1392]][_0x8a37[1395]](function (j){return false;} );this[_0x8a37[1396]](h);} ,this));} else {if(this[_0x8a37[1390]][_0x8a37[1397]]){c(_0x8a37[1073]+this[_0x8a37[1390]][_0x8a37[1397]])[_0x8a37[741]](c[_0x8a37[469]](this[_0x8a37[1396]],this));} ;} ;} ,uploadSubmit:function (f){c(_0x8a37[1377])[_0x8a37[1376]]();this[_0x8a37[1400]](this[_0x8a37[1398]],this[_0x8a37[1399]]());} ,uploadFrame:function (){this[_0x8a37[443]]=_0x8a37[1401]+Math[_0x8a37[1136]](Math[_0x8a37[1135]]()*99999);var f=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);var e=_0x8a37[1402]+this[_0x8a37[443]]+_0x8a37[1403]+this[_0x8a37[443]]+_0x8a37[1404];f[_0x8a37[791]]=e;c(f)[_0x8a37[766]](_0x8a37[66]);if(this[_0x8a37[1390]][_0x8a37[196]]){this[_0x8a37[1390]][_0x8a37[196]]();} ;c(_0x8a37[1073]+this[_0x8a37[443]])[_0x8a37[622]](c[_0x8a37[469]](this[_0x8a37[1405]],this));return this[_0x8a37[443]];} ,uploadForm:function (j,h){if(this[_0x8a37[1390]][_0x8a37[385]]){var l=_0x8a37[1406]+this[_0x8a37[443]],e=_0x8a37[1407]+this[_0x8a37[443]];this[_0x8a37[110]]=c(_0x8a37[1408]+this[_0x8a37[1390]][_0x8a37[1409]]+_0x8a37[1410]+h+_0x8a37[1403]+l+_0x8a37[1411]+l+_0x8a37[1412]);if(this[_0x8a37[25]][_0x8a37[1071]]!==false&& typeof this[_0x8a37[25]][_0x8a37[1071]]===_0x8a37[1072]){c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[1071]],c[_0x8a37[469]](function (n,f){if(f!=null&&f.toString()[_0x8a37[510]](_0x8a37[1073])===0){f=c(f)[_0x8a37[322]]();} ;var o=c(_0x8a37[1413],{type:_0x8a37[716],name:n,value:f});c(this[_0x8a37[110]])[_0x8a37[437]](o);} ,this));} ;var g=this[_0x8a37[1390]][_0x8a37[385]];var m=c(g)[_0x8a37[602]]();c(g)[_0x8a37[339]](_0x8a37[443],e)[_0x8a37[778]](m)[_0x8a37[766]](this[_0x8a37[110]]);c(this[_0x8a37[110]])[_0x8a37[200]](_0x8a37[724],_0x8a37[713])[_0x8a37[200]](_0x8a37[705],_0x8a37[1353])[_0x8a37[200]](_0x8a37[708],_0x8a37[1353])[_0x8a37[766]](_0x8a37[66]);this[_0x8a37[110]][_0x8a37[1395]]();} else {j[_0x8a37[339]](_0x8a37[492],h)[_0x8a37[339]](_0x8a37[1416],_0x8a37[1417])[_0x8a37[339]](_0x8a37[1414],_0x8a37[1415])[_0x8a37[339]](_0x8a37[1394],this[_0x8a37[1390]][_0x8a37[1409]]);this[_0x8a37[1398]][_0x8a37[1395]]();} ;} ,uploadLoaded:function (){var h=c(_0x8a37[1073]+this[_0x8a37[443]])[0],j;if(h[_0x8a37[1418]]){j=h[_0x8a37[1418]];} else {if(h[_0x8a37[626]]){j=h[_0x8a37[626]][_0x8a37[209]];} else {j=window[_0x8a37[1419]][this[_0x8a37[443]]][_0x8a37[209]];} ;} ;if(this[_0x8a37[1390]][_0x8a37[1420]]){c(_0x8a37[1377])[_0x8a37[435]]();if( typeof j!==_0x8a37[12]){var g=j[_0x8a37[66]][_0x8a37[791]];var f=g[_0x8a37[600]](/\{(.|\n)*\}/)[0];f=f[_0x8a37[341]](/^\[/,_0x8a37[28]);f=f[_0x8a37[341]](/\]$/,_0x8a37[28]);var e=c[_0x8a37[676]](f);if( typeof e[_0x8a37[18]]==_0x8a37[12]){this[_0x8a37[1390]][_0x8a37[1420]](e);} else {this[_0x8a37[1390]][_0x8a37[18]](this,e);this[_0x8a37[1140]]();} ;} else {this[_0x8a37[1140]]();alert(_0x8a37[1421]);} ;} ;this[_0x8a37[1392]][_0x8a37[339]](_0x8a37[1394],this[_0x8a37[1393]]);this[_0x8a37[1392]][_0x8a37[339]](_0x8a37[492],_0x8a37[28]);} ,draguploadInit:function (f,e){this[_0x8a37[1422]]=c[_0x8a37[195]]({url:false,success:false,error:false,preview:false,uploadFields:false,text:this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1423]],atext:this[_0x8a37[25]][_0x8a37[243]][_0x8a37[1424]],uploadParam:false},e);if(window[_0x8a37[504]]===undefined){return false;} ;this[_0x8a37[1425]]=c(_0x8a37[1426]);this[_0x8a37[1427]]=c(_0x8a37[1428]+this[_0x8a37[1422]][_0x8a37[590]]+_0x8a37[1429]);this[_0x8a37[1430]]=c(_0x8a37[1431]+this[_0x8a37[1422]][_0x8a37[1432]]+_0x8a37[1429]);this[_0x8a37[1425]][_0x8a37[437]](this[_0x8a37[1427]]);c(f)[_0x8a37[778]](this[_0x8a37[1425]]);c(f)[_0x8a37[778]](this[_0x8a37[1430]]);this[_0x8a37[1427]][_0x8a37[480]](_0x8a37[1433],c[_0x8a37[469]](function (){return this[_0x8a37[1434]]();} ,this));this[_0x8a37[1427]][_0x8a37[480]](_0x8a37[1435],c[_0x8a37[469]](function (){return this[_0x8a37[1436]]();} ,this));this[_0x8a37[1427]][_0x8a37[317]](0)[_0x8a37[1437]]=c[_0x8a37[469]](function (g){g[_0x8a37[507]]();this[_0x8a37[1427]][_0x8a37[327]](_0x8a37[1439])[_0x8a37[448]](_0x8a37[1438]);this[_0x8a37[515]](this[_0x8a37[1422]][_0x8a37[1409]],g[_0x8a37[505]][_0x8a37[506]][0],false,false,false,this[_0x8a37[1422]][_0x8a37[1440]]);} ,this);} ,dragUploadAjax:function (h,l,f,g,n,m){if(!f){var o=c[_0x8a37[1442]][_0x8a37[1441]]();if(o[_0x8a37[1306]]){o[_0x8a37[1306]][_0x8a37[1445]](_0x8a37[1443],c[_0x8a37[469]](this[_0x8a37[1444]],this),false);} ;c[_0x8a37[1446]]({xhr:function (){return o;} });} ;this[_0x8a37[389]](_0x8a37[1438],n);var j= new FormData();if(m!==false){j[_0x8a37[437]](m,l);} else {j[_0x8a37[437]](_0x8a37[31],l);} ;if(this[_0x8a37[25]][_0x8a37[1071]]!==false&& typeof this[_0x8a37[25]][_0x8a37[1071]]===_0x8a37[1072]){c[_0x8a37[19]](this[_0x8a37[25]][_0x8a37[1071]],c[_0x8a37[469]](function (p,e){if(e!=null&&e.toString()[_0x8a37[510]](_0x8a37[1073])===0){e=c(e)[_0x8a37[322]]();} ;j[_0x8a37[437]](p,e);} ,this));} ;c[_0x8a37[678]]({url:h,dataType:_0x8a37[43],data:j,cache:false,contentType:false,processData:false,type:_0x8a37[1417],success:c[_0x8a37[469]](function (q){q=q[_0x8a37[341]](/^\[/,_0x8a37[28]);q=q[_0x8a37[341]](/\]$/,_0x8a37[28]);var p=( typeof q===_0x8a37[10]?c[_0x8a37[676]](q):q);if(f){g[_0x8a37[730]](_0x8a37[1447],function (){c(this)[_0x8a37[321]]();} );var e=c(_0x8a37[1448]);e[_0x8a37[339]](_0x8a37[357],p[_0x8a37[1080]])[_0x8a37[339]](_0x8a37[443],_0x8a37[1449]);this[_0x8a37[1450]](n,e[0]);var r=c(this[_0x8a37[323]][_0x8a37[363]](_0x8a37[1451]));if(r[_0x8a37[20]]){r[_0x8a37[325]](_0x8a37[443]);} else {r=false;} ;this[_0x8a37[355]]();this[_0x8a37[616]]();if(r){this[_0x8a37[389]](_0x8a37[477],r,p);} ;if( typeof p[_0x8a37[18]]!==_0x8a37[12]){this[_0x8a37[389]](_0x8a37[1205],p);} ;} else {if( typeof p[_0x8a37[18]]==_0x8a37[12]){this[_0x8a37[1422]][_0x8a37[1420]](p);} else {this[_0x8a37[1422]][_0x8a37[18]](this,p);this[_0x8a37[1422]][_0x8a37[1420]](false);} ;} ;} ,this)});} ,draguploadOndrag:function (){this[_0x8a37[1427]][_0x8a37[448]](_0x8a37[1439]);return false;} ,draguploadOndragleave:function (){this[_0x8a37[1427]][_0x8a37[327]](_0x8a37[1439]);return false;} ,uploadProgress:function (g,h){var f=g[_0x8a37[1452]]?parseInt(g[_0x8a37[1452]]/g[_0x8a37[1453]]*100,10):g;this[_0x8a37[1427]][_0x8a37[590]](_0x8a37[1454]+f+_0x8a37[1455]+(h||_0x8a37[28]));} ,isMobile:function (){return /(iPhone|iPod|BlackBerry|Android)/[_0x8a37[577]](navigator[_0x8a37[519]]);} ,isIPad:function (){return /iPad/[_0x8a37[577]](navigator[_0x8a37[519]]);} ,normalize:function (e){if( typeof (e)===_0x8a37[12]){return 0;} ;return parseInt(e[_0x8a37[341]](_0x8a37[453],_0x8a37[28]),10);} ,outerHtml:function (e){return c(_0x8a37[969])[_0x8a37[437]](c(e)[_0x8a37[1145]](0)[_0x8a37[602]]())[_0x8a37[43]]();} ,stripHtml:function (f){var e=document[_0x8a37[570]](_0x8a37[85]);e[_0x8a37[791]]=f;return e[_0x8a37[1023]]||e[_0x8a37[1024]]||_0x8a37[28];} ,isString:function (e){return Object[_0x8a37[5]][_0x8a37[1456]][_0x8a37[8]](e)==_0x8a37[1457];} ,isEmpty:function (e){e=e[_0x8a37[341]](/&#x200b;|<br>|<br\/>|&nbsp;/gi,_0x8a37[28]);e=e[_0x8a37[341]](/\s/g,_0x8a37[28]);e=e[_0x8a37[341]](/^<p>[^\W\w\D\d]*?<\/p>$/i,_0x8a37[28]);return e==_0x8a37[28];} ,isIe11:function (){return !!navigator[_0x8a37[519]][_0x8a37[600]](/Trident\/7\./);} ,browser:function (f){var g=navigator[_0x8a37[519]][_0x8a37[784]]();var e=/(opr)[\/]([\w.]+)/[_0x8a37[743]](g)||/(chrome)[ \/]([\w.]+)/[_0x8a37[743]](g)||/(webkit)[ \/]([\w.]+).*(safari)[ \/]([\w.]+)/[_0x8a37[743]](g)||/(webkit)[ \/]([\w.]+)/[_0x8a37[743]](g)||/(opera)(?:.*version|)[ \/]([\w.]+)/[_0x8a37[743]](g)||/(msie) ([\w.]+)/[_0x8a37[743]](g)||g[_0x8a37[510]](_0x8a37[1458])>=0&&/(rv)(?::| )([\w.]+)/[_0x8a37[743]](g)||g[_0x8a37[510]](_0x8a37[1459])<0&&/(mozilla)(?:.*? rv:([\w.]+)|)/[_0x8a37[743]](g)||[];if(f==_0x8a37[521]){return e[2];} ;if(f==_0x8a37[517]){return (e[1]==_0x8a37[1187]||e[1]==_0x8a37[517]);} ;if(e[1]==_0x8a37[1460]){return f==_0x8a37[238];} ;if(e[1]==_0x8a37[1461]){return f==_0x8a37[517];} ;return f==e[1];} ,oldIE:function (){if(this[_0x8a37[239]](_0x8a37[238])&&parseInt(this[_0x8a37[239]](_0x8a37[521]),10)<9){return true;} ;return false;} ,getFragmentHtml:function (f){var e=f[_0x8a37[1462]](true);var g=this[_0x8a37[209]][_0x8a37[570]](_0x8a37[107]);g[_0x8a37[793]](e);return g[_0x8a37[791]];} ,extractContent:function (){var e=this[_0x8a37[323]][0];var g=this[_0x8a37[209]][_0x8a37[792]]();var f;while((f=e[_0x8a37[794]])){g[_0x8a37[793]](f);} ;return g;} ,isParentRedactor:function (e){if(!e){return false;} ;if(this[_0x8a37[25]][_0x8a37[204]]){return e;} ;if(c(e)[_0x8a37[499]](_0x8a37[1109])[_0x8a37[20]]==0||c(e)[_0x8a37[496]](_0x8a37[328])){return false;} else {return e;} ;} ,currentOrParentIs:function (e){var f=this[_0x8a37[543]](),g=this[_0x8a37[544]]();return f&&f[_0x8a37[368]]===e?f:g&&g[_0x8a37[368]]===e?g:false;} ,isEndOfElement:function (){var f=this[_0x8a37[545]]();var h=this[_0x8a37[1020]](f);var g=c[_0x8a37[380]](c(f)[_0x8a37[590]]())[_0x8a37[341]](/\n\r\n/g,_0x8a37[28]);var e=g[_0x8a37[20]];if(h==e){return true;} else {return false;} ;} ,isFocused:function (){var e,f=this[_0x8a37[565]]();if(f&&f[_0x8a37[566]]&&f[_0x8a37[566]]>0){e=f[_0x8a37[790]](0)[_0x8a37[985]];} ;if(!e){return false;} ;if(this[_0x8a37[25]][_0x8a37[204]]){if(this[_0x8a37[1463]]()[_0x8a37[4]]()){return !this[_0x8a37[323]][_0x8a37[1000]](e);} else {return true;} ;} ;return c(e)[_0x8a37[732]](_0x8a37[1109])[_0x8a37[20]]!=0;} ,removeEmptyAttr:function (f,e){if(c(f)[_0x8a37[339]](e)==_0x8a37[28]){c(f)[_0x8a37[325]](e);} ;} ,removeFromArrayByValue:function (g,f){var e=null;while((e=g[_0x8a37[510]](f))!==-1){g[_0x8a37[237]](e,1);} ;return g;} };b[_0x8a37[5]][_0x8a37[21]][_0x8a37[5]]=b[_0x8a37[5]];c[_0x8a37[22]][_0x8a37[7]][_0x8a37[615]]=function (s,z,e,C,E){var h=/(^|&lt;|\s)(www\..+?\..+?)([.),]?)(\s|\.\s+|\)|&gt;|$)/,g=/(^|&lt;|\s)(((https?|ftp):\/\/|mailto:).+?)([.),]?)(\s|\.\s+|\)|&gt;|$)/,u=/(https?:\/\/.*\.(?:png|jpg|jpeg|gif))/gi,D=/https?:\/\/(?:[0-9A-Z-]+\.)?(?:youtu\.be\/|youtube\.com\S*[^\w\-\s])([\w\-]{11})(?=[^\w\-]|$)(?![?=&+%\w.-]*(?:['"][^<>]*>|<\/a>))[?=&+%\w.-]*/ig,B=/https?:\/\/(www\.)?vimeo.com\/(\d+)($|\/)/;var f=(this[_0x8a37[323]]?this[_0x8a37[323]][_0x8a37[317]](0):this)[_0x8a37[1108]],A=f[_0x8a37[20]];while(A--){var t=f[A];if(t[_0x8a37[568]]===3){var p=t[_0x8a37[599]];if(C&&p){var q=_0x8a37[1464],x=_0x8a37[1465];if(p[_0x8a37[600]](D)){p=p[_0x8a37[341]](D,q+_0x8a37[1466]+x);c(t)[_0x8a37[319]](p)[_0x8a37[321]]();} else {if(p[_0x8a37[600]](B)){p=p[_0x8a37[341]](B,q+_0x8a37[1467]+x);c(t)[_0x8a37[319]](p)[_0x8a37[321]]();} ;} ;} ;if(e&&p&&p[_0x8a37[600]](u)){p=p[_0x8a37[341]](u,_0x8a37[1468]);c(t)[_0x8a37[319]](p)[_0x8a37[321]]();} ;if(z&&p&&(p[_0x8a37[600]](h)||p[_0x8a37[600]](g))){var r=true;var o=true;while(r){var y;var j=h;var w=h[_0x8a37[743]](p);var v=g[_0x8a37[743]](p);if(w&&w[2]&&v&&v[2]){var m=p[_0x8a37[510]](w[2]);var l=p[_0x8a37[510]](v[2]);if(m<l){y=w;j=h;} else {y=v;j=g;} ;} else {if(w&&w[2]){y=w;j=h;} else {if(v&&v[2]){y=v;j=g;} ;} ;} ;r=(y&&y[_0x8a37[20]]);if(r){y=y[2];} ;if(r&&y&&y[_0x8a37[20]]>E){y=y[_0x8a37[672]](0,E)+_0x8a37[1094];} ;if(o){p=p[_0x8a37[341]](/&/g,_0x8a37[944])[_0x8a37[341]](/</g,_0x8a37[943])[_0x8a37[341]](/>/g,_0x8a37[942]);} ;if(r&&y){if(j==h){p=p[_0x8a37[341]](h,_0x8a37[1469]+s+_0x8a37[1470]+c[_0x8a37[380]](y)+_0x8a37[1471]);} else {p=p[_0x8a37[341]](g,_0x8a37[1472]+c[_0x8a37[380]](y)+_0x8a37[1473]);} ;} ;o=false;} ;c(t)[_0x8a37[319]](p)[_0x8a37[321]]();} ;} else {if(t[_0x8a37[568]]===1&&!/^(a|button|textarea)$/i[_0x8a37[577]](t[_0x8a37[368]])){c[_0x8a37[22]][_0x8a37[7]][_0x8a37[615]][_0x8a37[8]](t,s,z,e,C,E);} ;} ;} ;} ;} )(jQuery);
}

},{}],56:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"bloom-input\"><div class=\"bloom-editor-wrapper\"><div redactor=\"redactor\" ng-model=\"ngModel\" placeholder=\"{{placeholder}}\" tabindex=\"{{xtabindex}}\" class=\"bloom-editor\"></div><input type=\"file\" tabindex=\"-1\"/><button ng-click=\"save()\" tabindex=\"-1\" class=\"input-btn image\"><i class=\"fa fa-picture-o\"></i></button><button ng-click=\"submit()\" tabindex=\"{{xtabindexPlus}}\" class=\"input-btn create\">{{buttonText || 'Create'}}</button><div ng-show=\"loading\" style=\"width:calc({{progress}}% - 2px)\" class=\"upload-progress\"></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],57:[function(require,module,exports){
module.exports = function($scope, NotifsState, Notifs, Users, Session, $timeout) {
  var _this = this;
  this.Session = Session;
  this.list = [];
  this.open = false;
  this.toggle = function() {
    _this.open = !_this.open;
    if (_this.open) {
      return Notifs.updateLastRead(Session.me);
    }
  };
  this.calculateUnread = function() {
    return _this.unread = _this.list.filter(function(notif) {
      return notif.createdAt > _this.lastOpened;
    }).length;
  };
  this.updateLastRead = function() {
    Session.data.lastOpenedNotifs = Date.now();
    return Users.updateLastOpened(Session.me);
  };
  this.refresh = function() {
    var processResults;
    processResults = function(results) {
      _this.list = results.list;
      _this.lastOpened = results.lastOpened;
      _this.loaded = true;
      _this.calculateUnread();
      return $timeout(_this.refresh, 3000);
    };
    return Notifs.get(Session.me).then(processResults, processResults);
  };
  Session.load().then(function(data) {
    _this.lastOpened = Session.data.lastOpenedNotifs;
    return _this.refresh();
  });
  $scope.$watch((function() {
    return NotifsState.opened;
  }), function(opened, wasOpened) {
    if (wasOpened && !opened) {
      _this.updateLastRead();
    }
    if (!wasOpened && opened) {
      return _this.unread = 0;
    }
  });
  return this;
};


},{}],58:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return {
    restrict: 'E',
    scope: {
      db: '=',
      dbParams: '='
    },
    replace: true,
    template: require('./template.jade'),
    controller: 'NotifsCtrl',
    controllerAs: 'notifs'
  };
};


},{"./template.jade":65}],59:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return angular.module('bloom.notifs', ['bloom.session']).controller('NotifsCtrl', require('./controller')).service('Notifs', require('./service')).service('NotifsState', require('./state')).directive('notifs', require('./directive')).controller('NotifCtrl', require('./notif/controller')).directive('notif', require('./notif/directive'));
};


},{"./controller":57,"./directive":58,"./notif/controller":60,"./notif/directive":61,"./service":63,"./state":64}],60:[function(require,module,exports){
module.exports = function(Notifs, Forum, Users, Comments, $scope) {
  this.data = $scope.data;
  return this;
};


},{}],61:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return {
    restrict: 'E',
    scope: {
      db: '=',
      dbParams: '='
    },
    template: require('./template.jade'),
    controller: 'NotifCtrl',
    controllerAs: 'notif'
  };
};


},{"./template.jade":62}],62:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div ng-switch=\"db.type\" class=\"notif\"><a ui-sref=\"forum\" ng-switch-when=\"ask\"><div class=\"notifs-avatar\"><user-avatar id=\"db.data.from\"></user-avatar></div><div class=\"notif-content\"><span class=\"notif-user\"><user-name id=\"db.data.from\" link=\"false\"></user-name></span><span ng-if=\"db.data.type == 'post'\"> asked you to answer a post: <span>\"{{db.post.title}}\"</span></span><span ng-if=\"db.data.type == 'comment'\"> asked you to answer a comment: \"<div class=\"message\"><comment-content comment=\"db.comment\" length=\"100\" type=\"comment\"></comment-content></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>{{db.createdAt | ago}} ago</div></div></a><a ui-sref=\"forum.post({ id: db.data.postId })\" ng-switch-when=\"commentUpvote\"><div class=\"notifs-avatar\"><user-avatar id=\"db.comment.author\"></user-avatar></div><div class=\"notif-content\"><span class=\"notif-user\"><user-name id=\"db.comment.author\" link=\"false\"></user-name></span><span> upvoted your comment: \"<div class=\"message\"><comment-content comment=\"db.comment\" length=\"50\" type=\"comment\"></comment-content></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>{{db.createdAt | ago}} ago</div></div></a><a ui-sref=\"forum.post({ id: db.data.postId })\" ng-switch-when=\"commentReply\"><div class=\"notifs-avatar\"><user-avatar user=\"db.author\"></user-avatar></div><div class=\"notif-content\"><span class=\"notif-user\"><user-name user=\"db.author\" link=\"false\"></user-name></span><span> replied to your comment: \"<div class=\"message\"><comment-content comment=\"db.comment\" length=\"150\" type=\"comment\"></comment-content></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>{{db.createdAt | ago}} ago</div></div></a><a ui-sref=\"forum.post({ id: db.data.postId })\" ng-switch-when=\"postComment\"><div class=\"notifs-avatar\"><user-avatar user=\"db.user\"></user-avatar></div><div class=\"notif-content\"><span class=\"notif-user\"><user-name id=\"db.user\" link=\"false\"></user-name></span><span> replied to your post, <span ng-bind-html=\"db.post.title\" class=\"bold\"></span>: \"<div class=\"message\"><comment-content comment=\"db.comment\" length=\"100\" type=\"comment\"></comment-content></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>{{db.createdAt | ago}} ago</div></div></a><div class=\"clear\"></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],63:[function(require,module,exports){
var _this = this;

module.exports = function($q, API, Forum, Users, $timeout, Session, Comments) {
  _this.addMetadata = function(notif) {
    var addComment, addPost, addUser, def, fakeDef, filters;
    addPost = function(notif, postId) {
      var def;
      def = $q.defer();
      Forum.getPost(postId).then(function(post) {
        return def.resolve(_.extend(notif, {
          post: post
        }));
      });
      return def.promise;
    };
    addUser = function(notif, userId) {
      var def;
      def = $q.defer();
      Users.get(userId).then(function(user) {
        return def.resolve(_.extend(notif, {
          user: user
        }));
      });
      return def.promise;
    };
    addComment = function(notif, commentId) {
      var def;
      def = $q.defer();
      Comments.get(commentId).then(function(comment) {
        return def.resolve(_.extend(notif, {
          comment: comment
        }));
      });
      return def.promise;
    };
    fakeDef = $q.defer();
    filters = (function() {
      var _this = this;
      switch (notif.type) {
        case 'postComment':
          def = $q.defer();
          $q.all([addComment(notif, notif.data.commentId), addPost(notif, notif.data.postId)]).then(function() {
            return addUser(notif, notif.comment.author).then(function() {
              return def.resolve(notif);
            });
          });
          return def.promise;
        case 'commentReply':
          def = $q.defer();
          $q.all([addComment(notif, notif.data.commentId), addPost(notif, notif.data.postId)]).then(function() {
            return addUser(notif, notif.comment.author).then(function() {
              return def.resolve(notif);
            });
          });
          return def.promise;
        case 'commentUpvote':
          def = $q.defer();
          $q.all([addComment(notif, notif.data.commentId), addPost(notif, notif.data.postId)]).then(function() {
            return addUser(notif, notif.comment.author).then(function() {
              return def.resolve(notif);
            });
          });
          return def.promise;
        case 'ask':
          switch (notif.data.type) {
            case 'comment':
              return addComment(notif, notif.data.id);
            case 'post':
              return addPost(notif, notif.data.id);
          }
          break;
        default:
          return fakeDef.promise;
      }
    }).call(_this);
    fakeDef.resolve(notif);
    return filters;
  };
  _this.get = function(to) {
    var defer;
    defer = $q.defer();
    API.process(API.get("/notifs/" + Session.me)).then(function(results) {
      return $q.all(results.list.map(_this.addMetadata)).then(function(joinedList) {
        return defer.resolve({
          list: joinedList,
          lastOpened: results.lastOpened
        });
      });
    }, function() {
      return defer.resolve([]);
    });
    return defer.promise;
  };
  _this.updateLastRead = function(who) {
    return API.process(API.post("/notifs/" + who));
  };
  return _this;
};


},{}],64:[function(require,module,exports){
var _this = this;

module.exports = function() {
  _this.opened = false;
  return _this;
};


},{}],65:[function(require,module,exports){
var jade = require("jade/runtime");

module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"notifs\"><div ng-click=\"notifs.toggle()\" class=\"notifs-icon\"><i class=\"fa fa-globe\"></i><div class=\"notifs-unread\">13</div></div><div ng-if=\"notifs.open\" class=\"bloom-popover\"><div class=\"popover-container\"><div class=\"notifs-top\"><span><b>Notifications</b></span></div><div ng-if=\"!notifs.loaded\" class=\"notifs-loading\"><i class=\"fa fa-refresh fa-spin\"></i></div><div ng-if=\"notifs.loaded\"><div ng-if=\"notifs.list.length == 0\" class=\"notifs-none\">No notifications!</div><!-- ul.notifs-listli.new\n  .notif\n    a(href='http://www.thinkful.com/courses/IOS-001/unit/4/lesson/4/assignment/4?id=IOS-001:v1:content:45')\n      .notifs-avatar\n        .bloom-avatar\n          img(style='border-radius: 2px; width: 35px; height: 35px;', src='https://i.cloudup.com/oMpHZDGnX4-3000x3000.png')\n      .notif-content\n        span.notif-user\n          .bloom-username Aaron Hall\n        span\n          |  upvoted your comment: \n          .message\n            p\n              | \"I've never seen the other two, but they appear to be sporty. You may like that, but your wife may not, especially if she is inexperienced. Of the two, the Buccaneer looks more comfortable.\"\n        .notif-time\n          i.fa.fa-clock-o\n          | 3m ago\nli.new\n  .notif\n    a(href='http://www.thinkful.com/courses/IOS-001/unit/4/lesson/3/assignment/5?id=IOS-001:v1:content:39')\n      .notifs-avatar\n        .bloom-avatar\n          img(style='border-radius: 2px; width: 35px; height: 35px;', src='https://i.cloudup.com/EwJJfSLoQ1-3000x3000.png')\n      .notif-content\n        span.notif-user\n          .bloom-username Andrew Hsu\n        span\n          |  replied to your comment: \n          .message\n            p\n              | \"Any thoughts on these boats? Any known issues I should be aware of or look for? Thoughts on their sailing performance or offshore seaworthyness?\"\n        .notif-time\n          i.fa.fa-clock-o\n          | 15m ago\nli\n  .notif\n    a(href='http://www.thinkful.com/courses/IOS-001/unit/4/lesson/3/assignment/5?id=IOS-001:v1:content:39')\n      .notifs-avatar\n        .bloom-avatar\n          img(style='border-radius: 2px; width: 35px; height: 35px;', src='https://i.cloudup.com/u3QVFmDq5l-3000x3000.png')\n      .notif-content\n        span.notif-user\n          .bloom-username Nick Cammarata\n        span\n          |  started a discussion: \n          .message\n            p\n              | \"I dare say that era NC would be something of a motor sailor in light airs but for the coconut run should be fine though maybe sailing ability would be more of an issue once you are tromping around Australia and/or heading home.\"\n        .notif-time\n          i.fa.fa-clock-o\n          | 1h ago\nli\n  .notif\n    a(href='http://www.thinkful.com/courses/IOS-001/unit/4/lesson/3/assignment/5?id=IOS-001:v1:content:39')\n      .notifs-avatar\n        .bloom-avatar\n          img(style='border-radius: 2px; width: 35px; height: 35px;', src='https://i.cloudup.com/TzOmRmNoty-3000x3000.png')\n      .notif-content\n        span.notif-user\n          .bloom-username Matt Johnston\n        span\n          |  answered your question: \n          .message\n            p\n              | \"The teak rails are nice and sturdy, but once past a beam reach I found that an outboard barber hauler was necessary to prevent chafe on the jib sheet.\"\n        .notif-time\n          i.fa.fa-clock-o\n          | 3h ago\n          --><ul class=\"notifs-list\"><li class=\"new\"><div class=\"notif\"><a href=\"http://localhost:9000/forum/Fy_d9q3KRm6X0z_bPsZA-w/comments/4RDMy0L1SsyB3RD1fvcpxA\" ng-click=\"notifs.toggle()\"><div class=\"notifs-avatar\"><div class=\"bloom-avatar\"><img src=\"/images/users/xchris.png\"/></div></div><div class=\"notif-content\"><span class=\"notif-user\">Chris Young</span><span> replied to your comment: \"<div style=\"font-weight: normal;\" class=\"message\"><p>No, the locust bean gum works in synergy with xanthan. You need both together.</p></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>3m ago</div></div></a><div class=\"clear\"></div></div></li><li><div class=\"notif\"><a href=\"http://localhost:9000/forum/Fy_d9q3KRm6X0z_bPsZA-w/comments/4RDMy0L1SsyB3RD1fvcpxA\" ng-click=\"notifs.toggle()\"><div class=\"notifs-avatar\"><div class=\"bloom-avatar\"><img src=\"/images/users/xnick.png\"/></div></div><div class=\"notif-content\"><span class=\"notif-user\">Nick Cammarata</span><span> replied your comment: \"<div style=\"font-weight: normal;\" class=\"message\"><p>What a cool group of techniques :) Dumb question: what's the purpose of the shells if the \"eggs\" are served on a...</p></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>2h ago</div></div></a><div class=\"clear\"></div></div></li><li><div class=\"notif\"><a href=\"http://localhost:9000/forum/Fy_d9q3KRm6X0z_bPsZA-w/comments/4RDMy0L1SsyB3RD1fvcpxA\" ng-click=\"notifs.toggle()\"><div class=\"notifs-avatar\"><div class=\"bloom-avatar\"><img src=\"/images/users/xandrew.png\"/></div></div><div class=\"notif-content\"><span class=\"notif-user\">Andrew Hsu</span><span> upvoted your comment: \"<div style=\"font-weight:normal;\" class=\"message\"><p>Unbelievable. If I ever need to explain to anyone what ChefSteps is I will just show them this recipe and video. This is fantastic and the amount of information, etc...</p></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>5h ago</div></div></a><div class=\"clear\"></div></div></li><li><div class=\"notif\"><a href=\"http://localhost:9000/forum/Fy_d9q3KRm6X0z_bPsZA-w/comments/4RDMy0L1SsyB3RD1fvcpxA\" ng-click=\"notifs.toggle()\"><div class=\"notifs-avatar\"><div class=\"bloom-avatar\"><img src=\"/images/users/xgrant.png\"/></div></div><div class=\"notif-content\"><span class=\"notif-user\">Grant Lee Crilly</span><span> replied to your comment: \"<div style=\"font-weight:normal;\" class=\"message\"><p>We offer hacks for every technical piece of equipment used in the steps so anyone can make this within reason. But it's a lot of work, it is a functional concept car for sure.</p></div>\"</span><div class=\"notif-time\"><i class=\"fa fa-clock-o\"></i>1d ago</div></div></a><div class=\"clear\"></div></div></li></ul></div></div><div class=\"popover-arrow\"></div></div></div>");;return buf.join("");
};
},{"jade/runtime":78}],66:[function(require,module,exports){
var _this = this;

module.exports = function() {
  return angular.module('bloom.users.helpers', []).controller('UserAvatarCtrl', function($scope, Users, BloomSettings) {
    var _this = this;
    $scope.hover = false;
    $scope.$watchCollection('user', function(val) {
      if (val == null) {
        return;
      }
      _this.user = val;
      _this.avatarUrl = _this.user.avatarUrl;
      return _this.profileLink = _this.user.profileLink;
    });
    return this;
  }).directive('userAvatar', function() {
    return {
      restrict: 'E',
      scope: {
        user: '=',
        id: '=',
        hover: '@',
        link: '@',
        size: '@'
      },
      controller: 'UserAvatarCtrl as userAvatar',
      template: "<div class=\"bloom-avatar hover-target\">\n  <a ng-href=\"userAvatar.profileLink\">\n    <img ng-if=\"userAvatar.user._id != 'xanon'\" ng-src=\"{{userAvatar.avatarUrl}}\" ng-style=\"{ width: size, height: size }\">\n    <img ng-if=\"userAvatar.user._id == 'xanon'\" src=\"https://d3awvtnmmsvyot.cloudfront.net/api/file/U2RccgsARPyMmzJ5Ao0c/convert?fit=crop&w=70&h=70&cache=true\">\n  </a>\n</div>"
    };
  }).controller('UserNameCtrl', function($scope, Users, BloomSettings) {
    var _this = this;
    $scope.hover = false;
    $scope.$watchCollection('user', function(val) {
      if (val == null) {
        return;
      }
      _this.user = val;
      _this.avatarUrl = _this.user.avatarUrl;
      return _this.profileLink = _this.user.profileLink;
    });
    return this;
  }).directive('userName', function() {
    return {
      restrict: 'E',
      scope: {
        user: '=',
        id: '=',
        hover: '@',
        link: '@',
        size: '@'
      },
      controller: 'UserNameCtrl as userName',
      template: "<div class=\"bloom-username hover-target\">\n  <a ng-href=\"{{userName.profileLink}}\">{{userName.user.name}}</a>\n</div>"
    };
  });
};


},{}],67:[function(require,module,exports){
module.exports = function() {
  require('./helpers')();
  return angular.module('bloom.users', ['bloom.settings', 'bloom.users.helpers']).service('Users', require('./service'));
};


},{"./helpers":66,"./service":68}],68:[function(require,module,exports){
module.exports = function(BloomSettings, $q) {
  var _this = this;
  this.get = _.memoize(function(id) {
    return BloomSettings.getUser(id);
  });
  this.getList = function(users) {
    return $q.all(users.map(function(user) {
      return _this.get(user);
    }));
  };
  return this;
};


},{}],69:[function(require,module,exports){
var _this = this;

module.exports = function() {
  require('./moment')();
  angular.module('ago', []).factory('nowTime', function($timeout) {
    var nowTime, updateTime;
    nowTime = null;
    updateTime = function() {
      return nowTime = Date.now();
    };
    updateTime();
    return function() {
      return nowTime;
    };
  }).filter('ago', function(nowTime) {
    return function(input) {
      if (input == null) {
        return '';
      }
      return moment(input).from(nowTime());
    };
  });
  return moment.lang("en", {
    relativeTime: {
      future: "%s",
      past: "%s",
      s: "just now",
      m: "1m",
      mm: "%dm",
      h: "1h",
      hh: "%dh",
      d: "1d",
      dd: "%dd",
      M: "1mo",
      MM: "%dmo",
      y: "1y",
      yy: "%dy"
    }
  });
};


},{"./moment":70}],70:[function(require,module,exports){
// moment.js
// version : 1.7.2
// author : Tim Wood
// license : MIT
// momentjs.com
module.exports = function() {
  (function(a){function E(a,b,c,d){var e=c.lang();return e[a].call?e[a](c,d):e[a][b]}function F(a,b){return function(c){return K(a.call(this,c),b)}}function G(a){return function(b){var c=a.call(this,b);return c+this.lang().ordinal(c)}}function H(a,b,c){this._d=a,this._isUTC=!!b,this._a=a._a||null,this._lang=c||!1}function I(a){var b=this._data={},c=a.years||a.y||0,d=a.months||a.M||0,e=a.weeks||a.w||0,f=a.days||a.d||0,g=a.hours||a.h||0,h=a.minutes||a.m||0,i=a.seconds||a.s||0,j=a.milliseconds||a.ms||0;this._milliseconds=j+i*1e3+h*6e4+g*36e5,this._days=f+e*7,this._months=d+c*12,b.milliseconds=j%1e3,i+=J(j/1e3),b.seconds=i%60,h+=J(i/60),b.minutes=h%60,g+=J(h/60),b.hours=g%24,f+=J(g/24),f+=e*7,b.days=f%30,d+=J(f/30),b.months=d%12,c+=J(d/12),b.years=c,this._lang=!1}function J(a){return a<0?Math.ceil(a):Math.floor(a)}function K(a,b){var c=a+"";while(c.length<b)c="0"+c;return c}function L(a,b,c){var d=b._milliseconds,e=b._days,f=b._months,g;d&&a._d.setTime(+a+d*c),e&&a.date(a.date()+e*c),f&&(g=a.date(),a.date(1).month(a.month()+f*c).date(Math.min(g,a.daysInMonth())))}function M(a){return Object.prototype.toString.call(a)==="[object Array]"}function N(a,b){var c=Math.min(a.length,b.length),d=Math.abs(a.length-b.length),e=0,f;for(f=0;f<c;f++)~~a[f]!==~~b[f]&&e++;return e+d}function O(a,b,c,d){var e,f,g=[];for(e=0;e<7;e++)g[e]=a[e]=a[e]==null?e===2?1:0:a[e];return a[7]=g[7]=b,a[8]!=null&&(g[8]=a[8]),a[3]+=c||0,a[4]+=d||0,f=new Date(0),b?(f.setUTCFullYear(a[0],a[1],a[2]),f.setUTCHours(a[3],a[4],a[5],a[6])):(f.setFullYear(a[0],a[1],a[2]),f.setHours(a[3],a[4],a[5],a[6])),f._a=g,f}function P(a,c){var d,e,g=[];!c&&h&&(c=require("./lang/"+a));for(d=0;d<i.length;d++)c[i[d]]=c[i[d]]||f.en[i[d]];for(d=0;d<12;d++)e=b([2e3,d]),g[d]=new RegExp("^"+(c.months[d]||c.months(e,""))+"|^"+(c.monthsShort[d]||c.monthsShort(e,"")).replace(".",""),"i");return c.monthsParse=c.monthsParse||g,f[a]=c,c}function Q(a){var c=typeof a=="string"&&a||a&&a._lang||null;return c?f[c]||P(c):b}function R(a){return a.match(/\[.*\]/)?a.replace(/^\[|\]$/g,""):a.replace(/\\/g,"")}function S(a){var b=a.match(k),c,d;for(c=0,d=b.length;c<d;c++)D[b[c]]?b[c]=D[b[c]]:b[c]=R(b[c]);return function(e){var f="";for(c=0;c<d;c++)f+=typeof b[c].call=="function"?b[c].call(e,a):b[c];return f}}function T(a,b){function d(b){return a.lang().longDateFormat[b]||b}var c=5;while(c--&&l.test(b))b=b.replace(l,d);return A[b]||(A[b]=S(b)),A[b](a)}function U(a){switch(a){case"DDDD":return p;case"YYYY":return q;case"S":case"SS":case"SSS":case"DDD":return o;case"MMM":case"MMMM":case"dd":case"ddd":case"dddd":case"a":case"A":return r;case"Z":case"ZZ":return s;case"T":return t;case"MM":case"DD":case"YY":case"HH":case"hh":case"mm":case"ss":case"M":case"D":case"d":case"H":case"h":case"m":case"s":return n;default:return new RegExp(a.replace("\\",""))}}function V(a,b,c,d){var e,f;switch(a){case"M":case"MM":c[1]=b==null?0:~~b-1;break;case"MMM":case"MMMM":for(e=0;e<12;e++)if(Q().monthsParse[e].test(b)){c[1]=e,f=!0;break}f||(c[8]=!1);break;case"D":case"DD":case"DDD":case"DDDD":b!=null&&(c[2]=~~b);break;case"YY":c[0]=~~b+(~~b>70?1900:2e3);break;case"YYYY":c[0]=~~Math.abs(b);break;case"a":case"A":d.isPm=(b+"").toLowerCase()==="pm";break;case"H":case"HH":case"h":case"hh":c[3]=~~b;break;case"m":case"mm":c[4]=~~b;break;case"s":case"ss":c[5]=~~b;break;case"S":case"SS":case"SSS":c[6]=~~(("0."+b)*1e3);break;case"Z":case"ZZ":d.isUTC=!0,e=(b+"").match(x),e&&e[1]&&(d.tzh=~~e[1]),e&&e[2]&&(d.tzm=~~e[2]),e&&e[0]==="+"&&(d.tzh=-d.tzh,d.tzm=-d.tzm)}b==null&&(c[8]=!1)}function W(a,b){var c=[0,0,1,0,0,0,0],d={tzh:0,tzm:0},e=b.match(k),f,g;for(f=0;f<e.length;f++)g=(U(e[f]).exec(a)||[])[0],g&&(a=a.slice(a.indexOf(g)+g.length)),D[e[f]]&&V(e[f],g,c,d);return d.isPm&&c[3]<12&&(c[3]+=12),d.isPm===!1&&c[3]===12&&(c[3]=0),O(c,d.isUTC,d.tzh,d.tzm)}function X(a,b){var c,d=a.match(m)||[],e,f=99,g,h,i;for(g=0;g<b.length;g++)h=W(a,b[g]),e=T(new H(h),b[g]).match(m)||[],i=N(d,e),i<f&&(f=i,c=h);return c}function Y(a){var b="YYYY-MM-DDT",c;if(u.exec(a)){for(c=0;c<4;c++)if(w[c][1].exec(a)){b+=w[c][0];break}return s.exec(a)?W(a,b+" Z"):W(a,b)}return new Date(a)}function Z(a,b,c,d,e){var f=e.relativeTime[a];return typeof f=="function"?f(b||1,!!c,a,d):f.replace(/%d/i,b||1)}function $(a,b,c){var e=d(Math.abs(a)/1e3),f=d(e/60),g=d(f/60),h=d(g/24),i=d(h/365),j=e<45&&["s",e]||f===1&&["m"]||f<45&&["mm",f]||g===1&&["h"]||g<22&&["hh",g]||h===1&&["d"]||h<=25&&["dd",h]||h<=45&&["M"]||h<345&&["MM",d(h/30)]||i===1&&["y"]||["yy",i];return j[2]=b,j[3]=a>0,j[4]=c,Z.apply({},j)}function _(a,c){b.fn[a]=function(a){var b=this._isUTC?"UTC":"";return a!=null?(this._d["set"+b+c](a),this):this._d["get"+b+c]()}}function ab(a){b.duration.fn[a]=function(){return this._data[a]}}function bb(a,c){b.duration.fn["as"+a]=function(){return+this/c}}var b,c="1.7.2",d=Math.round,e,f={},g="en",h=typeof module!="undefined"&&module.exports,i="months|monthsShort|weekdays|weekdaysShort|weekdaysMin|longDateFormat|calendar|relativeTime|ordinal|meridiem".split("|"),j=/^\/?Date\((\-?\d+)/i,k=/(\[[^\[]*\])|(\\)?(Mo|MM?M?M?|Do|DDDo|DD?D?D?|ddd?d?|do?|w[o|w]?|YYYY|YY|a|A|hh?|HH?|mm?|ss?|SS?S?|zz?|ZZ?|.)/g,l=/(\[[^\[]*\])|(\\)?(LT|LL?L?L?)/g,m=/([0-9a-zA-Z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+)/gi,n=/\d\d?/,o=/\d{1,3}/,p=/\d{3}/,q=/\d{1,4}/,r=/[0-9a-z\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]+/i,s=/Z|[\+\-]\d\d:?\d\d/i,t=/T/i,u=/^\s*\d{4}-\d\d-\d\d(T(\d\d(:\d\d(:\d\d(\.\d\d?\d?)?)?)?)?([\+\-]\d\d:?\d\d)?)?/,v="YYYY-MM-DDTHH:mm:ssZ",w=[["HH:mm:ss.S",/T\d\d:\d\d:\d\d\.\d{1,3}/],["HH:mm:ss",/T\d\d:\d\d:\d\d/],["HH:mm",/T\d\d:\d\d/],["HH",/T\d\d/]],x=/([\+\-]|\d\d)/gi,y="Month|Date|Hours|Minutes|Seconds|Milliseconds".split("|"),z={Milliseconds:1,Seconds:1e3,Minutes:6e4,Hours:36e5,Days:864e5,Months:2592e6,Years:31536e6},A={},B="DDD w M D d".split(" "),C="M D H h m s w".split(" "),D={M:function(){return this.month()+1},MMM:function(a){return E("monthsShort",this.month(),this,a)},MMMM:function(a){return E("months",this.month(),this,a)},D:function(){return this.date()},DDD:function(){var a=new Date(this.year(),this.month(),this.date()),b=new Date(this.year(),0,1);return~~((a-b)/864e5+1.5)},d:function(){return this.day()},dd:function(a){return E("weekdaysMin",this.day(),this,a)},ddd:function(a){return E("weekdaysShort",this.day(),this,a)},dddd:function(a){return E("weekdays",this.day(),this,a)},w:function(){var a=new Date(this.year(),this.month(),this.date()-this.day()+5),b=new Date(a.getFullYear(),0,4);return~~((a-b)/864e5/7+1.5)},YY:function(){return K(this.year()%100,2)},YYYY:function(){return K(this.year(),4)},a:function(){return this.lang().meridiem(this.hours(),this.minutes(),!0)},A:function(){return this.lang().meridiem(this.hours(),this.minutes(),!1)},H:function(){return this.hours()},h:function(){return this.hours()%12||12},m:function(){return this.minutes()},s:function(){return this.seconds()},S:function(){return~~(this.milliseconds()/100)},SS:function(){return K(~~(this.milliseconds()/10),2)},SSS:function(){return K(this.milliseconds(),3)},Z:function(){var a=-this.zone(),b="+";return a<0&&(a=-a,b="-"),b+K(~~(a/60),2)+":"+K(~~a%60,2)},ZZ:function(){var a=-this.zone(),b="+";return a<0&&(a=-a,b="-"),b+K(~~(10*a/6),4)}};while(B.length)e=B.pop(),D[e+"o"]=G(D[e]);while(C.length)e=C.pop(),D[e+e]=F(D[e],2);D.DDDD=F(D.DDD,3),b=function(c,d){if(c===null||c==="")return null;var e,f;return b.isMoment(c)?new H(new Date(+c._d),c._isUTC,c._lang):(d?M(d)?e=X(c,d):e=W(c,d):(f=j.exec(c),e=c===a?new Date:f?new Date(+f[1]):c instanceof Date?c:M(c)?O(c):typeof c=="string"?Y(c):new Date(c)),new H(e))},b.utc=function(a,c){return M(a)?new H(O(a,!0),!0):(typeof a=="string"&&!s.exec(a)&&(a+=" +0000",c&&(c+=" Z")),b(a,c).utc())},b.unix=function(a){return b(a*1e3)},b.duration=function(a,c){var d=b.isDuration(a),e=typeof a=="number",f=d?a._data:e?{}:a,g;return e&&(c?f[c]=a:f.milliseconds=a),g=new I(f),d&&(g._lang=a._lang),g},b.humanizeDuration=function(a,c,d){return b.duration(a,c===!0?null:c).humanize(c===!0?!0:d)},b.version=c,b.defaultFormat=v,b.lang=function(a,c){var d;if(!a)return g;(c||!f[a])&&P(a,c);if(f[a]){for(d=0;d<i.length;d++)b[i[d]]=f[a][i[d]];b.monthsParse=f[a].monthsParse,g=a}},b.langData=Q,b.isMoment=function(a){return a instanceof H},b.isDuration=function(a){return a instanceof I},b.lang("en",{months:"January_February_March_April_May_June_July_August_September_October_November_December".split("_"),monthsShort:"Jan_Feb_Mar_Apr_May_Jun_Jul_Aug_Sep_Oct_Nov_Dec".split("_"),weekdays:"Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday".split("_"),weekdaysShort:"Sun_Mon_Tue_Wed_Thu_Fri_Sat".split("_"),weekdaysMin:"Su_Mo_Tu_We_Th_Fr_Sa".split("_"),longDateFormat:{LT:"h:mm A",L:"MM/DD/YYYY",LL:"MMMM D YYYY",LLL:"MMMM D YYYY LT",LLLL:"dddd, MMMM D YYYY LT"},meridiem:function(a,b,c){return a>11?c?"pm":"PM":c?"am":"AM"},calendar:{sameDay:"[Today at] LT",nextDay:"[Tomorrow at] LT",nextWeek:"dddd [at] LT",lastDay:"[Yesterday at] LT",lastWeek:"[last] dddd [at] LT",sameElse:"L"},relativeTime:{future:"in %s",past:"%s ago",s:"a few seconds",m:"a minute",mm:"%d minutes",h:"an hour",hh:"%d hours",d:"a day",dd:"%d days",M:"a month",MM:"%d months",y:"a year",yy:"%d years"},ordinal:function(a){var b=a%10;return~~(a%100/10)===1?"th":b===1?"st":b===2?"nd":b===3?"rd":"th"}}),b.fn=H.prototype={clone:function(){return b(this)},valueOf:function(){return+this._d},unix:function(){return Math.floor(+this._d/1e3)},toString:function(){return this._d.toString()},toDate:function(){return this._d},toArray:function(){var a=this;return[a.year(),a.month(),a.date(),a.hours(),a.minutes(),a.seconds(),a.milliseconds(),!!this._isUTC]},isValid:function(){return this._a?this._a[8]!=null?!!this._a[8]:!N(this._a,(this._a[7]?b.utc(this._a):b(this._a)).toArray()):!isNaN(this._d.getTime())},utc:function(){return this._isUTC=!0,this},local:function(){return this._isUTC=!1,this},format:function(a){return T(this,a?a:b.defaultFormat)},add:function(a,c){var d=c?b.duration(+c,a):b.duration(a);return L(this,d,1),this},subtract:function(a,c){var d=c?b.duration(+c,a):b.duration(a);return L(this,d,-1),this},diff:function(a,c,e){var f=this._isUTC?b(a).utc():b(a).local(),g=(this.zone()-f.zone())*6e4,h=this._d-f._d-g,i=this.year()-f.year(),j=this.month()-f.month(),k=this.date()-f.date(),l;return c==="months"?l=i*12+j+k/30:c==="years"?l=i+(j+k/30)/12:l=c==="seconds"?h/1e3:c==="minutes"?h/6e4:c==="hours"?h/36e5:c==="days"?h/864e5:c==="weeks"?h/6048e5:h,e?l:d(l)},from:function(a,c){return b.duration(this.diff(a)).lang(this._lang).humanize(!c)},fromNow:function(a){return this.from(b(),a)},calendar:function(){var a=this.diff(b().sod(),"days",!0),c=this.lang().calendar,d=c.sameElse,e=a<-6?d:a<-1?c.lastWeek:a<0?c.lastDay:a<1?c.sameDay:a<2?c.nextDay:a<7?c.nextWeek:d;return this.format(typeof e=="function"?e.apply(this):e)},isLeapYear:function(){var a=this.year();return a%4===0&&a%100!==0||a%400===0},isDST:function(){return this.zone()<b([this.year()]).zone()||this.zone()<b([this.year(),5]).zone()},day:function(a){var b=this._isUTC?this._d.getUTCDay():this._d.getDay();return a==null?b:this.add({d:a-b})},startOf:function(a){switch(a.replace(/s$/,"")){case"year":this.month(0);case"month":this.date(1);case"day":this.hours(0);case"hour":this.minutes(0);case"minute":this.seconds(0);case"second":this.milliseconds(0)}return this},endOf:function(a){return this.startOf(a).add(a.replace(/s?$/,"s"),1).subtract("ms",1)},sod:function(){return this.clone().startOf("day")},eod:function(){return this.clone().endOf("day")},zone:function(){return this._isUTC?0:this._d.getTimezoneOffset()},daysInMonth:function(){return b.utc([this.year(),this.month()+1,0]).date()},lang:function(b){return b===a?Q(this):(this._lang=b,this)}};for(e=0;e<y.length;e++)_(y[e].toLowerCase(),y[e]);_("year","FullYear"),b.duration.fn=I.prototype={weeks:function(){return J(this.days()/7)},valueOf:function(){return this._milliseconds+this._days*864e5+this._months*2592e6},humanize:function(a){var b=+this,c=this.lang().relativeTime,d=$(b,!a,this.lang()),e=b<=0?c.past:c.future;return a&&(typeof e=="function"?d=e(d):d=e.replace(/%s/i,d)),d},lang:b.fn.lang};for(e in z)z.hasOwnProperty(e)&&(bb(e,z[e]),ab(e.toLowerCase()));bb("Weeks",6048e5),h&&(module.exports=b),typeof ender=="undefined"&&(this.moment=b),typeof define=="function"&&define.amd&&define("moment",[],function(){return b})}).call(this);
}
},{}],71:[function(require,module,exports){
var _this = this;

module.exports = function() {
  var filters;
  filters = angular.module('bloom.filters', []);
  filters.filter('noHTML', function() {
    return function(html) {
      return $("<div>" + html + "</div>").text();
    };
  });
  return filters.filter("truncate", function() {
    return function(value, wordwise, max, tail) {
      var lastspace;
      if (!value) {
        return "";
      }
      max = parseInt(max, 10);
      if (!max) {
        return value;
      }
      if (value.length <= max) {
        return value;
      }
      value = value.substr(0, max);
      if (wordwise) {
        lastspace = value.lastIndexOf(" ");
        if (lastspace !== -1) {
          value = value.substr(0, lastspace);
        }
      }
      return value + (tail || " …");
    };
  });
};


},{}],72:[function(require,module,exports){
/**
 * angular-strap
 * @version v2.0.0 - 2014-04-07
 * @link http://mgcrea.github.io/angular-strap
 * @author Olivier Louvignes (olivier@mg-crea.com)
 * @license MIT License, http://www.opensource.org/licenses/MIT
 */
(function(window, document, undefined) {
'use strict';
// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/module.js
angular.module('mgcrea.ngStrap', [
  'mgcrea.ngStrap.modal',
  'mgcrea.ngStrap.aside',
  'mgcrea.ngStrap.alert',
  'mgcrea.ngStrap.button',
  'mgcrea.ngStrap.select',
  'mgcrea.ngStrap.datepicker',
  'mgcrea.ngStrap.timepicker',
  'mgcrea.ngStrap.navbar',
  'mgcrea.ngStrap.tooltip',
  'mgcrea.ngStrap.popover',
  'mgcrea.ngStrap.dropdown',
  'mgcrea.ngStrap.typeahead',
  'mgcrea.ngStrap.scrollspy',
  'mgcrea.ngStrap.affix',
  'mgcrea.ngStrap.tab'
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/affix/affix.js
angular.module('mgcrea.ngStrap.affix', [
  'mgcrea.ngStrap.helpers.dimensions',
  'mgcrea.ngStrap.helpers.debounce'
]).provider('$affix', function () {
  var defaults = this.defaults = { offsetTop: 'auto' };
  this.$get = [
    '$window',
    'debounce',
    'dimensions',
    function ($window, debounce, dimensions) {
      var bodyEl = angular.element($window.document.body);
      var windowEl = angular.element($window);
      function AffixFactory(element, config) {
        var $affix = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        var targetEl = options.target;
        // Initial private vars
        var reset = 'affix affix-top affix-bottom', initialAffixTop = 0, initialOffsetTop = 0, offsetTop = 0, offsetBottom = 0, affixed = null, unpin = null;
        var parent = element.parent();
        // Options: custom parent
        if (options.offsetParent) {
          if (options.offsetParent.match(/^\d+$/)) {
            for (var i = 0; i < options.offsetParent * 1 - 1; i++) {
              parent = parent.parent();
            }
          } else {
            parent = angular.element(options.offsetParent);
          }
        }
        $affix.init = function () {
          $affix.$parseOffsets();
          initialOffsetTop = dimensions.offset(element[0]).top + initialAffixTop;
          // Bind events
          targetEl.on('scroll', $affix.checkPosition);
          targetEl.on('click', $affix.checkPositionWithEventLoop);
          windowEl.on('resize', $affix.$debouncedOnResize);
          // Both of these checkPosition() calls are necessary for the case where
          // the user hits refresh after scrolling to the bottom of the page.
          $affix.checkPosition();
          $affix.checkPositionWithEventLoop();
        };
        $affix.destroy = function () {
          // Unbind events
          targetEl.off('scroll', $affix.checkPosition);
          targetEl.off('click', $affix.checkPositionWithEventLoop);
          windowEl.off('resize', $affix.$debouncedOnResize);
        };
        $affix.checkPositionWithEventLoop = function () {
          setTimeout($affix.checkPosition, 1);
        };
        $affix.checkPosition = function () {
          // if (!this.$element.is(':visible')) return
          var scrollTop = getScrollTop();
          var position = dimensions.offset(element[0]);
          var elementHeight = dimensions.height(element[0]);
          // Get required affix class according to position
          var affix = getRequiredAffixClass(unpin, position, elementHeight);
          // Did affix status changed this last check?
          if (affixed === affix)
            return;
          affixed = affix;
          // Add proper affix class
          element.removeClass(reset).addClass('affix' + (affix !== 'middle' ? '-' + affix : ''));
          if (affix === 'top') {
            unpin = null;
            element.css('position', options.offsetParent ? '' : 'relative');
            element.css('top', '');
          } else if (affix === 'bottom') {
            if (options.offsetUnpin) {
              unpin = -(options.offsetUnpin * 1);
            } else {
              // Calculate unpin threshold when affixed to bottom.
              // Hopefully the browser scrolls pixel by pixel.
              unpin = position.top - scrollTop;
            }
            element.css('position', options.offsetParent ? '' : 'relative');
            element.css('top', options.offsetParent ? '' : bodyEl[0].offsetHeight - offsetBottom - elementHeight - initialOffsetTop + 'px');
          } else {
            // affix === 'middle'
            unpin = null;
            element.css('position', 'fixed');
            element.css('top', initialAffixTop + 'px');
          }
        };
        $affix.$onResize = function () {
          $affix.$parseOffsets();
          $affix.checkPosition();
        };
        $affix.$debouncedOnResize = debounce($affix.$onResize, 50);
        $affix.$parseOffsets = function () {
          // Reset position to calculate correct offsetTop
          element.css('position', options.offsetParent ? '' : 'relative');
          if (options.offsetTop) {
            if (options.offsetTop === 'auto') {
              options.offsetTop = '+0';
            }
            if (options.offsetTop.match(/^[-+]\d+$/)) {
              initialAffixTop = -options.offsetTop * 1;
              if (options.offsetParent) {
                offsetTop = dimensions.offset(parent[0]).top + options.offsetTop * 1;
              } else {
                offsetTop = dimensions.offset(element[0]).top - dimensions.css(element[0], 'marginTop', true) + options.offsetTop * 1;
              }
            } else {
              offsetTop = options.offsetTop * 1;
            }
          }
          if (options.offsetBottom) {
            if (options.offsetParent && options.offsetBottom.match(/^[-+]\d+$/)) {
              // add 1 pixel due to rounding problems...
              offsetBottom = getScrollHeight() - (dimensions.offset(parent[0]).top + dimensions.height(parent[0])) + options.offsetBottom * 1 + 1;
            } else {
              offsetBottom = options.offsetBottom * 1;
            }
          }
        };
        // Private methods
        function getRequiredAffixClass(unpin, position, elementHeight) {
          var scrollTop = getScrollTop();
          var scrollHeight = getScrollHeight();
          if (scrollTop <= offsetTop) {
            return 'top';
          } else if (unpin !== null && scrollTop + unpin <= position.top) {
            return 'middle';
          } else if (offsetBottom !== null && position.top + elementHeight + initialAffixTop >= scrollHeight - offsetBottom) {
            return 'bottom';
          } else {
            return 'middle';
          }
        }
        function getScrollTop() {
          return targetEl[0] === $window ? $window.pageYOffset : targetEl[0] === $window;
        }
        function getScrollHeight() {
          return targetEl[0] === $window ? $window.document.body.scrollHeight : targetEl[0].scrollHeight;
        }
        $affix.init();
        return $affix;
      }
      return AffixFactory;
    }
  ];
}).directive('bsAffix', [
  '$affix',
  '$window',
  function ($affix, $window) {
    return {
      restrict: 'EAC',
      require: '^?bsAffixTarget',
      link: function postLink(scope, element, attr, affixTarget) {
        var options = {
            scope: scope,
            offsetTop: 'auto',
            target: affixTarget ? affixTarget.$element : angular.element($window)
          };
        angular.forEach([
          'offsetTop',
          'offsetBottom',
          'offsetParent',
          'offsetUnpin'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        var affix = $affix(element, options);
        scope.$on('$destroy', function () {
          options = null;
          affix = null;
        });
      }
    };
  }
]).directive('bsAffixTarget', function () {
  return {
    controller: [
      '$element',
      function ($element) {
        this.$element = $element;
      }
    ]
  };
});

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/alert/alert.js
// @BUG: following snippet won't compile correctly
// @TODO: submit issue to core
// '<span ng-if="title"><strong ng-bind="title"></strong>&nbsp;</span><span ng-bind-html="content"></span>' +
angular.module('mgcrea.ngStrap.alert', ['mgcrea.ngStrap.modal']).provider('$alert', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'alert',
      placement: null,
      template: 'alert/alert.tpl.html',
      container: false,
      element: null,
      backdrop: false,
      keyboard: true,
      show: true,
      duration: false,
      type: false
    };
  this.$get = [
    '$modal',
    '$timeout',
    function ($modal, $timeout) {
      function AlertFactory(config) {
        var $alert = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        $alert = $modal(options);
        // Support scope as string options [/*title, content, */type]
        if (options.type) {
          $alert.$scope.type = options.type;
        }
        // Support auto-close duration
        var show = $alert.show;
        if (options.duration) {
          $alert.show = function () {
            show();
            $timeout(function () {
              $alert.hide();
            }, options.duration * 1000);
          };
        }
        return $alert;
      }
      return AlertFactory;
    }
  ];
}).directive('bsAlert', [
  '$window',
  '$location',
  '$sce',
  '$alert',
  function ($window, $location, $sce, $alert) {
    var requestAnimationFrame = $window.requestAnimationFrame || $window.setTimeout;
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr, transclusion) {
        // Directive options
        var options = {
            scope: scope,
            element: element,
            show: false
          };
        angular.forEach([
          'template',
          'placement',
          'keyboard',
          'html',
          'container',
          'animation',
          'duration'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Support scope as data-attrs
        angular.forEach([
          'title',
          'content',
          'type'
        ], function (key) {
          attr[key] && attr.$observe(key, function (newValue, oldValue) {
            scope[key] = $sce.trustAsHtml(newValue);
          });
        });
        // Support scope as an object
        attr.bsAlert && scope.$watch(attr.bsAlert, function (newValue, oldValue) {
          if (angular.isObject(newValue)) {
            angular.extend(scope, newValue);
          } else {
            scope.content = newValue;
          }
        }, true);
        // Initialize alert
        var alert = $alert(options);
        // Trigger
        element.on(attr.trigger || 'click', alert.toggle);
        // Garbage collection
        scope.$on('$destroy', function () {
          alert.destroy();
          options = null;
          alert = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/aside/aside.js
angular.module('mgcrea.ngStrap.aside', ['mgcrea.ngStrap.modal']).provider('$aside', function () {
  var defaults = this.defaults = {
      animation: 'am-fade-and-slide-right',
      prefixClass: 'aside',
      placement: 'right',
      template: 'aside/aside.tpl.html',
      contentTemplate: false,
      container: false,
      element: null,
      backdrop: true,
      keyboard: true,
      html: false,
      show: true
    };
  this.$get = [
    '$modal',
    function ($modal) {
      function AsideFactory(config) {
        var $aside = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        $aside = $modal(options);
        return $aside;
      }
      return AsideFactory;
    }
  ];
}).directive('bsAside', [
  '$window',
  '$location',
  '$sce',
  '$aside',
  function ($window, $location, $sce, $aside) {
    var requestAnimationFrame = $window.requestAnimationFrame || $window.setTimeout;
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr, transclusion) {
        // Directive options
        var options = {
            scope: scope,
            element: element,
            show: false
          };
        angular.forEach([
          'template',
          'contentTemplate',
          'placement',
          'backdrop',
          'keyboard',
          'html',
          'container',
          'animation'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Support scope as data-attrs
        angular.forEach([
          'title',
          'content'
        ], function (key) {
          attr[key] && attr.$observe(key, function (newValue, oldValue) {
            scope[key] = $sce.trustAsHtml(newValue);
          });
        });
        // Support scope as an object
        attr.bsAside && scope.$watch(attr.bsAside, function (newValue, oldValue) {
          if (angular.isObject(newValue)) {
            angular.extend(scope, newValue);
          } else {
            scope.content = newValue;
          }
        }, true);
        // Initialize aside
        var aside = $aside(options);
        // Trigger
        element.on(attr.trigger || 'click', aside.toggle);
        // Garbage collection
        scope.$on('$destroy', function () {
          aside.destroy();
          options = null;
          aside = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/button/button.js
angular.module('mgcrea.ngStrap.button', ['ngAnimate']).provider('$button', function () {
  var defaults = this.defaults = {
      activeClass: 'active',
      toggleEvent: 'click'
    };
  this.$get = function () {
    return { defaults: defaults };
  };
}).directive('bsCheckboxGroup', function () {
  return {
    restrict: 'A',
    require: 'ngModel',
    compile: function postLink(element, attr) {
      element.attr('data-toggle', 'buttons');
      element.removeAttr('ng-model');
      var children = element[0].querySelectorAll('input[type="checkbox"]');
      angular.forEach(children, function (child) {
        var childEl = angular.element(child);
        childEl.attr('bs-checkbox', '');
        childEl.attr('ng-model', attr.ngModel + '.' + childEl.attr('value'));
      });
    }
  };
}).directive('bsCheckbox', [
  '$button',
  '$$rAF',
  function ($button, $$rAF) {
    var defaults = $button.defaults;
    var constantValueRegExp = /^(true|false|\d+)$/;
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        var options = defaults;
        // Support label > input[type="checkbox"]
        var isInput = element[0].nodeName === 'INPUT';
        var activeElement = isInput ? element.parent() : element;
        var trueValue = angular.isDefined(attr.trueValue) ? attr.trueValue : true;
        if (constantValueRegExp.test(attr.trueValue)) {
          trueValue = scope.$eval(attr.trueValue);
        }
        var falseValue = angular.isDefined(attr.falseValue) ? attr.falseValue : false;
        if (constantValueRegExp.test(attr.falseValue)) {
          falseValue = scope.$eval(attr.falseValue);
        }
        // Parse exotic values
        var hasExoticValues = typeof trueValue !== 'boolean' || typeof falseValue !== 'boolean';
        if (hasExoticValues) {
          controller.$parsers.push(function (viewValue) {
            // console.warn('$parser', element.attr('ng-model'), 'viewValue', viewValue);
            return viewValue ? trueValue : falseValue;
          });
          // Fix rendering for exotic values
          scope.$watch(attr.ngModel, function (newValue, oldValue) {
            controller.$render();
          });
        }
        // model -> view
        controller.$render = function () {
          // console.warn('$render', element.attr('ng-model'), 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue, 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue);
          var isActive = angular.equals(controller.$modelValue, trueValue);
          $$rAF(function () {
            if (isInput)
              element[0].checked = isActive;
            activeElement.toggleClass(options.activeClass, isActive);
          });
        };
        // view -> model
        element.bind(options.toggleEvent, function () {
          scope.$apply(function () {
            // console.warn('!click', element.attr('ng-model'), 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue, 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue);
            if (!isInput) {
              controller.$setViewValue(!activeElement.hasClass('active'));
            }
            if (!hasExoticValues) {
              controller.$render();
            }
          });
        });
      }
    };
  }
]).directive('bsRadioGroup', function () {
  return {
    restrict: 'A',
    require: 'ngModel',
    compile: function postLink(element, attr) {
      element.attr('data-toggle', 'buttons');
      element.removeAttr('ng-model');
      var children = element[0].querySelectorAll('input[type="radio"]');
      angular.forEach(children, function (child) {
        angular.element(child).attr('bs-radio', '');
        angular.element(child).attr('ng-model', attr.ngModel);
      });
    }
  };
}).directive('bsRadio', [
  '$button',
  '$$rAF',
  function ($button, $$rAF) {
    var defaults = $button.defaults;
    var constantValueRegExp = /^(true|false|\d+)$/;
    return {
      restrict: 'A',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        var options = defaults;
        // Support `label > input[type="radio"]` markup
        var isInput = element[0].nodeName === 'INPUT';
        var activeElement = isInput ? element.parent() : element;
        var value = constantValueRegExp.test(attr.value) ? scope.$eval(attr.value) : attr.value;
        // model -> view
        controller.$render = function () {
          // console.warn('$render', element.attr('value'), 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue, 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue);
          var isActive = angular.equals(controller.$modelValue, value);
          $$rAF(function () {
            if (isInput)
              element[0].checked = isActive;
            activeElement.toggleClass(options.activeClass, isActive);
          });
        };
        // view -> model
        element.bind(options.toggleEvent, function () {
          scope.$apply(function () {
            // console.warn('!click', element.attr('value'), 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue, 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue);
            controller.$setViewValue(value);
            controller.$render();
          });
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/datepicker/datepicker.js
angular.module('mgcrea.ngStrap.datepicker', [
  'mgcrea.ngStrap.helpers.dateParser',
  'mgcrea.ngStrap.tooltip'
]).provider('$datepicker', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'datepicker',
      placement: 'bottom-left',
      template: 'datepicker/datepicker.tpl.html',
      trigger: 'focus',
      container: false,
      keyboard: true,
      html: false,
      delay: 0,
      useNative: false,
      dateType: 'date',
      dateFormat: 'shortDate',
      strictFormat: false,
      autoclose: false,
      minDate: -Infinity,
      maxDate: +Infinity,
      startView: 0,
      minView: 0,
      startWeek: 0
    };
  this.$get = [
    '$window',
    '$document',
    '$rootScope',
    '$sce',
    '$locale',
    'dateFilter',
    'datepickerViews',
    '$tooltip',
    function ($window, $document, $rootScope, $sce, $locale, dateFilter, datepickerViews, $tooltip) {
      var bodyEl = angular.element($window.document.body);
      var isTouch = 'createTouch' in $window.document;
      var isNative = /(ip(a|o)d|iphone|android)/gi.test($window.navigator.userAgent);
      if (!defaults.lang)
        defaults.lang = $locale.id;
      function DatepickerFactory(element, controller, config) {
        var $datepicker = $tooltip(element, angular.extend({}, defaults, config));
        var parentScope = config.scope;
        var options = $datepicker.$options;
        var scope = $datepicker.$scope;
        if (options.startView)
          options.startView -= options.minView;
        // View vars
        var pickerViews = datepickerViews($datepicker);
        $datepicker.$views = pickerViews.views;
        var viewDate = pickerViews.viewDate;
        scope.$mode = options.startView;
        var $picker = $datepicker.$views[scope.$mode];
        // Scope methods
        scope.$select = function (date) {
          $datepicker.select(date);
        };
        scope.$selectPane = function (value) {
          $datepicker.$selectPane(value);
        };
        scope.$toggleMode = function () {
          $datepicker.setMode((scope.$mode + 1) % $datepicker.$views.length);
        };
        // Public methods
        $datepicker.update = function (date) {
          // console.warn('$datepicker.update() newValue=%o', date);
          if (angular.isDate(date) && !isNaN(date.getTime())) {
            $datepicker.$date = date;
            $picker.update.call($picker, date);
          }
          // Build only if pristine
          $datepicker.$build(true);
        };
        $datepicker.select = function (date, keep) {
          // console.warn('$datepicker.select', date, scope.$mode);
          if (!angular.isDate(controller.$dateValue))
            controller.$dateValue = new Date(date);
          controller.$dateValue.setFullYear(date.getFullYear(), date.getMonth(), date.getDate());
          if (!scope.$mode || keep) {
            controller.$setViewValue(controller.$dateValue);
            controller.$render();
            if (options.autoclose && !keep) {
              $datepicker.hide(true);
            }
          } else {
            angular.extend(viewDate, {
              year: date.getFullYear(),
              month: date.getMonth(),
              date: date.getDate()
            });
            $datepicker.setMode(scope.$mode - 1);
            $datepicker.$build();
          }
        };
        $datepicker.setMode = function (mode) {
          // console.warn('$datepicker.setMode', mode);
          scope.$mode = mode;
          $picker = $datepicker.$views[scope.$mode];
          $datepicker.$build();
        };
        // Protected methods
        $datepicker.$build = function (pristine) {
          // console.warn('$datepicker.$build() viewDate=%o', viewDate);
          if (pristine === true && $picker.built)
            return;
          if (pristine === false && !$picker.built)
            return;
          $picker.build.call($picker);
        };
        $datepicker.$updateSelected = function () {
          for (var i = 0, l = scope.rows.length; i < l; i++) {
            angular.forEach(scope.rows[i], updateSelected);
          }
        };
        $datepicker.$isSelected = function (date) {
          return $picker.isSelected(date);
        };
        $datepicker.$selectPane = function (value) {
          var steps = $picker.steps;
          var targetDate = new Date(Date.UTC(viewDate.year + (steps.year || 0) * value, viewDate.month + (steps.month || 0) * value, viewDate.date + (steps.day || 0) * value));
          angular.extend(viewDate, {
            year: targetDate.getUTCFullYear(),
            month: targetDate.getUTCMonth(),
            date: targetDate.getUTCDate()
          });
          $datepicker.$build();
        };
        $datepicker.$onMouseDown = function (evt) {
          // Prevent blur on mousedown on .dropdown-menu
          evt.preventDefault();
          evt.stopPropagation();
          // Emulate click for mobile devices
          if (isTouch) {
            var targetEl = angular.element(evt.target);
            if (targetEl[0].nodeName.toLowerCase() !== 'button') {
              targetEl = targetEl.parent();
            }
            targetEl.triggerHandler('click');
          }
        };
        $datepicker.$onKeyDown = function (evt) {
          if (!/(38|37|39|40|13)/.test(evt.keyCode) || evt.shiftKey || evt.altKey)
            return;
          evt.preventDefault();
          evt.stopPropagation();
          if (evt.keyCode === 13) {
            if (!scope.$mode) {
              return $datepicker.hide(true);
            } else {
              return scope.$apply(function () {
                $datepicker.setMode(scope.$mode - 1);
              });
            }
          }
          // Navigate with keyboard
          $picker.onKeyDown(evt);
          parentScope.$digest();
        };
        // Private
        function updateSelected(el) {
          el.selected = $datepicker.$isSelected(el.date);
        }
        function focusElement() {
          element[0].focus();
        }
        // Overrides
        var _init = $datepicker.init;
        $datepicker.init = function () {
          if (isNative && options.useNative) {
            element.prop('type', 'date');
            element.css('-webkit-appearance', 'textfield');
            return;
          } else if (isTouch) {
            element.prop('type', 'text');
            element.attr('readonly', 'true');
            element.on('click', focusElement);
          }
          _init();
        };
        var _destroy = $datepicker.destroy;
        $datepicker.destroy = function () {
          if (isNative && options.useNative) {
            element.off('click', focusElement);
          }
          _destroy();
        };
        var _show = $datepicker.show;
        $datepicker.show = function () {
          _show();
          setTimeout(function () {
            $datepicker.$element.on(isTouch ? 'touchstart' : 'mousedown', $datepicker.$onMouseDown);
            if (options.keyboard) {
              element.on('keydown', $datepicker.$onKeyDown);
            }
          });
        };
        var _hide = $datepicker.hide;
        $datepicker.hide = function (blur) {
          $datepicker.$element.off(isTouch ? 'touchstart' : 'mousedown', $datepicker.$onMouseDown);
          if (options.keyboard) {
            element.off('keydown', $datepicker.$onKeyDown);
          }
          _hide(blur);
        };
        return $datepicker;
      }
      DatepickerFactory.defaults = defaults;
      return DatepickerFactory;
    }
  ];
}).directive('bsDatepicker', [
  '$window',
  '$parse',
  '$q',
  '$locale',
  'dateFilter',
  '$datepicker',
  '$dateParser',
  '$timeout',
  function ($window, $parse, $q, $locale, dateFilter, $datepicker, $dateParser, $timeout) {
    var defaults = $datepicker.defaults;
    var isNative = /(ip(a|o)d|iphone|android)/gi.test($window.navigator.userAgent);
    var isNumeric = function (n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    };
    return {
      restrict: 'EAC',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = {
            scope: scope,
            controller: controller
          };
        angular.forEach([
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'template',
          'autoclose',
          'dateType',
          'dateFormat',
          'strictFormat',
          'startWeek',
          'useNative',
          'lang',
          'startView',
          'minView'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Initialize datepicker
        if (isNative && options.useNative)
          options.dateFormat = 'yyyy-MM-dd';
        var datepicker = $datepicker(element, controller, options);
        options = datepicker.$options;
        // Observe attributes for changes
        angular.forEach([
          'minDate',
          'maxDate'
        ], function (key) {
          // console.warn('attr.$observe(%s)', key, attr[key]);
          angular.isDefined(attr[key]) && attr.$observe(key, function (newValue) {
            // console.warn('attr.$observe(%s)=%o', key, newValue);
            if (newValue === 'today') {
              var today = new Date();
              datepicker.$options[key] = +new Date(today.getFullYear(), today.getMonth(), today.getDate() + (key === 'maxDate' ? 1 : 0), 0, 0, 0, key === 'minDate' ? 0 : -1);
            } else if (angular.isString(newValue) && newValue.match(/^".+"$/)) {
              // Support {{ dateObj }}
              datepicker.$options[key] = +new Date(newValue.substr(1, newValue.length - 2));
            } else if (isNumeric(newValue)) {
              datepicker.$options[key] = +new Date(parseInt(newValue, 10));
            } else {
              datepicker.$options[key] = +new Date(newValue);
            }
            // Build only if dirty
            !isNaN(datepicker.$options[key]) && datepicker.$build(false);
          });
        });
        // Watch model for changes
        scope.$watch(attr.ngModel, function (newValue, oldValue) {
          datepicker.update(controller.$dateValue);
        }, true);
        var dateParser = $dateParser({
            format: options.dateFormat,
            lang: options.lang,
            strict: options.strictFormat
          });
        // viewValue -> $parsers -> modelValue
        controller.$parsers.unshift(function (viewValue) {
          // console.warn('$parser("%s"): viewValue=%o', element.attr('ng-model'), viewValue);
          // Null values should correctly reset the model value & validity
          if (!viewValue) {
            controller.$setValidity('date', true);
            return;
          }
          var parsedDate = dateParser.parse(viewValue, controller.$dateValue);
          if (!parsedDate || isNaN(parsedDate.getTime())) {
            controller.$setValidity('date', false);
            return;
          } else {
            var isValid = (isNaN(datepicker.$options.minDate) || parsedDate.getTime() >= datepicker.$options.minDate) && (isNaN(datepicker.$options.maxDate) || parsedDate.getTime() <= datepicker.$options.maxDate);
            controller.$setValidity('date', isValid);
            // Only update the model when we have a valid date
            if (isValid)
              controller.$dateValue = parsedDate;
          }
          if (options.dateType === 'string') {
            return dateFilter(viewValue, options.dateFormat);
          } else if (options.dateType === 'number') {
            return controller.$dateValue.getTime();
          } else if (options.dateType === 'iso') {
            return controller.$dateValue.toISOString();
          } else {
            return new Date(controller.$dateValue);
          }
        });
        // modelValue -> $formatters -> viewValue
        controller.$formatters.push(function (modelValue) {
          // console.warn('$formatter("%s"): modelValue=%o (%o)', element.attr('ng-model'), modelValue, typeof modelValue);
          var date;
          if (angular.isUndefined(modelValue) || modelValue === null) {
            date = NaN;
          } else if (angular.isDate(modelValue)) {
            date = modelValue;
          } else if (options.dateType === 'string') {
            date = dateParser.parse(modelValue);
          } else {
            date = new Date(modelValue);
          }
          // Setup default value?
          // if(isNaN(date.getTime())) {
          //   var today = new Date();
          //   date = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 0, 0, 0, 0);
          // }
          controller.$dateValue = date;
          return controller.$dateValue;
        });
        // viewValue -> element
        controller.$render = function () {
          // console.warn('$render("%s"): viewValue=%o', element.attr('ng-model'), controller.$viewValue);
          element.val(!controller.$dateValue || isNaN(controller.$dateValue.getTime()) ? '' : dateFilter(controller.$dateValue, options.dateFormat));
        };
        // Garbage collection
        scope.$on('$destroy', function () {
          datepicker.destroy();
          options = null;
          datepicker = null;
        });
      }
    };
  }
]).provider('datepickerViews', function () {
  var defaults = this.defaults = {
      dayFormat: 'dd',
      daySplit: 7
    };
  // Split array into smaller arrays
  function split(arr, size) {
    var arrays = [];
    while (arr.length > 0) {
      arrays.push(arr.splice(0, size));
    }
    return arrays;
  }
  // Modulus operator
  function mod(n, m) {
    return (n % m + m) % m;
  }
  this.$get = [
    '$locale',
    '$sce',
    'dateFilter',
    function ($locale, $sce, dateFilter) {
      return function (picker) {
        var scope = picker.$scope;
        var options = picker.$options;
        var weekDaysMin = $locale.DATETIME_FORMATS.SHORTDAY;
        var weekDaysLabels = weekDaysMin.slice(options.startWeek).concat(weekDaysMin.slice(0, options.startWeek));
        var weekDaysLabelsHtml = $sce.trustAsHtml('<th class="dow text-center">' + weekDaysLabels.join('</th><th class="dow text-center">') + '</th>');
        var startDate = picker.$date || new Date();
        var viewDate = {
            year: startDate.getFullYear(),
            month: startDate.getMonth(),
            date: startDate.getDate()
          };
        var timezoneOffset = startDate.getTimezoneOffset() * 60000;
        var views = [
            {
              format: 'dd',
              split: 7,
              steps: { month: 1 },
              update: function (date, force) {
                if (!this.built || force || date.getFullYear() !== viewDate.year || date.getMonth() !== viewDate.month) {
                  angular.extend(viewDate, {
                    year: picker.$date.getFullYear(),
                    month: picker.$date.getMonth(),
                    date: picker.$date.getDate()
                  });
                  picker.$build();
                } else if (date.getDate() !== viewDate.date) {
                  viewDate.date = picker.$date.getDate();
                  picker.$updateSelected();
                }
              },
              build: function () {
                var firstDayOfMonth = new Date(viewDate.year, viewDate.month, 1), firstDayOfMonthOffset = firstDayOfMonth.getTimezoneOffset();
                var firstDate = new Date(+firstDayOfMonth - mod(firstDayOfMonth.getDay() - options.startWeek, 6) * 86400000), firstDateOffset = firstDate.getTimezoneOffset();
                // Handle daylight time switch
                if (firstDateOffset !== firstDayOfMonthOffset)
                  firstDate = new Date(+firstDate + (firstDateOffset - firstDayOfMonthOffset) * 60000);
                var days = [], day;
                for (var i = 0; i < 42; i++) {
                  // < 7 * 6
                  day = new Date(firstDate.getFullYear(), firstDate.getMonth(), firstDate.getDate() + i);
                  days.push({
                    date: day,
                    label: dateFilter(day, this.format),
                    selected: picker.$date && this.isSelected(day),
                    muted: day.getMonth() !== viewDate.month,
                    disabled: this.isDisabled(day)
                  });
                }
                scope.title = dateFilter(firstDayOfMonth, 'MMMM yyyy');
                scope.labels = weekDaysLabelsHtml;
                scope.rows = split(days, this.split);
                this.built = true;
              },
              isSelected: function (date) {
                return picker.$date && date.getFullYear() === picker.$date.getFullYear() && date.getMonth() === picker.$date.getMonth() && date.getDate() === picker.$date.getDate();
              },
              isDisabled: function (date) {
                return date.getTime() < options.minDate || date.getTime() > options.maxDate;
              },
              onKeyDown: function (evt) {
                var actualTime = picker.$date.getTime();
                if (evt.keyCode === 37)
                  picker.select(new Date(actualTime - 1 * 86400000), true);
                else if (evt.keyCode === 38)
                  picker.select(new Date(actualTime - 7 * 86400000), true);
                else if (evt.keyCode === 39)
                  picker.select(new Date(actualTime + 1 * 86400000), true);
                else if (evt.keyCode === 40)
                  picker.select(new Date(actualTime + 7 * 86400000), true);
              }
            },
            {
              name: 'month',
              format: 'MMM',
              split: 4,
              steps: { year: 1 },
              update: function (date, force) {
                if (!this.built || date.getFullYear() !== viewDate.year) {
                  angular.extend(viewDate, {
                    year: picker.$date.getFullYear(),
                    month: picker.$date.getMonth(),
                    date: picker.$date.getDate()
                  });
                  picker.$build();
                } else if (date.getMonth() !== viewDate.month) {
                  angular.extend(viewDate, {
                    month: picker.$date.getMonth(),
                    date: picker.$date.getDate()
                  });
                  picker.$updateSelected();
                }
              },
              build: function () {
                var firstMonth = new Date(viewDate.year, 0, 1);
                var months = [], month;
                for (var i = 0; i < 12; i++) {
                  month = new Date(viewDate.year, i, 1);
                  months.push({
                    date: month,
                    label: dateFilter(month, this.format),
                    selected: picker.$isSelected(month),
                    disabled: this.isDisabled(month)
                  });
                }
                scope.title = dateFilter(month, 'yyyy');
                scope.labels = false;
                scope.rows = split(months, this.split);
                this.built = true;
              },
              isSelected: function (date) {
                return picker.$date && date.getFullYear() === picker.$date.getFullYear() && date.getMonth() === picker.$date.getMonth();
              },
              isDisabled: function (date) {
                var lastDate = +new Date(date.getFullYear(), date.getMonth() + 1, 0);
                return lastDate < options.minDate || date.getTime() > options.maxDate;
              },
              onKeyDown: function (evt) {
                var actualMonth = picker.$date.getMonth();
                if (evt.keyCode === 37)
                  picker.select(picker.$date.setMonth(actualMonth - 1), true);
                else if (evt.keyCode === 38)
                  picker.select(picker.$date.setMonth(actualMonth - 4), true);
                else if (evt.keyCode === 39)
                  picker.select(picker.$date.setMonth(actualMonth + 1), true);
                else if (evt.keyCode === 40)
                  picker.select(picker.$date.setMonth(actualMonth + 4), true);
              }
            },
            {
              name: 'year',
              format: 'yyyy',
              split: 4,
              steps: { year: 12 },
              update: function (date, force) {
                if (!this.built || force || parseInt(date.getFullYear() / 20, 10) !== parseInt(viewDate.year / 20, 10)) {
                  angular.extend(viewDate, {
                    year: picker.$date.getFullYear(),
                    month: picker.$date.getMonth(),
                    date: picker.$date.getDate()
                  });
                  picker.$build();
                } else if (date.getFullYear() !== viewDate.year) {
                  angular.extend(viewDate, {
                    year: picker.$date.getFullYear(),
                    month: picker.$date.getMonth(),
                    date: picker.$date.getDate()
                  });
                  picker.$updateSelected();
                }
              },
              build: function () {
                var firstYear = viewDate.year - viewDate.year % (this.split * 3);
                var years = [], year;
                for (var i = 0; i < 12; i++) {
                  year = new Date(firstYear + i, 0, 1);
                  years.push({
                    date: year,
                    label: dateFilter(year, this.format),
                    selected: picker.$isSelected(year),
                    disabled: this.isDisabled(year)
                  });
                }
                scope.title = years[0].label + '-' + years[years.length - 1].label;
                scope.labels = false;
                scope.rows = split(years, this.split);
                this.built = true;
              },
              isSelected: function (date) {
                return picker.$date && date.getFullYear() === picker.$date.getFullYear();
              },
              isDisabled: function (date) {
                var lastDate = +new Date(date.getFullYear() + 1, 0, 0);
                return lastDate < options.minDate || date.getTime() > options.maxDate;
              },
              onKeyDown: function (evt) {
                var actualYear = picker.$date.getFullYear();
                if (evt.keyCode === 37)
                  picker.select(picker.$date.setYear(actualYear - 1), true);
                else if (evt.keyCode === 38)
                  picker.select(picker.$date.setYear(actualYear - 4), true);
                else if (evt.keyCode === 39)
                  picker.select(picker.$date.setYear(actualYear + 1), true);
                else if (evt.keyCode === 40)
                  picker.select(picker.$date.setYear(actualYear + 4), true);
              }
            }
          ];
        return {
          views: options.minView ? Array.prototype.slice.call(views, options.minView) : views,
          viewDate: viewDate
        };
      };
    }
  ];
});

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/dropdown/dropdown.js
angular.module('mgcrea.ngStrap.dropdown', ['mgcrea.ngStrap.tooltip']).provider('$dropdown', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'dropdown',
      placement: 'bottom-left',
      template: 'dropdown/dropdown.tpl.html',
      trigger: 'click',
      container: false,
      keyboard: true,
      html: false,
      delay: 0
    };
  this.$get = [
    '$window',
    '$rootScope',
    '$tooltip',
    function ($window, $rootScope, $tooltip) {
      var bodyEl = angular.element($window.document.body);
      var matchesSelector = Element.prototype.matchesSelector || Element.prototype.webkitMatchesSelector || Element.prototype.mozMatchesSelector || Element.prototype.msMatchesSelector || Element.prototype.oMatchesSelector;
      function DropdownFactory(element, config) {
        var $dropdown = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        var scope = $dropdown.$scope = options.scope && options.scope.$new() || $rootScope.$new();
        $dropdown = $tooltip(element, options);
        // Protected methods
        $dropdown.$onKeyDown = function (evt) {
          if (!/(38|40)/.test(evt.keyCode))
            return;
          evt.preventDefault();
          evt.stopPropagation();
          // Retrieve focused index
          var items = angular.element($dropdown.$element[0].querySelectorAll('li:not(.divider) a'));
          if (!items.length)
            return;
          var index;
          angular.forEach(items, function (el, i) {
            if (matchesSelector && matchesSelector.call(el, ':focus'))
              index = i;
          });
          // Navigate with keyboard
          if (evt.keyCode === 38 && index > 0)
            index--;
          else if (evt.keyCode === 40 && index < items.length - 1)
            index++;
          else if (angular.isUndefined(index))
            index = 0;
          items.eq(index)[0].focus();
        };
        // Overrides
        var show = $dropdown.show;
        $dropdown.show = function () {
          show();
          setTimeout(function () {
            options.keyboard && $dropdown.$element.on('keydown', $dropdown.$onKeyDown);
            bodyEl.on('click', onBodyClick);
          });
        };
        var hide = $dropdown.hide;
        $dropdown.hide = function () {
          options.keyboard && $dropdown.$element.off('keydown', $dropdown.$onKeyDown);
          bodyEl.off('click', onBodyClick);
          hide();
        };
        // Private functions
        function onBodyClick(evt) {
          if (evt.target === element[0])
            return;
          return evt.target !== element[0] && $dropdown.hide();
        }
        return $dropdown;
      }
      return DropdownFactory;
    }
  ];
}).directive('bsDropdown', [
  '$window',
  '$location',
  '$sce',
  '$dropdown',
  function ($window, $location, $sce, $dropdown) {
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr, transclusion) {
        // Directive options
        var options = { scope: scope };
        angular.forEach([
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'template'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Support scope as an object
        attr.bsDropdown && scope.$watch(attr.bsDropdown, function (newValue, oldValue) {
          scope.content = newValue;
        }, true);
        // Initialize dropdown
        var dropdown = $dropdown(element, options);
        // Garbage collection
        scope.$on('$destroy', function () {
          dropdown.destroy();
          options = null;
          dropdown = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/helpers/date-parser.js
angular.module('mgcrea.ngStrap.helpers.dateParser', []).provider('$dateParser', [
  '$localeProvider',
  function ($localeProvider) {
    var proto = Date.prototype;
    function isNumeric(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
    var defaults = this.defaults = {
        format: 'shortDate',
        strict: false
      };
    this.$get = [
      '$locale',
      function ($locale) {
        var DateParserFactory = function (config) {
          var options = angular.extend({}, defaults, config);
          var $dateParser = {};
          var regExpMap = {
              'sss': '[0-9]{3}',
              'ss': '[0-5][0-9]',
              's': options.strict ? '[1-5]?[0-9]' : '[0-9]|[0-5][0-9]',
              'mm': '[0-5][0-9]',
              'm': options.strict ? '[1-5]?[0-9]' : '[0-9]|[0-5][0-9]',
              'HH': '[01][0-9]|2[0-3]',
              'H': options.strict ? '1?[0-9]|2[0-3]' : '[01]?[0-9]|2[0-3]',
              'hh': '[0][1-9]|[1][012]',
              'h': options.strict ? '[1-9]|1[012]' : '0?[1-9]|1[012]',
              'a': 'AM|PM',
              'EEEE': $locale.DATETIME_FORMATS.DAY.join('|'),
              'EEE': $locale.DATETIME_FORMATS.SHORTDAY.join('|'),
              'dd': '0[1-9]|[12][0-9]|3[01]',
              'd': options.strict ? '[1-9]|[1-2][0-9]|3[01]' : '0?[1-9]|[1-2][0-9]|3[01]',
              'MMMM': $locale.DATETIME_FORMATS.MONTH.join('|'),
              'MMM': $locale.DATETIME_FORMATS.SHORTMONTH.join('|'),
              'MM': '0[1-9]|1[012]',
              'M': options.strict ? '[1-9]|1[012]' : '0?[1-9]|1[012]',
              'yyyy': '[1]{1}[0-9]{3}|[2]{1}[0-9]{3}',
              'yy': '[0-9]{2}',
              'y': options.strict ? '-?(0|[1-9][0-9]{0,3})' : '-?0*[0-9]{1,4}'
            };
          var setFnMap = {
              'sss': proto.setMilliseconds,
              'ss': proto.setSeconds,
              's': proto.setSeconds,
              'mm': proto.setMinutes,
              'm': proto.setMinutes,
              'HH': proto.setHours,
              'H': proto.setHours,
              'hh': proto.setHours,
              'h': proto.setHours,
              'dd': proto.setDate,
              'd': proto.setDate,
              'a': function (value) {
                var hours = this.getHours();
                return this.setHours(value.match(/pm/i) ? hours + 12 : hours);
              },
              'MMMM': function (value) {
                return this.setMonth($locale.DATETIME_FORMATS.MONTH.indexOf(value));
              },
              'MMM': function (value) {
                return this.setMonth($locale.DATETIME_FORMATS.SHORTMONTH.indexOf(value));
              },
              'MM': function (value) {
                return this.setMonth(1 * value - 1);
              },
              'M': function (value) {
                return this.setMonth(1 * value - 1);
              },
              'yyyy': proto.setFullYear,
              'yy': function (value) {
                return this.setFullYear(2000 + 1 * value);
              },
              'y': proto.setFullYear
            };
          var regex, setMap;
          $dateParser.init = function () {
            $dateParser.$format = $locale.DATETIME_FORMATS[options.format] || options.format;
            regex = regExpForFormat($dateParser.$format);
            setMap = setMapForFormat($dateParser.$format);
          };
          $dateParser.isValid = function (date) {
            if (angular.isDate(date))
              return !isNaN(date.getTime());
            return regex.test(date);
          };
          $dateParser.parse = function (value, baseDate) {
            if (angular.isDate(value))
              return value;
            var matches = regex.exec(value);
            if (!matches)
              return false;
            var date = baseDate || new Date(0);
            for (var i = 0; i < matches.length - 1; i++) {
              setMap[i] && setMap[i].call(date, matches[i + 1]);
            }
            return date;
          };
          // Private functions
          function setMapForFormat(format) {
            var keys = Object.keys(setFnMap), i;
            var map = [], sortedMap = [];
            // Map to setFn
            var clonedFormat = format;
            for (i = 0; i < keys.length; i++) {
              if (format.split(keys[i]).length > 1) {
                var index = clonedFormat.search(keys[i]);
                format = format.split(keys[i]).join('');
                if (setFnMap[keys[i]])
                  map[index] = setFnMap[keys[i]];
              }
            }
            // Sort result map
            angular.forEach(map, function (v) {
              sortedMap.push(v);
            });
            return sortedMap;
          }
          function escapeReservedSymbols(text) {
            return text.replace(/\//g, '[\\/]').replace('/-/g', '[-]').replace(/\./g, '[.]').replace(/\\s/g, '[\\s]');
          }
          function regExpForFormat(format) {
            var keys = Object.keys(regExpMap), i;
            var re = format;
            // Abstract replaces to avoid collisions
            for (i = 0; i < keys.length; i++) {
              re = re.split(keys[i]).join('${' + i + '}');
            }
            // Replace abstracted values
            for (i = 0; i < keys.length; i++) {
              re = re.split('${' + i + '}').join('(' + regExpMap[keys[i]] + ')');
            }
            format = escapeReservedSymbols(format);
            return new RegExp('^' + re + '$', ['i']);
          }
          $dateParser.init();
          return $dateParser;
        };
        return DateParserFactory;
      }
    ];
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/helpers/debounce.js
angular.module('mgcrea.ngStrap.helpers.debounce', []).constant('debounce', function (func, wait, immediate) {
  var timeout, args, context, timestamp, result;
  return function () {
    context = this;
    args = arguments;
    timestamp = new Date();
    var later = function () {
      var last = new Date() - timestamp;
      if (last < wait) {
        timeout = setTimeout(later, wait - last);
      } else {
        timeout = null;
        if (!immediate)
          result = func.apply(context, args);
      }
    };
    var callNow = immediate && !timeout;
    if (!timeout) {
      timeout = setTimeout(later, wait);
    }
    if (callNow)
      result = func.apply(context, args);
    return result;
  };
}).constant('throttle', function (func, wait, options) {
  var context, args, result;
  var timeout = null;
  var previous = 0;
  options || (options = {});
  var later = function () {
    previous = options.leading === false ? 0 : new Date();
    timeout = null;
    result = func.apply(context, args);
  };
  return function () {
    var now = new Date();
    if (!previous && options.leading === false)
      previous = now;
    var remaining = wait - (now - previous);
    context = this;
    args = arguments;
    if (remaining <= 0) {
      clearTimeout(timeout);
      timeout = null;
      previous = now;
      result = func.apply(context, args);
    } else if (!timeout && options.trailing !== false) {
      timeout = setTimeout(later, remaining);
    }
    return result;
  };
});

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/helpers/dimensions.js
angular.module('mgcrea.ngStrap.helpers.dimensions', []).factory('dimensions', [
  '$document',
  '$window',
  function ($document, $window) {
    var jqLite = angular.element;
    var fn = {};
    /**
     * Test the element nodeName
     * @param element
     * @param name
     */
    var nodeName = fn.nodeName = function (element, name) {
        return element.nodeName && element.nodeName.toLowerCase() === name.toLowerCase();
      };
    /**
     * Returns the element computed style
     * @param element
     * @param prop
     * @param extra
     */
    fn.css = function (element, prop, extra) {
      var value;
      if (element.currentStyle) {
        //IE
        value = element.currentStyle[prop];
      } else if (window.getComputedStyle) {
        value = window.getComputedStyle(element)[prop];
      } else {
        value = element.style[prop];
      }
      return extra === true ? parseFloat(value) || 0 : value;
    };
    /**
     * Provides read-only equivalent of jQuery's offset function:
     * @required-by bootstrap-tooltip, bootstrap-affix
     * @url http://api.jquery.com/offset/
     * @param element
     */
    fn.offset = function (element) {
      var boxRect = element.getBoundingClientRect();
      var docElement = element.ownerDocument;
      return {
        width: element.offsetWidth,
        height: element.offsetHeight,
        top: boxRect.top + (window.pageYOffset || docElement.documentElement.scrollTop) - (docElement.documentElement.clientTop || 0),
        left: boxRect.left + (window.pageXOffset || docElement.documentElement.scrollLeft) - (docElement.documentElement.clientLeft || 0)
      };
    };
    /**
     * Provides read-only equivalent of jQuery's position function
     * @required-by bootstrap-tooltip, bootstrap-affix
     * @url http://api.jquery.com/offset/
     * @param element
     */
    fn.position = function (element) {
      var offsetParentRect = {
          top: 0,
          left: 0
        }, offsetParentElement, offset;
      // Fixed elements are offset from window (parentOffset = {top:0, left: 0}, because it is it's only offset parent
      if (fn.css(element, 'position') === 'fixed') {
        // We assume that getBoundingClientRect is available when computed position is fixed
        offset = element.getBoundingClientRect();
      } else {
        // Get *real* offsetParentElement
        offsetParentElement = offsetParent(element);
        offset = fn.offset(element);
        // Get correct offsets
        offset = fn.offset(element);
        if (!nodeName(offsetParentElement, 'html')) {
          offsetParentRect = fn.offset(offsetParentElement);
        }
        // Add offsetParent borders
        offsetParentRect.top += fn.css(offsetParentElement, 'borderTopWidth', true);
        offsetParentRect.left += fn.css(offsetParentElement, 'borderLeftWidth', true);
      }
      // Subtract parent offsets and element margins
      return {
        width: element.offsetWidth,
        height: element.offsetHeight,
        top: offset.top - offsetParentRect.top - fn.css(element, 'marginTop', true),
        left: offset.left - offsetParentRect.left - fn.css(element, 'marginLeft', true)
      };
    };
    /**
     * Returns the closest, non-statically positioned offsetParent of a given element
     * @required-by fn.position
     * @param element
     */
    var offsetParent = function offsetParentElement(element) {
      var docElement = element.ownerDocument;
      var offsetParent = element.offsetParent || docElement;
      if (nodeName(offsetParent, '#document'))
        return docElement.documentElement;
      while (offsetParent && !nodeName(offsetParent, 'html') && fn.css(offsetParent, 'position') === 'static') {
        offsetParent = offsetParent.offsetParent;
      }
      return offsetParent || docElement.documentElement;
    };
    /**
     * Provides equivalent of jQuery's height function
     * @required-by bootstrap-affix
     * @url http://api.jquery.com/height/
     * @param element
     * @param outer
     */
    fn.height = function (element, outer) {
      var value = element.offsetHeight;
      if (outer) {
        value += fn.css(element, 'marginTop', true) + fn.css(element, 'marginBottom', true);
      } else {
        value -= fn.css(element, 'paddingTop', true) + fn.css(element, 'paddingBottom', true) + fn.css(element, 'borderTopWidth', true) + fn.css(element, 'borderBottomWidth', true);
      }
      return value;
    };
    /**
     * Provides equivalent of jQuery's height function
     * @required-by bootstrap-affix
     * @url http://api.jquery.com/width/
     * @param element
     * @param outer
     */
    fn.width = function (element, outer) {
      var value = element.offsetWidth;
      if (outer) {
        value += fn.css(element, 'marginLeft', true) + fn.css(element, 'marginRight', true);
      } else {
        value -= fn.css(element, 'paddingLeft', true) + fn.css(element, 'paddingRight', true) + fn.css(element, 'borderLeftWidth', true) + fn.css(element, 'borderRightWidth', true);
      }
      return value;
    };
    return fn;
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/helpers/parse-options.js
angular.module('mgcrea.ngStrap.helpers.parseOptions', []).provider('$parseOptions', function () {
  var defaults = this.defaults = { regexp: /^\s*(.*?)(?:\s+as\s+(.*?))?(?:\s+group\s+by\s+(.*))?\s+for\s+(?:([\$\w][\$\w]*)|(?:\(\s*([\$\w][\$\w]*)\s*,\s*([\$\w][\$\w]*)\s*\)))\s+in\s+(.*?)(?:\s+track\s+by\s+(.*?))?$/ };
  this.$get = [
    '$parse',
    '$q',
    function ($parse, $q) {
      function ParseOptionsFactory(attr, config) {
        var $parseOptions = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        $parseOptions.$values = [];
        // Private vars
        var match, displayFn, valueName, keyName, groupByFn, valueFn, valuesFn;
        $parseOptions.init = function () {
          $parseOptions.$match = match = attr.match(options.regexp);
          displayFn = $parse(match[2] || match[1]), valueName = match[4] || match[6], keyName = match[5], groupByFn = $parse(match[3] || ''), valueFn = $parse(match[2] ? match[1] : valueName), valuesFn = $parse(match[7]);
        };
        $parseOptions.valuesFn = function (scope, controller) {
          return $q.when(valuesFn(scope, controller)).then(function (values) {
            $parseOptions.$values = values ? parseValues(values) : {};
            return $parseOptions.$values;
          });
        };
        // Private functions
        function parseValues(values) {
          return values.map(function (match, index) {
            var locals = {}, label, value;
            locals[valueName] = match;
            label = displayFn(locals);
            value = valueFn(locals) || index;
            return {
              label: label,
              value: value
            };
          });
        }
        $parseOptions.init();
        return $parseOptions;
      }
      return ParseOptionsFactory;
    }
  ];
});

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/helpers/raf.js
angular.version.minor < 3 && angular.version.dot < 14 && angular.module('ng').factory('$$rAF', [
  '$window',
  '$timeout',
  function ($window, $timeout) {
    var requestAnimationFrame = $window.requestAnimationFrame || $window.webkitRequestAnimationFrame || $window.mozRequestAnimationFrame;
    var cancelAnimationFrame = $window.cancelAnimationFrame || $window.webkitCancelAnimationFrame || $window.mozCancelAnimationFrame || $window.webkitCancelRequestAnimationFrame;
    var rafSupported = !!requestAnimationFrame;
    var raf = rafSupported ? function (fn) {
        var id = requestAnimationFrame(fn);
        return function () {
          cancelAnimationFrame(id);
        };
      } : function (fn) {
        var timer = $timeout(fn, 16.66, false);
        // 1000 / 60 = 16.666
        return function () {
          $timeout.cancel(timer);
        };
      };
    raf.supported = rafSupported;
    return raf;
  }
]);  // .factory('$$animateReflow', function($$rAF, $document) {
     //   var bodyEl = $document[0].body;
     //   return function(fn) {
     //     //the returned function acts as the cancellation function
     //     return $$rAF(function() {
     //       //the line below will force the browser to perform a repaint
     //       //so that all the animated elements within the animation frame
     //       //will be properly updated and drawn on screen. This is
     //       //required to perform multi-class CSS based animations with
     //       //Firefox. DO NOT REMOVE THIS LINE.
     //       var a = bodyEl.offsetWidth + 1;
     //       fn();
     //     });
     //   };
     // });

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/modal/modal.js
angular.module('mgcrea.ngStrap.modal', ['mgcrea.ngStrap.helpers.dimensions']).provider('$modal', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      backdropAnimation: 'am-fade',
      prefixClass: 'modal',
      prefixEvent: 'modal',
      placement: 'top',
      template: 'modal/modal.tpl.html',
      contentTemplate: false,
      container: false,
      element: null,
      backdrop: true,
      keyboard: true,
      html: false,
      show: true
    };
  this.$get = [
    '$window',
    '$rootScope',
    '$compile',
    '$q',
    '$templateCache',
    '$http',
    '$animate',
    '$timeout',
    '$sce',
    'dimensions',
    function ($window, $rootScope, $compile, $q, $templateCache, $http, $animate, $timeout, $sce, dimensions) {
      var forEach = angular.forEach;
      var trim = String.prototype.trim;
      var requestAnimationFrame = $window.requestAnimationFrame || $window.setTimeout;
      var bodyElement = angular.element($window.document.body);
      var htmlReplaceRegExp = /ng-bind="/gi;
      function ModalFactory(config) {
        var $modal = {};
        // Common vars
        var options = $modal.$options = angular.extend({}, defaults, config);
        $modal.$promise = fetchTemplate(options.template);
        var scope = $modal.$scope = options.scope && options.scope.$new() || $rootScope.$new();
        if (!options.element && !options.container) {
          options.container = 'body';
        }
        // Support scope as string options
        forEach([
          'title',
          'content'
        ], function (key) {
          if (options[key])
            scope[key] = $sce.trustAsHtml(options[key]);
        });
        // Provide scope helpers
        scope.$hide = function () {
          scope.$$postDigest(function () {
            $modal.hide();
          });
        };
        scope.$show = function () {
          scope.$$postDigest(function () {
            $modal.show();
          });
        };
        scope.$toggle = function () {
          scope.$$postDigest(function () {
            $modal.toggle();
          });
        };
        // Support contentTemplate option
        if (options.contentTemplate) {
          $modal.$promise = $modal.$promise.then(function (template) {
            var templateEl = angular.element(template);
            return fetchTemplate(options.contentTemplate).then(function (contentTemplate) {
              var contentEl = findElement('[ng-bind="content"]', templateEl[0]).removeAttr('ng-bind').html(contentTemplate);
              // Drop the default footer as you probably don't want it if you use a custom contentTemplate
              if (!config.template)
                contentEl.next().remove();
              return templateEl[0].outerHTML;
            });
          });
        }
        // Fetch, compile then initialize modal
        var modalLinker, modalElement;
        var backdropElement = angular.element('<div class="' + options.prefixClass + '-backdrop"/>');
        $modal.$promise.then(function (template) {
          if (angular.isObject(template))
            template = template.data;
          if (options.html)
            template = template.replace(htmlReplaceRegExp, 'ng-bind-html="');
          template = trim.apply(template);
          modalLinker = $compile(template);
          $modal.init();
        });
        $modal.init = function () {
          // Options: show
          if (options.show) {
            scope.$$postDigest(function () {
              $modal.show();
            });
          }
        };
        $modal.destroy = function () {
          // Remove element
          if (modalElement) {
            modalElement.remove();
            modalElement = null;
          }
          if (backdropElement) {
            backdropElement.remove();
            backdropElement = null;
          }
          // Destroy scope
          scope.$destroy();
        };
        $modal.show = function () {
          scope.$emit(options.prefixEvent + '.show.before', $modal);
          var parent = options.container ? findElement(options.container) : null;
          var after = options.container ? null : options.element;
          // Fetch a cloned element linked from template
          modalElement = $modal.$element = modalLinker(scope, function (clonedElement, scope) {
          });
          // Set the initial positioning.
          modalElement.css({ display: 'block' }).addClass(options.placement);
          // Options: animation
          if (options.animation) {
            if (options.backdrop) {
              backdropElement.addClass(options.backdropAnimation);
            }
            modalElement.addClass(options.animation);
          }
          if (options.backdrop) {
            $animate.enter(backdropElement, bodyElement, null, function () {
            });
          }
          $animate.enter(modalElement, parent, after, function () {
            scope.$emit(options.prefixEvent + '.show', $modal);
          });
          scope.$isShown = true;
          scope.$$phase || scope.$root.$$phase || scope.$digest();
          // Focus once the enter-animation has started
          // Weird PhantomJS bug hack
          var el = modalElement[0];
          requestAnimationFrame(function () {
            el.focus();
          });
          bodyElement.addClass(options.prefixClass + '-open');
          if (options.animation) {
            bodyElement.addClass(options.prefixClass + '-with-' + options.animation);
          }
          // Bind events
          if (options.backdrop) {
            modalElement.on('click', hideOnBackdropClick);
            backdropElement.on('click', hideOnBackdropClick);
          }
          if (options.keyboard) {
            modalElement.on('keyup', $modal.$onKeyUp);
          }
        };
        $modal.hide = function () {
          scope.$emit(options.prefixEvent + '.hide.before', $modal);
          $animate.leave(modalElement, function () {
            scope.$emit(options.prefixEvent + '.hide', $modal);
            bodyElement.removeClass(options.prefixClass + '-open');
            if (options.animation) {
              bodyElement.addClass(options.prefixClass + '-with-' + options.animation);
            }
          });
          if (options.backdrop) {
            $animate.leave(backdropElement, function () {
            });
          }
          scope.$isShown = false;
          scope.$$phase || scope.$root.$$phase || scope.$digest();
          // Unbind events
          if (options.backdrop) {
            modalElement.off('click', hideOnBackdropClick);
            backdropElement.off('click', hideOnBackdropClick);
          }
          if (options.keyboard) {
            modalElement.off('keyup', $modal.$onKeyUp);
          }
        };
        $modal.toggle = function () {
          scope.$isShown ? $modal.hide() : $modal.show();
        };
        $modal.focus = function () {
          modalElement[0].focus();
        };
        // Protected methods
        $modal.$onKeyUp = function (evt) {
          evt.which === 27 && $modal.hide();
        };
        // Private methods
        function hideOnBackdropClick(evt) {
          if (evt.target !== evt.currentTarget)
            return;
          options.backdrop === 'static' ? $modal.focus() : $modal.hide();
        }
        return $modal;
      }
      // Helper functions
      function findElement(query, element) {
        return angular.element((element || document).querySelectorAll(query));
      }
      function fetchTemplate(template) {
        return $q.when($templateCache.get(template) || $http.get(template)).then(function (res) {
          if (angular.isObject(res)) {
            $templateCache.put(template, res.data);
            return res.data;
          }
          return res;
        });
      }
      return ModalFactory;
    }
  ];
}).directive('bsModal', [
  '$window',
  '$location',
  '$sce',
  '$modal',
  function ($window, $location, $sce, $modal) {
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr, transclusion) {
        // Directive options
        var options = {
            scope: scope,
            element: element,
            show: false
          };
        angular.forEach([
          'template',
          'contentTemplate',
          'placement',
          'backdrop',
          'keyboard',
          'html',
          'container',
          'animation'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Support scope as data-attrs
        angular.forEach([
          'title',
          'content'
        ], function (key) {
          attr[key] && attr.$observe(key, function (newValue, oldValue) {
            scope[key] = $sce.trustAsHtml(newValue);
          });
        });
        // Support scope as an object
        attr.bsModal && scope.$watch(attr.bsModal, function (newValue, oldValue) {
          if (angular.isObject(newValue)) {
            angular.extend(scope, newValue);
          } else {
            scope.content = newValue;
          }
        }, true);
        // Initialize modal
        var modal = $modal(options);
        // Trigger
        element.on(attr.trigger || 'click', modal.toggle);
        // Garbage collection
        scope.$on('$destroy', function () {
          modal.destroy();
          options = null;
          modal = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/navbar/navbar.js
angular.module('mgcrea.ngStrap.navbar', []).provider('$navbar', function () {
  var defaults = this.defaults = {
      activeClass: 'active',
      routeAttr: 'data-match-route',
      strict: false
    };
  this.$get = function () {
    return { defaults: defaults };
  };
}).directive('bsNavbar', [
  '$window',
  '$location',
  '$navbar',
  function ($window, $location, $navbar) {
    var defaults = $navbar.defaults;
    return {
      restrict: 'A',
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = angular.copy(defaults);
        angular.forEach(Object.keys(defaults), function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Watch for the $location
        scope.$watch(function () {
          return $location.path();
        }, function (newValue, oldValue) {
          var liElements = element[0].querySelectorAll('li[' + options.routeAttr + ']');
          angular.forEach(liElements, function (li) {
            var liElement = angular.element(li);
            var pattern = liElement.attr(options.routeAttr).replace('/', '\\/');
            if (options.strict) {
              pattern = '^' + pattern + '$';
            }
            var regexp = new RegExp(pattern, ['i']);
            if (regexp.test(newValue)) {
              liElement.addClass(options.activeClass);
            } else {
              liElement.removeClass(options.activeClass);
            }
          });
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/popover/popover.js
angular.module('mgcrea.ngStrap.popover', ['mgcrea.ngStrap.tooltip']).provider('$popover', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      placement: 'right',
      template: 'popover/popover.tpl.html',
      contentTemplate: false,
      trigger: 'click',
      keyboard: true,
      html: false,
      title: '',
      content: '',
      delay: 0,
      container: false
    };
  this.$get = [
    '$tooltip',
    function ($tooltip) {
      function PopoverFactory(element, config) {
        // Common vars
        var options = angular.extend({}, defaults, config);
        var $popover = $tooltip(element, options);
        // Support scope as string options [/*title, */content]
        if (options.content) {
          $popover.$scope.content = options.content;
        }
        return $popover;
      }
      return PopoverFactory;
    }
  ];
}).directive('bsPopover', [
  '$window',
  '$location',
  '$sce',
  '$popover',
  function ($window, $location, $sce, $popover) {
    var requestAnimationFrame = $window.requestAnimationFrame || $window.setTimeout;
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr) {
        // Directive options
        var options = { scope: scope };
        angular.forEach([
          'template',
          'contentTemplate',
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Support scope as data-attrs
        angular.forEach([
          'title',
          'content'
        ], function (key) {
          attr[key] && attr.$observe(key, function (newValue, oldValue) {
            scope[key] = $sce.trustAsHtml(newValue);
            angular.isDefined(oldValue) && requestAnimationFrame(function () {
              popover && popover.$applyPlacement();
            });
          });
        });
        // Support scope as an object
        attr.bsPopover && scope.$watch(attr.bsPopover, function (newValue, oldValue) {
          if (angular.isObject(newValue)) {
            angular.extend(scope, newValue);
          } else {
            scope.content = newValue;
          }
          angular.isDefined(oldValue) && requestAnimationFrame(function () {
            popover && popover.$applyPlacement();
          });
        }, true);
        // Initialize popover
        var popover = $popover(element, options);
        // Garbage collection
        scope.$on('$destroy', function () {
          popover.destroy();
          options = null;
          popover = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/select/select.js
angular.module('mgcrea.ngStrap.select', [
  'mgcrea.ngStrap.tooltip',
  'mgcrea.ngStrap.helpers.parseOptions'
]).provider('$select', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'select',
      placement: 'bottom-left',
      template: 'select/select.tpl.html',
      trigger: 'focus',
      container: false,
      keyboard: true,
      html: false,
      delay: 0,
      multiple: false,
      sort: true,
      caretHtml: '&nbsp;<span class="caret"></span>',
      placeholder: 'Choose among the following...',
      maxLength: 3,
      maxLengthHtml: 'selected'
    };
  this.$get = [
    '$window',
    '$document',
    '$rootScope',
    '$tooltip',
    function ($window, $document, $rootScope, $tooltip) {
      var bodyEl = angular.element($window.document.body);
      var isTouch = 'createTouch' in $window.document;
      function SelectFactory(element, controller, config) {
        var $select = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        $select = $tooltip(element, options);
        var parentScope = config.scope;
        var scope = $select.$scope;
        scope.$matches = [];
        scope.$activeIndex = 0;
        scope.$isMultiple = options.multiple;
        scope.$activate = function (index) {
          scope.$$postDigest(function () {
            $select.activate(index);
          });
        };
        scope.$select = function (index, evt) {
          scope.$$postDigest(function () {
            $select.select(index);
          });
        };
        scope.$isVisible = function () {
          return $select.$isVisible();
        };
        scope.$isActive = function (index) {
          return $select.$isActive(index);
        };
        // Public methods
        $select.update = function (matches) {
          scope.$matches = matches;
          $select.$updateActiveIndex();
        };
        $select.activate = function (index) {
          if (options.multiple) {
            scope.$activeIndex.sort();
            $select.$isActive(index) ? scope.$activeIndex.splice(scope.$activeIndex.indexOf(index), 1) : scope.$activeIndex.push(index);
            if (options.sort)
              scope.$activeIndex.sort();
          } else {
            scope.$activeIndex = index;
          }
          return scope.$activeIndex;
        };
        $select.select = function (index) {
          var value = scope.$matches[index].value;
          $select.activate(index);
          if (options.multiple) {
            controller.$setViewValue(scope.$activeIndex.map(function (index) {
              return scope.$matches[index].value;
            }));
          } else {
            controller.$setViewValue(value);
          }
          controller.$render();
          if (parentScope)
            parentScope.$digest();
          // Hide if single select
          if (!options.multiple) {
            $select.hide();
          }
          // Emit event
          scope.$emit('$select.select', value, index);
        };
        // Protected methods
        $select.$updateActiveIndex = function () {
          if (controller.$modelValue && scope.$matches.length) {
            if (options.multiple && angular.isArray(controller.$modelValue)) {
              scope.$activeIndex = controller.$modelValue.map(function (value) {
                return $select.$getIndex(value);
              });
            } else {
              scope.$activeIndex = $select.$getIndex(controller.$modelValue);
            }
          } else if (scope.$activeIndex >= scope.$matches.length) {
            scope.$activeIndex = options.multiple ? [] : 0;
          }
        };
        $select.$isVisible = function () {
          if (!options.minLength || !controller) {
            return scope.$matches.length;
          }
          // minLength support
          return scope.$matches.length && controller.$viewValue.length >= options.minLength;
        };
        $select.$isActive = function (index) {
          if (options.multiple) {
            return scope.$activeIndex.indexOf(index) !== -1;
          } else {
            return scope.$activeIndex === index;
          }
        };
        $select.$getIndex = function (value) {
          var l = scope.$matches.length, i = l;
          if (!l)
            return;
          for (i = l; i--;) {
            if (scope.$matches[i].value === value)
              break;
          }
          if (i < 0)
            return;
          return i;
        };
        $select.$onMouseDown = function (evt) {
          // Prevent blur on mousedown on .dropdown-menu
          evt.preventDefault();
          evt.stopPropagation();
          // Emulate click for mobile devices
          if (isTouch) {
            var targetEl = angular.element(evt.target);
            targetEl.triggerHandler('click');
          }
        };
        $select.$onKeyDown = function (evt) {
          if (!/(9|13|38|40)/.test(evt.keyCode))
            return;
          evt.preventDefault();
          evt.stopPropagation();
          // Select with enter
          if (evt.keyCode === 13 || evt.keyCode === 9) {
            return $select.select(scope.$activeIndex);
          }
          // Navigate with keyboard
          if (evt.keyCode === 38 && scope.$activeIndex > 0)
            scope.$activeIndex--;
          else if (evt.keyCode === 40 && scope.$activeIndex < scope.$matches.length - 1)
            scope.$activeIndex++;
          else if (angular.isUndefined(scope.$activeIndex))
            scope.$activeIndex = 0;
          scope.$digest();
        };
        // Overrides
        var _show = $select.show;
        $select.show = function () {
          _show();
          if (options.multiple) {
            $select.$element.addClass('select-multiple');
          }
          setTimeout(function () {
            $select.$element.on(isTouch ? 'touchstart' : 'mousedown', $select.$onMouseDown);
            if (options.keyboard) {
              element.on('keydown', $select.$onKeyDown);
            }
          });
        };
        var _hide = $select.hide;
        $select.hide = function () {
          $select.$element.off(isTouch ? 'touchstart' : 'mousedown', $select.$onMouseDown);
          if (options.keyboard) {
            element.off('keydown', $select.$onKeyDown);
          }
          _hide();
        };
        return $select;
      }
      SelectFactory.defaults = defaults;
      return SelectFactory;
    }
  ];
}).directive('bsSelect', [
  '$window',
  '$parse',
  '$q',
  '$select',
  '$parseOptions',
  function ($window, $parse, $q, $select, $parseOptions) {
    var defaults = $select.defaults;
    return {
      restrict: 'EAC',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = { scope: scope };
        angular.forEach([
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'template',
          'placeholder',
          'multiple',
          'maxLength',
          'maxLengthHtml'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Add support for select markup
        if (element[0].nodeName.toLowerCase() === 'select') {
          var inputEl = element;
          inputEl.css('display', 'none');
          element = angular.element('<button type="button" class="btn btn-default"></button>');
          inputEl.after(element);
        }
        // Build proper ngOptions
        var parsedOptions = $parseOptions(attr.ngOptions);
        // Initialize select
        var select = $select(element, controller, options);
        // Watch ngOptions values before filtering for changes
        var watchedOptions = parsedOptions.$match[7].replace(/\|.+/, '').trim();
        scope.$watch(watchedOptions, function (newValue, oldValue) {
          // console.warn('scope.$watch(%s)', watchedOptions, newValue, oldValue);
          parsedOptions.valuesFn(scope, controller).then(function (values) {
            select.update(values);
            controller.$render();
          });
        }, true);
        // Watch model for changes
        scope.$watch(attr.ngModel, function (newValue, oldValue) {
          // console.warn('scope.$watch(%s)', attr.ngModel, newValue, oldValue);
          select.$updateActiveIndex();
        }, true);
        // Model rendering in view
        controller.$render = function () {
          // console.warn('$render', element.attr('ng-model'), 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue, 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue);
          var selected, index;
          if (options.multiple && angular.isArray(controller.$modelValue)) {
            selected = controller.$modelValue.map(function (value) {
              index = select.$getIndex(value);
              return angular.isDefined(index) ? select.$scope.$matches[index].label : false;
            }).filter(angular.isDefined);
            if (selected.length > (options.maxLength || defaults.maxLength)) {
              selected = selected.length + ' ' + (options.maxLengthHtml || defaults.maxLengthHtml);
            } else {
              selected = selected.join(', ');
            }
          } else {
            index = select.$getIndex(controller.$modelValue);
            selected = angular.isDefined(index) ? select.$scope.$matches[index].label : false;
          }
          element.html((selected ? selected : attr.placeholder || defaults.placeholder) + defaults.caretHtml);
        };
        // Garbage collection
        scope.$on('$destroy', function () {
          select.destroy();
          options = null;
          select = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/scrollspy/scrollspy.js
angular.module('mgcrea.ngStrap.scrollspy', [
  'mgcrea.ngStrap.helpers.debounce',
  'mgcrea.ngStrap.helpers.dimensions'
]).provider('$scrollspy', function () {
  // Pool of registered spies
  var spies = this.$$spies = {};
  var defaults = this.defaults = {
      debounce: 150,
      throttle: 100,
      offset: 100
    };
  this.$get = [
    '$window',
    '$document',
    '$rootScope',
    'dimensions',
    'debounce',
    'throttle',
    function ($window, $document, $rootScope, dimensions, debounce, throttle) {
      var windowEl = angular.element($window);
      var docEl = angular.element($document.prop('documentElement'));
      var bodyEl = angular.element($window.document.body);
      // Helper functions
      function nodeName(element, name) {
        return element[0].nodeName && element[0].nodeName.toLowerCase() === name.toLowerCase();
      }
      function ScrollSpyFactory(config) {
        // Common vars
        var options = angular.extend({}, defaults, config);
        if (!options.element)
          options.element = bodyEl;
        var isWindowSpy = nodeName(options.element, 'body');
        var scrollEl = isWindowSpy ? windowEl : options.element;
        var scrollId = isWindowSpy ? 'window' : options.id;
        // Use existing spy
        if (spies[scrollId]) {
          spies[scrollId].$$count++;
          return spies[scrollId];
        }
        var $scrollspy = {};
        // Private vars
        var unbindViewContentLoaded, unbindIncludeContentLoaded;
        var trackedElements = $scrollspy.$trackedElements = [];
        var sortedElements = [];
        var activeTarget;
        var debouncedCheckPosition;
        var throttledCheckPosition;
        var debouncedCheckOffsets;
        var viewportHeight;
        var scrollTop;
        $scrollspy.init = function () {
          // Setup internal ref counter
          this.$$count = 1;
          // Bind events
          debouncedCheckPosition = debounce(this.checkPosition, options.debounce);
          throttledCheckPosition = throttle(this.checkPosition, options.throttle);
          scrollEl.on('click', this.checkPositionWithEventLoop);
          windowEl.on('resize', debouncedCheckPosition);
          scrollEl.on('scroll', throttledCheckPosition);
          debouncedCheckOffsets = debounce(this.checkOffsets, options.debounce);
          unbindViewContentLoaded = $rootScope.$on('$viewContentLoaded', debouncedCheckOffsets);
          unbindIncludeContentLoaded = $rootScope.$on('$includeContentLoaded', debouncedCheckOffsets);
          debouncedCheckOffsets();
          // Register spy for reuse
          if (scrollId) {
            spies[scrollId] = $scrollspy;
          }
        };
        $scrollspy.destroy = function () {
          // Check internal ref counter
          this.$$count--;
          if (this.$$count > 0) {
            return;
          }
          // Unbind events
          scrollEl.off('click', this.checkPositionWithEventLoop);
          windowEl.off('resize', debouncedCheckPosition);
          scrollEl.off('scroll', debouncedCheckPosition);
          unbindViewContentLoaded();
          unbindIncludeContentLoaded();
          if (scrollId) {
            delete spies[scrollId];
          }
        };
        $scrollspy.checkPosition = function () {
          // Not ready yet
          if (!sortedElements.length)
            return;
          // Calculate the scroll position
          scrollTop = (isWindowSpy ? $window.pageYOffset : scrollEl.prop('scrollTop')) || 0;
          // Calculate the viewport height for use by the components
          viewportHeight = Math.max($window.innerHeight, docEl.prop('clientHeight'));
          // Activate first element if scroll is smaller
          if (scrollTop < sortedElements[0].offsetTop && activeTarget !== sortedElements[0].target) {
            return $scrollspy.$activateElement(sortedElements[0]);
          }
          // Activate proper element
          for (var i = sortedElements.length; i--;) {
            if (angular.isUndefined(sortedElements[i].offsetTop) || sortedElements[i].offsetTop === null)
              continue;
            if (activeTarget === sortedElements[i].target)
              continue;
            if (scrollTop < sortedElements[i].offsetTop)
              continue;
            if (sortedElements[i + 1] && scrollTop > sortedElements[i + 1].offsetTop)
              continue;
            return $scrollspy.$activateElement(sortedElements[i]);
          }
        };
        $scrollspy.checkPositionWithEventLoop = function () {
          setTimeout(this.checkPosition, 1);
        };
        // Protected methods
        $scrollspy.$activateElement = function (element) {
          if (activeTarget) {
            var activeElement = $scrollspy.$getTrackedElement(activeTarget);
            if (activeElement) {
              activeElement.source.removeClass('active');
              if (nodeName(activeElement.source, 'li') && nodeName(activeElement.source.parent().parent(), 'li')) {
                activeElement.source.parent().parent().removeClass('active');
              }
            }
          }
          activeTarget = element.target;
          element.source.addClass('active');
          if (nodeName(element.source, 'li') && nodeName(element.source.parent().parent(), 'li')) {
            element.source.parent().parent().addClass('active');
          }
        };
        $scrollspy.$getTrackedElement = function (target) {
          return trackedElements.filter(function (obj) {
            return obj.target === target;
          })[0];
        };
        // Track offsets behavior
        $scrollspy.checkOffsets = function () {
          angular.forEach(trackedElements, function (trackedElement) {
            var targetElement = document.querySelector(trackedElement.target);
            trackedElement.offsetTop = targetElement ? dimensions.offset(targetElement).top : null;
            if (options.offset && trackedElement.offsetTop !== null)
              trackedElement.offsetTop -= options.offset * 1;
          });
          sortedElements = trackedElements.filter(function (el) {
            return el.offsetTop !== null;
          }).sort(function (a, b) {
            return a.offsetTop - b.offsetTop;
          });
          debouncedCheckPosition();
        };
        $scrollspy.trackElement = function (target, source) {
          trackedElements.push({
            target: target,
            source: source
          });
        };
        $scrollspy.untrackElement = function (target, source) {
          var toDelete;
          for (var i = trackedElements.length; i--;) {
            if (trackedElements[i].target === target && trackedElements[i].source === source) {
              toDelete = i;
              break;
            }
          }
          trackedElements = trackedElements.splice(toDelete, 1);
        };
        $scrollspy.activate = function (i) {
          trackedElements[i].addClass('active');
        };
        // Initialize plugin
        $scrollspy.init();
        return $scrollspy;
      }
      return ScrollSpyFactory;
    }
  ];
}).directive('bsScrollspy', [
  '$rootScope',
  'debounce',
  'dimensions',
  '$scrollspy',
  function ($rootScope, debounce, dimensions, $scrollspy) {
    return {
      restrict: 'EAC',
      link: function postLink(scope, element, attr) {
        var options = { scope: scope };
        angular.forEach([
          'offset',
          'target'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        var scrollspy = $scrollspy(options);
        scrollspy.trackElement(options.target, element);
        scope.$on('$destroy', function () {
          scrollspy.untrackElement(options.target, element);
          scrollspy.destroy();
          options = null;
          scrollspy = null;
        });
      }
    };
  }
]).directive('bsScrollspyList', [
  '$rootScope',
  'debounce',
  'dimensions',
  '$scrollspy',
  function ($rootScope, debounce, dimensions, $scrollspy) {
    return {
      restrict: 'A',
      compile: function postLink(element, attr) {
        var children = element[0].querySelectorAll('li > a[href]');
        angular.forEach(children, function (child) {
          var childEl = angular.element(child);
          childEl.parent().attr('bs-scrollspy', '').attr('data-target', childEl.attr('href'));
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/tab/tab.js
angular.module('mgcrea.ngStrap.tab', []).run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('$pane', '{{pane.content}}');
  }
]).provider('$tab', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      template: 'tab/tab.tpl.html'
    };
  this.$get = function () {
    return { defaults: defaults };
  };
}).directive('bsTabs', [
  '$window',
  '$animate',
  '$tab',
  function ($window, $animate, $tab) {
    var defaults = $tab.defaults;
    return {
      restrict: 'EAC',
      scope: true,
      require: '?ngModel',
      templateUrl: function (element, attr) {
        return attr.template || defaults.template;
      },
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = defaults;
        angular.forEach(['animation'], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Require scope as an object
        attr.bsTabs && scope.$watch(attr.bsTabs, function (newValue, oldValue) {
          scope.panes = newValue;
        }, true);
        // Add base class
        element.addClass('tabs');
        // Support animations
        if (options.animation) {
          element.addClass(options.animation);
        }
        scope.active = scope.activePane = 0;
        // view -> model
        scope.setActive = function (index, ev) {
          scope.active = index;
          if (controller) {
            controller.$setViewValue(index);
          }
        };
        // model -> view
        if (controller) {
          controller.$render = function () {
            scope.active = controller.$modelValue * 1;
          };
        }
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/timepicker/timepicker.js
angular.module('mgcrea.ngStrap.timepicker', [
  'mgcrea.ngStrap.helpers.dateParser',
  'mgcrea.ngStrap.tooltip'
]).provider('$timepicker', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'timepicker',
      placement: 'bottom-left',
      template: 'timepicker/timepicker.tpl.html',
      trigger: 'focus',
      container: false,
      keyboard: true,
      html: false,
      delay: 0,
      useNative: true,
      timeType: 'date',
      timeFormat: 'shortTime',
      autoclose: false,
      minTime: -Infinity,
      maxTime: +Infinity,
      length: 5,
      hourStep: 1,
      minuteStep: 5
    };
  this.$get = [
    '$window',
    '$document',
    '$rootScope',
    '$sce',
    '$locale',
    'dateFilter',
    '$tooltip',
    function ($window, $document, $rootScope, $sce, $locale, dateFilter, $tooltip) {
      var bodyEl = angular.element($window.document.body);
      var isTouch = 'createTouch' in $window.document;
      var isNative = /(ip(a|o)d|iphone|android)/gi.test($window.navigator.userAgent);
      if (!defaults.lang)
        defaults.lang = $locale.id;
      function timepickerFactory(element, controller, config) {
        var $timepicker = $tooltip(element, angular.extend({}, defaults, config));
        var parentScope = config.scope;
        var options = $timepicker.$options;
        var scope = $timepicker.$scope;
        // View vars
        var selectedIndex = 0;
        var startDate = controller.$dateValue || new Date();
        var viewDate = {
            hour: startDate.getHours(),
            meridian: startDate.getHours() < 12,
            minute: startDate.getMinutes(),
            second: startDate.getSeconds(),
            millisecond: startDate.getMilliseconds()
          };
        var format = $locale.DATETIME_FORMATS[options.timeFormat] || options.timeFormat;
        var formats = /(h+)[:]?(m+)[ ]?(a?)/i.exec(format).slice(1);
        // Scope methods
        scope.$select = function (date, index) {
          $timepicker.select(date, index);
        };
        scope.$moveIndex = function (value, index) {
          $timepicker.$moveIndex(value, index);
        };
        scope.$switchMeridian = function (date) {
          $timepicker.switchMeridian(date);
        };
        // Public methods
        $timepicker.update = function (date) {
          // console.warn('$timepicker.update() newValue=%o', date);
          if (angular.isDate(date) && !isNaN(date.getTime())) {
            $timepicker.$date = date;
            angular.extend(viewDate, {
              hour: date.getHours(),
              minute: date.getMinutes(),
              second: date.getSeconds(),
              millisecond: date.getMilliseconds()
            });
            $timepicker.$build();
          } else if (!$timepicker.$isBuilt) {
            $timepicker.$build();
          }
        };
        $timepicker.select = function (date, index, keep) {
          // console.warn('$timepicker.select', date, scope.$mode);
          if (!controller.$dateValue || isNaN(controller.$dateValue.getTime()))
            controller.$dateValue = new Date(1970, 0, 1);
          if (!angular.isDate(date))
            date = new Date(date);
          if (index === 0)
            controller.$dateValue.setHours(date.getHours());
          else if (index === 1)
            controller.$dateValue.setMinutes(date.getMinutes());
          controller.$setViewValue(controller.$dateValue);
          controller.$render();
          if (options.autoclose && !keep) {
            $timepicker.hide(true);
          }
        };
        $timepicker.switchMeridian = function (date) {
          var hours = (date || controller.$dateValue).getHours();
          controller.$dateValue.setHours(hours < 12 ? hours + 12 : hours - 12);
          controller.$render();
        };
        // Protected methods
        $timepicker.$build = function () {
          // console.warn('$timepicker.$build() viewDate=%o', viewDate);
          var i, midIndex = scope.midIndex = parseInt(options.length / 2, 10);
          var hours = [], hour;
          for (i = 0; i < options.length; i++) {
            hour = new Date(1970, 0, 1, viewDate.hour - (midIndex - i) * options.hourStep);
            hours.push({
              date: hour,
              label: dateFilter(hour, formats[0]),
              selected: $timepicker.$date && $timepicker.$isSelected(hour, 0),
              disabled: $timepicker.$isDisabled(hour, 0)
            });
          }
          var minutes = [], minute;
          for (i = 0; i < options.length; i++) {
            minute = new Date(1970, 0, 1, 0, viewDate.minute - (midIndex - i) * options.minuteStep);
            minutes.push({
              date: minute,
              label: dateFilter(minute, formats[1]),
              selected: $timepicker.$date && $timepicker.$isSelected(minute, 1),
              disabled: $timepicker.$isDisabled(minute, 1)
            });
          }
          var rows = [];
          for (i = 0; i < options.length; i++) {
            rows.push([
              hours[i],
              minutes[i]
            ]);
          }
          scope.rows = rows;
          scope.showAM = !!formats[2];
          scope.isAM = ($timepicker.$date || hours[midIndex].date).getHours() < 12;
          $timepicker.$isBuilt = true;
        };
        $timepicker.$isSelected = function (date, index) {
          if (!$timepicker.$date)
            return false;
          else if (index === 0) {
            return date.getHours() === $timepicker.$date.getHours();
          } else if (index === 1) {
            return date.getMinutes() === $timepicker.$date.getMinutes();
          }
        };
        $timepicker.$isDisabled = function (date, index) {
          var selectedTime;
          if (index === 0) {
            selectedTime = date.getTime() + viewDate.minute * 60000;
          } else if (index === 1) {
            selectedTime = date.getTime() + viewDate.hour * 3600000;
          }
          return selectedTime < options.minTime || selectedTime > options.maxTime;
        };
        $timepicker.$moveIndex = function (value, index) {
          var targetDate;
          if (index === 0) {
            targetDate = new Date(1970, 0, 1, viewDate.hour + value * options.length, viewDate.minute);
            angular.extend(viewDate, { hour: targetDate.getHours() });
          } else if (index === 1) {
            targetDate = new Date(1970, 0, 1, viewDate.hour, viewDate.minute + value * options.length * options.minuteStep);
            angular.extend(viewDate, { minute: targetDate.getMinutes() });
          }
          $timepicker.$build();
        };
        $timepicker.$onMouseDown = function (evt) {
          // Prevent blur on mousedown on .dropdown-menu
          if (evt.target.nodeName.toLowerCase() !== 'input')
            evt.preventDefault();
          evt.stopPropagation();
          // Emulate click for mobile devices
          if (isTouch) {
            var targetEl = angular.element(evt.target);
            if (targetEl[0].nodeName.toLowerCase() !== 'button') {
              targetEl = targetEl.parent();
            }
            targetEl.triggerHandler('click');
          }
        };
        $timepicker.$onKeyDown = function (evt) {
          if (!/(38|37|39|40|13)/.test(evt.keyCode) || evt.shiftKey || evt.altKey)
            return;
          evt.preventDefault();
          evt.stopPropagation();
          // Close on enter
          if (evt.keyCode === 13)
            return $timepicker.hide(true);
          // Navigate with keyboard
          var newDate = new Date($timepicker.$date);
          var hours = newDate.getHours(), hoursLength = dateFilter(newDate, 'h').length;
          var minutes = newDate.getMinutes(), minutesLength = dateFilter(newDate, 'mm').length;
          var lateralMove = /(37|39)/.test(evt.keyCode);
          var count = 2 + !!formats[2] * 1;
          // Navigate indexes (left, right)
          if (lateralMove) {
            if (evt.keyCode === 37)
              selectedIndex = selectedIndex < 1 ? count - 1 : selectedIndex - 1;
            else if (evt.keyCode === 39)
              selectedIndex = selectedIndex < count - 1 ? selectedIndex + 1 : 0;
          }
          // Update values (up, down)
          if (selectedIndex === 0) {
            if (lateralMove)
              return createSelection(0, hoursLength);
            if (evt.keyCode === 38)
              newDate.setHours(hours - options.hourStep);
            else if (evt.keyCode === 40)
              newDate.setHours(hours + options.hourStep);
          } else if (selectedIndex === 1) {
            if (lateralMove)
              return createSelection(hoursLength + 1, hoursLength + 1 + minutesLength);
            if (evt.keyCode === 38)
              newDate.setMinutes(minutes - options.minuteStep);
            else if (evt.keyCode === 40)
              newDate.setMinutes(minutes + options.minuteStep);
          } else if (selectedIndex === 2) {
            if (lateralMove)
              return createSelection(hoursLength + 1 + minutesLength + 1, hoursLength + 1 + minutesLength + 3);
            $timepicker.switchMeridian();
          }
          $timepicker.select(newDate, selectedIndex, true);
          parentScope.$digest();
        };
        // Private
        function createSelection(start, end) {
          if (element[0].createTextRange) {
            var selRange = element[0].createTextRange();
            selRange.collapse(true);
            selRange.moveStart('character', start);
            selRange.moveEnd('character', end);
            selRange.select();
          } else if (element[0].setSelectionRange) {
            element[0].setSelectionRange(start, end);
          } else if (angular.isUndefined(element[0].selectionStart)) {
            element[0].selectionStart = start;
            element[0].selectionEnd = end;
          }
        }
        function focusElement() {
          element[0].focus();
        }
        // Overrides
        var _init = $timepicker.init;
        $timepicker.init = function () {
          if (isNative && options.useNative) {
            element.prop('type', 'time');
            element.css('-webkit-appearance', 'textfield');
            return;
          } else if (isTouch) {
            element.prop('type', 'text');
            element.attr('readonly', 'true');
            element.on('click', focusElement);
          }
          _init();
        };
        var _destroy = $timepicker.destroy;
        $timepicker.destroy = function () {
          if (isNative && options.useNative) {
            element.off('click', focusElement);
          }
          _destroy();
        };
        var _show = $timepicker.show;
        $timepicker.show = function () {
          _show();
          setTimeout(function () {
            $timepicker.$element.on(isTouch ? 'touchstart' : 'mousedown', $timepicker.$onMouseDown);
            if (options.keyboard) {
              element.on('keydown', $timepicker.$onKeyDown);
            }
          });
        };
        var _hide = $timepicker.hide;
        $timepicker.hide = function (blur) {
          $timepicker.$element.off(isTouch ? 'touchstart' : 'mousedown', $timepicker.$onMouseDown);
          if (options.keyboard) {
            element.off('keydown', $timepicker.$onKeyDown);
          }
          _hide(blur);
        };
        return $timepicker;
      }
      timepickerFactory.defaults = defaults;
      return timepickerFactory;
    }
  ];
}).directive('bsTimepicker', [
  '$window',
  '$parse',
  '$q',
  '$locale',
  'dateFilter',
  '$timepicker',
  '$dateParser',
  '$timeout',
  function ($window, $parse, $q, $locale, dateFilter, $timepicker, $dateParser, $timeout) {
    var defaults = $timepicker.defaults;
    var isNative = /(ip(a|o)d|iphone|android)/gi.test($window.navigator.userAgent);
    var requestAnimationFrame = $window.requestAnimationFrame || $window.setTimeout;
    return {
      restrict: 'EAC',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = {
            scope: scope,
            controller: controller
          };
        angular.forEach([
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'template',
          'autoclose',
          'timeType',
          'timeFormat',
          'useNative',
          'hourStep',
          'minuteStep'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Initialize timepicker
        if (isNative && (options.useNative || defaults.useNative))
          options.timeFormat = 'HH:mm';
        var timepicker = $timepicker(element, controller, options);
        options = timepicker.$options;
        // Initialize parser
        var dateParser = $dateParser({
            format: options.timeFormat,
            lang: options.lang
          });
        // Observe attributes for changes
        angular.forEach([
          'minTime',
          'maxTime'
        ], function (key) {
          // console.warn('attr.$observe(%s)', key, attr[key]);
          angular.isDefined(attr[key]) && attr.$observe(key, function (newValue) {
            if (newValue === 'now') {
              timepicker.$options[key] = new Date().setFullYear(1970, 0, 1);
            } else if (angular.isString(newValue) && newValue.match(/^".+"$/)) {
              timepicker.$options[key] = +new Date(newValue.substr(1, newValue.length - 2));
            } else {
              timepicker.$options[key] = dateParser.parse(newValue);
            }
            !isNaN(timepicker.$options[key]) && timepicker.$build();
          });
        });
        // Watch model for changes
        scope.$watch(attr.ngModel, function (newValue, oldValue) {
          // console.warn('scope.$watch(%s)', attr.ngModel, newValue, oldValue, controller.$dateValue);
          timepicker.update(controller.$dateValue);
        }, true);
        // viewValue -> $parsers -> modelValue
        controller.$parsers.unshift(function (viewValue) {
          // console.warn('$parser("%s"): viewValue=%o', element.attr('ng-model'), viewValue);
          // Null values should correctly reset the model value & validity
          if (!viewValue) {
            controller.$setValidity('date', true);
            return;
          }
          var parsedTime = dateParser.parse(viewValue, controller.$dateValue);
          if (!parsedTime || isNaN(parsedTime.getTime())) {
            controller.$setValidity('date', false);
          } else {
            var isValid = parsedTime.getTime() >= options.minTime && parsedTime.getTime() <= options.maxTime;
            controller.$setValidity('date', isValid);
            // Only update the model when we have a valid date
            if (isValid)
              controller.$dateValue = parsedTime;
          }
          if (options.timeType === 'string') {
            return dateFilter(viewValue, options.timeFormat);
          } else if (options.timeType === 'number') {
            return controller.$dateValue.getTime();
          } else if (options.timeType === 'iso') {
            return controller.$dateValue.toISOString();
          } else {
            return new Date(controller.$dateValue);
          }
        });
        // modelValue -> $formatters -> viewValue
        controller.$formatters.push(function (modelValue) {
          // console.warn('$formatter("%s"): modelValue=%o (%o)', element.attr('ng-model'), modelValue, typeof modelValue);
          var date;
          if (angular.isUndefined(modelValue) || modelValue === null) {
            date = NaN;
          } else if (angular.isDate(modelValue)) {
            date = modelValue;
          } else if (options.timeType === 'string') {
            date = dateParser.parse(modelValue);
          } else {
            date = new Date(modelValue);
          }
          // Setup default value?
          // if(isNaN(date.getTime())) date = new Date(new Date().setMinutes(0) + 36e5);
          controller.$dateValue = date;
          return controller.$dateValue;
        });
        // viewValue -> element
        controller.$render = function () {
          // console.warn('$render("%s"): viewValue=%o', element.attr('ng-model'), controller.$viewValue);
          element.val(!controller.$dateValue || isNaN(controller.$dateValue.getTime()) ? '' : dateFilter(controller.$dateValue, options.timeFormat));
        };
        // Garbage collection
        scope.$on('$destroy', function () {
          timepicker.destroy();
          options = null;
          timepicker = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/tooltip/tooltip.js
angular.module('mgcrea.ngStrap.tooltip', [
  'ngAnimate',
  'mgcrea.ngStrap.helpers.dimensions'
]).provider('$tooltip', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'tooltip',
      prefixEvent: 'tooltip',
      container: false,
      placement: 'top',
      template: 'tooltip/tooltip.tpl.html',
      contentTemplate: false,
      trigger: 'hover focus',
      keyboard: false,
      html: false,
      show: false,
      title: '',
      type: '',
      delay: 0
    };
  this.$get = [
    '$window',
    '$rootScope',
    '$compile',
    '$q',
    '$templateCache',
    '$http',
    '$animate',
    '$timeout',
    'dimensions',
    '$$rAF',
    function ($window, $rootScope, $compile, $q, $templateCache, $http, $animate, $timeout, dimensions, $$rAF) {
      var trim = String.prototype.trim;
      var isTouch = 'createTouch' in $window.document;
      var htmlReplaceRegExp = /ng-bind="/gi;
      function TooltipFactory(element, config) {
        var $tooltip = {};
        // Common vars
        var options = $tooltip.$options = angular.extend({}, defaults, config);
        $tooltip.$promise = fetchTemplate(options.template);
        var scope = $tooltip.$scope = options.scope && options.scope.$new() || $rootScope.$new();
        if (options.delay && angular.isString(options.delay)) {
          options.delay = parseFloat(options.delay);
        }
        // Support scope as string options
        if (options.title) {
          $tooltip.$scope.title = options.title;
        }
        // Provide scope helpers
        scope.$hide = function () {
          scope.$$postDigest(function () {
            $tooltip.hide();
          });
        };
        scope.$show = function () {
          scope.$$postDigest(function () {
            $tooltip.show();
          });
        };
        scope.$toggle = function () {
          scope.$$postDigest(function () {
            $tooltip.toggle();
          });
        };
        $tooltip.$isShown = scope.$isShown = false;
        // Private vars
        var timeout, hoverState;
        // Support contentTemplate option
        if (options.contentTemplate) {
          $tooltip.$promise = $tooltip.$promise.then(function (template) {
            var templateEl = angular.element(template);
            return fetchTemplate(options.contentTemplate).then(function (contentTemplate) {
              var contentEl = findElement('[ng-bind="content"]', templateEl[0]);
              if (!contentEl.length)
                contentEl = findElement('[ng-bind="title"]', templateEl[0]);
              contentEl.removeAttr('ng-bind').html(contentTemplate);
              return templateEl[0].outerHTML;
            });
          });
        }
        // Fetch, compile then initialize tooltip
        var tipLinker, tipElement, tipTemplate, tipContainer;
        $tooltip.$promise.then(function (template) {
          if (angular.isObject(template))
            template = template.data;
          if (options.html)
            template = template.replace(htmlReplaceRegExp, 'ng-bind-html="');
          template = trim.apply(template);
          tipTemplate = template;
          tipLinker = $compile(template);
          $tooltip.init();
        });
        $tooltip.init = function () {
          // Options: delay
          if (options.delay && angular.isNumber(options.delay)) {
            options.delay = {
              show: options.delay,
              hide: options.delay
            };
          }
          // Replace trigger on touch devices ?
          // if(isTouch && options.trigger === defaults.trigger) {
          //   options.trigger.replace(/hover/g, 'click');
          // }
          // Options : container
          if (options.container === 'self') {
            tipContainer = element;
          } else if (options.container) {
            tipContainer = findElement(options.container);
          }
          // Options: trigger
          var triggers = options.trigger.split(' ');
          angular.forEach(triggers, function (trigger) {
            if (trigger === 'click') {
              element.on('click', $tooltip.toggle);
            } else if (trigger !== 'manual') {
              element.on(trigger === 'hover' ? 'mouseenter' : 'focus', $tooltip.enter);
              element.on(trigger === 'hover' ? 'mouseleave' : 'blur', $tooltip.leave);
              trigger !== 'hover' && element.on(isTouch ? 'touchstart' : 'mousedown', $tooltip.$onFocusElementMouseDown);
            }
          });
          // Options: show
          if (options.show) {
            scope.$$postDigest(function () {
              options.trigger === 'focus' ? element[0].focus() : $tooltip.show();
            });
          }
        };
        $tooltip.destroy = function () {
          // Unbind events
          var triggers = options.trigger.split(' ');
          for (var i = triggers.length; i--;) {
            var trigger = triggers[i];
            if (trigger === 'click') {
              element.off('click', $tooltip.toggle);
            } else if (trigger !== 'manual') {
              element.off(trigger === 'hover' ? 'mouseenter' : 'focus', $tooltip.enter);
              element.off(trigger === 'hover' ? 'mouseleave' : 'blur', $tooltip.leave);
              trigger !== 'hover' && element.off(isTouch ? 'touchstart' : 'mousedown', $tooltip.$onFocusElementMouseDown);
            }
          }
          // Remove element
          if (tipElement) {
            tipElement.remove();
            tipElement = null;
          }
          // Destroy scope
          scope.$destroy();
        };
        $tooltip.enter = function () {
          clearTimeout(timeout);
          hoverState = 'in';
          if (!options.delay || !options.delay.show) {
            return $tooltip.show();
          }
          timeout = setTimeout(function () {
            if (hoverState === 'in')
              $tooltip.show();
          }, options.delay.show);
        };
        $tooltip.show = function () {
          scope.$emit(options.prefixEvent + '.show.before', $tooltip);
          var parent = options.container ? tipContainer : null;
          var after = options.container ? null : element;
          // Hide any existing tipElement
          if (tipElement)
            tipElement.remove();
          // Fetch a cloned element linked from template
          tipElement = $tooltip.$element = tipLinker(scope, function (clonedElement, scope) {
          });
          // Set the initial positioning.
          tipElement.css({
            top: '0px',
            left: '0px',
            display: 'block'
          }).addClass(options.placement);
          // Options: animation
          if (options.animation)
            tipElement.addClass(options.animation);
          // Options: type
          if (options.type)
            tipElement.addClass(options.prefixClass + '-' + options.type);
          $animate.enter(tipElement, parent, after, function () {
            scope.$emit(options.prefixEvent + '.show', $tooltip);
          });
          $tooltip.$isShown = scope.$isShown = true;
          scope.$$phase || scope.$root.$$phase || scope.$digest();
          $$rAF($tooltip.$applyPlacement);
          // var a = bodyEl.offsetWidth + 1; ?
          // Bind events
          if (options.keyboard) {
            if (options.trigger !== 'focus') {
              $tooltip.focus();
              tipElement.on('keyup', $tooltip.$onKeyUp);
            } else {
              element.on('keyup', $tooltip.$onFocusKeyUp);
            }
          }
        };
        $tooltip.leave = function () {
          clearTimeout(timeout);
          hoverState = 'out';
          if (!options.delay || !options.delay.hide) {
            return $tooltip.hide();
          }
          timeout = setTimeout(function () {
            if (hoverState === 'out') {
              $tooltip.hide();
            }
          }, options.delay.hide);
        };
        $tooltip.hide = function (blur) {
          if (!$tooltip.$isShown)
            return;
          scope.$emit(options.prefixEvent + '.hide.before', $tooltip);
          $animate.leave(tipElement, function () {
            scope.$emit(options.prefixEvent + '.hide', $tooltip);
          });
          $tooltip.$isShown = scope.$isShown = false;
          scope.$$phase || scope.$root.$$phase || scope.$digest();
          // Unbind events
          if (options.keyboard && tipElement !== null) {
            tipElement.off('keyup', $tooltip.$onKeyUp);
          }
          // Allow to blur the input when hidden, like when pressing enter key
          if (blur && options.trigger === 'focus') {
            return element[0].blur();
          }
        };
        $tooltip.toggle = function () {
          $tooltip.$isShown ? $tooltip.leave() : $tooltip.enter();
        };
        $tooltip.focus = function () {
          tipElement[0].focus();
        };
        // Protected methods
        $tooltip.$applyPlacement = function () {
          if (!tipElement)
            return;
          // Get the position of the tooltip element.
          var elementPosition = getPosition();
          // Get the height and width of the tooltip so we can center it.
          var tipWidth = tipElement.prop('offsetWidth'), tipHeight = tipElement.prop('offsetHeight');
          // Get the tooltip's top and left coordinates to center it with this directive.
          var tipPosition = getCalculatedOffset(options.placement, elementPosition, tipWidth, tipHeight);
          // Now set the calculated positioning.
          tipPosition.top += 'px';
          tipPosition.left += 'px';
          tipElement.css(tipPosition);
        };
        $tooltip.$onKeyUp = function (evt) {
          evt.which === 27 && $tooltip.hide();
        };
        $tooltip.$onFocusKeyUp = function (evt) {
          evt.which === 27 && element[0].blur();
        };
        $tooltip.$onFocusElementMouseDown = function (evt) {
          evt.preventDefault();
          evt.stopPropagation();
          // Some browsers do not auto-focus buttons (eg. Safari)
          $tooltip.$isShown ? element[0].blur() : element[0].focus();
        };
        // Private methods
        function getPosition() {
          if (options.container === 'body') {
            return dimensions.offset(element[0]);
          } else {
            return dimensions.position(element[0]);
          }
        }
        function getCalculatedOffset(placement, position, actualWidth, actualHeight) {
          var offset;
          var split = placement.split('-');
          switch (split[0]) {
          case 'right':
            offset = {
              top: position.top + position.height / 2 - actualHeight / 2,
              left: position.left + position.width
            };
            break;
          case 'bottom':
            offset = {
              top: position.top + position.height,
              left: position.left + position.width / 2 - actualWidth / 2
            };
            break;
          case 'left':
            offset = {
              top: position.top + position.height / 2 - actualHeight / 2,
              left: position.left - actualWidth
            };
            break;
          default:
            offset = {
              top: position.top - actualHeight,
              left: position.left + position.width / 2 - actualWidth / 2
            };
            break;
          }
          if (!split[1]) {
            return offset;
          }
          // Add support for corners @todo css
          if (split[0] === 'top' || split[0] === 'bottom') {
            switch (split[1]) {
            case 'left':
              offset.left = position.left;
              break;
            case 'right':
              offset.left = position.left + position.width - actualWidth;
            }
          } else if (split[0] === 'left' || split[0] === 'right') {
            switch (split[1]) {
            case 'top':
              offset.top = position.top - actualHeight;
              break;
            case 'bottom':
              offset.top = position.top + position.height;
            }
          }
          return offset;
        }
        return $tooltip;
      }
      // Helper functions
      function findElement(query, element) {
        return angular.element((element || document).querySelectorAll(query));
      }
      function fetchTemplate(template) {
        return $q.when($templateCache.get(template) || $http.get(template)).then(function (res) {
          if (angular.isObject(res)) {
            $templateCache.put(template, res.data);
            return res.data;
          }
          return res;
        });
      }
      return TooltipFactory;
    }
  ];
}).directive('bsTooltip', [
  '$window',
  '$location',
  '$sce',
  '$tooltip',
  '$$rAF',
  function ($window, $location, $sce, $tooltip, $$rAF) {
    return {
      restrict: 'EAC',
      scope: true,
      link: function postLink(scope, element, attr, transclusion) {
        // Directive options
        var options = { scope: scope };
        angular.forEach([
          'template',
          'contentTemplate',
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'type'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Observe scope attributes for change
        angular.forEach(['title'], function (key) {
          attr[key] && attr.$observe(key, function (newValue, oldValue) {
            scope[key] = $sce.trustAsHtml(newValue);
            angular.isDefined(oldValue) && $$rAF(function () {
              tooltip && tooltip.$applyPlacement();
            });
          });
        });
        // Support scope as an object
        attr.bsTooltip && scope.$watch(attr.bsTooltip, function (newValue, oldValue) {
          if (angular.isObject(newValue)) {
            angular.extend(scope, newValue);
          } else {
            scope.title = newValue;
          }
          angular.isDefined(oldValue) && $$rAF(function () {
            tooltip && tooltip.$applyPlacement();
          });
        }, true);
        // Initialize popover
        var tooltip = $tooltip(element, options);
        // Garbage collection
        scope.$on('$destroy', function () {
          tooltip.destroy();
          options = null;
          tooltip = null;
        });
      }
    };
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/typeahead/typeahead.js
angular.module('mgcrea.ngStrap.typeahead', [
  'mgcrea.ngStrap.tooltip',
  'mgcrea.ngStrap.helpers.parseOptions'
]).provider('$typeahead', function () {
  var defaults = this.defaults = {
      animation: 'am-fade',
      prefixClass: 'typeahead',
      placement: 'bottom-left',
      template: 'typeahead/typeahead.tpl.html',
      trigger: 'focus',
      container: false,
      keyboard: true,
      html: false,
      delay: 0,
      minLength: 1,
      filter: 'filter',
      limit: 6
    };
  this.$get = [
    '$window',
    '$rootScope',
    '$tooltip',
    function ($window, $rootScope, $tooltip) {
      var bodyEl = angular.element($window.document.body);
      function TypeaheadFactory(element, config) {
        var $typeahead = {};
        // Common vars
        var options = angular.extend({}, defaults, config);
        var controller = options.controller;
        $typeahead = $tooltip(element, options);
        var parentScope = config.scope;
        var scope = $typeahead.$scope;
        scope.$matches = [];
        scope.$activeIndex = 0;
        scope.$activate = function (index) {
          scope.$$postDigest(function () {
            $typeahead.activate(index);
          });
        };
        scope.$select = function (index, evt) {
          scope.$$postDigest(function () {
            $typeahead.select(index);
          });
        };
        scope.$isVisible = function () {
          return $typeahead.$isVisible();
        };
        // Public methods
        $typeahead.update = function (matches) {
          scope.$matches = matches;
          if (scope.$activeIndex >= matches.length) {
            scope.$activeIndex = 0;
          }
        };
        $typeahead.activate = function (index) {
          scope.$activeIndex = index;
        };
        $typeahead.select = function (index) {
          var value = scope.$matches[index].value;
          if (controller) {
            controller.$setViewValue(value);
            controller.$render();
            if (parentScope)
              parentScope.$digest();
          }
          if (options.trigger === 'focus')
            element[0].blur();
          else if ($typeahead.$isShown)
            $typeahead.hide();
          scope.$activeIndex = 0;
          // Emit event
          scope.$emit('$typeahead.select', value, index);
        };
        // Protected methods
        $typeahead.$isVisible = function () {
          if (!options.minLength || !controller) {
            return !!scope.$matches.length;
          }
          // minLength support
          return scope.$matches.length && angular.isString(controller.$viewValue) && controller.$viewValue.length >= options.minLength;
        };
        $typeahead.$getIndex = function (value) {
          var l = scope.$matches.length, i = l;
          if (!l)
            return;
          for (i = l; i--;) {
            if (scope.$matches[i].value === value)
              break;
          }
          if (i < 0)
            return;
          return i;
        };
        $typeahead.$onMouseDown = function (evt) {
          // Prevent blur on mousedown
          evt.preventDefault();
          evt.stopPropagation();
        };
        $typeahead.$onKeyDown = function (evt) {
          if (!/(38|40|13)/.test(evt.keyCode))
            return;
          evt.preventDefault();
          evt.stopPropagation();
          // Select with enter
          if (evt.keyCode === 13 && scope.$matches.length) {
            return $typeahead.select(scope.$activeIndex);
          }
          // Navigate with keyboard
          if (evt.keyCode === 38 && scope.$activeIndex > 0)
            scope.$activeIndex--;
          else if (evt.keyCode === 40 && scope.$activeIndex < scope.$matches.length - 1)
            scope.$activeIndex++;
          else if (angular.isUndefined(scope.$activeIndex))
            scope.$activeIndex = 0;
          scope.$digest();
        };
        // Overrides
        var show = $typeahead.show;
        $typeahead.show = function () {
          show();
          setTimeout(function () {
            $typeahead.$element.on('mousedown', $typeahead.$onMouseDown);
            if (options.keyboard) {
              element.on('keydown', $typeahead.$onKeyDown);
            }
          });
        };
        var hide = $typeahead.hide;
        $typeahead.hide = function () {
          $typeahead.$element.off('mousedown', $typeahead.$onMouseDown);
          if (options.keyboard) {
            element.off('keydown', $typeahead.$onKeyDown);
          }
          hide();
        };
        return $typeahead;
      }
      TypeaheadFactory.defaults = defaults;
      return TypeaheadFactory;
    }
  ];
}).directive('bsTypeahead', [
  '$window',
  '$parse',
  '$q',
  '$typeahead',
  '$parseOptions',
  function ($window, $parse, $q, $typeahead, $parseOptions) {
    var defaults = $typeahead.defaults;
    return {
      restrict: 'EAC',
      require: 'ngModel',
      link: function postLink(scope, element, attr, controller) {
        // Directive options
        var options = {
            scope: scope,
            controller: controller
          };
        angular.forEach([
          'placement',
          'container',
          'delay',
          'trigger',
          'keyboard',
          'html',
          'animation',
          'template',
          'filter',
          'limit',
          'minLength'
        ], function (key) {
          if (angular.isDefined(attr[key]))
            options[key] = attr[key];
        });
        // Build proper ngOptions
        var filter = options.filter || defaults.filter;
        var limit = options.limit || defaults.limit;
        var ngOptions = attr.ngOptions;
        if (filter)
          ngOptions += ' | ' + filter + ':$viewValue';
        if (limit)
          ngOptions += ' | limitTo:' + limit;
        var parsedOptions = $parseOptions(ngOptions);
        // Initialize typeahead
        var typeahead = $typeahead(element, options);
        // if(!dump) var dump = console.error.bind(console);
        // Watch model for changes
        scope.$watch(attr.ngModel, function (newValue, oldValue) {
          scope.$modelValue = newValue;
          //Set model value on the scope to custom templates can use it.
          parsedOptions.valuesFn(scope, controller).then(function (values) {
            if (values.length > limit)
              values = values.slice(0, limit);
            // if(matches.length === 1 && matches[0].value === newValue) return;
            typeahead.update(values);
            // Queue a new rendering that will leverage collection loading
            controller.$render();
          });
        });
        // Model rendering in view
        controller.$render = function () {
          // console.warn('$render', element.attr('ng-model'), 'controller.$modelValue', typeof controller.$modelValue, controller.$modelValue, 'controller.$viewValue', typeof controller.$viewValue, controller.$viewValue);
          if (controller.$isEmpty(controller.$viewValue))
            return element.val('');
          var index = typeahead.$getIndex(controller.$modelValue);
          var selected = angular.isDefined(index) ? typeahead.$scope.$matches[index].label : controller.$viewValue;
          element.val(selected.replace(/<(?:.|\n)*?>/gm, '').trim());
        };
        // Garbage collection
        scope.$on('$destroy', function () {
          typeahead.destroy();
          options = null;
          typeahead = null;
        });
      }
    };
  }
]);

})(window, document);

},{}],73:[function(require,module,exports){
/**
 * angular-strap
 * @version v2.0.0 - 2014-04-07
 * @link http://mgcrea.github.io/angular-strap
 * @author Olivier Louvignes (olivier@mg-crea.com)
 * @license MIT License, http://www.opensource.org/licenses/MIT
 */
(function(window, document, undefined) {
'use strict';

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/alert/alert.tpl.js
angular.module('mgcrea.ngStrap.alert').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('alert/alert.tpl.html', '<div class="alert alert-dismissable" tabindex="-1" ng-class="[type ? \'alert-\' + type : null]"><button type="button" class="close" ng-click="$hide()">&times;</button> <strong ng-bind="title"></strong>&nbsp;<span ng-bind-html="content"></span></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/aside/aside.tpl.js
angular.module('mgcrea.ngStrap.aside').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('aside/aside.tpl.html', '<div class="aside" tabindex="-1" role="dialog"><div class="aside-dialog"><div class="aside-content"><div class="aside-header" ng-show="title"><button type="button" class="close" ng-click="$hide()">&times;</button><h4 class="aside-title" ng-bind="title"></h4></div><div class="aside-body" ng-bind="content"></div><div class="aside-footer"><button type="button" class="btn btn-default" ng-click="$hide()">Close</button></div></div></div></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/datepicker/datepicker.tpl.js
angular.module('mgcrea.ngStrap.datepicker').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('datepicker/datepicker.tpl.html', '<div class="dropdown-menu datepicker" ng-class="\'datepicker-mode-\' + $mode" style="max-width: 320px"><table style="table-layout: fixed; height: 100%; width: 100%"><thead><tr class="text-center"><th><button tabindex="-1" type="button" class="btn btn-default pull-left" ng-click="$selectPane(-1)"><i class="glyphicon glyphicon-chevron-left"></i></button></th><th colspan="{{ rows[0].length - 2 }}"><button tabindex="-1" type="button" class="btn btn-default btn-block text-strong" ng-click="$toggleMode()"><strong style="text-transform: capitalize" ng-bind="title"></strong></button></th><th><button tabindex="-1" type="button" class="btn btn-default pull-right" ng-click="$selectPane(+1)"><i class="glyphicon glyphicon-chevron-right"></i></button></th></tr><tr ng-show="labels" ng-bind-html="labels"></tr></thead><tbody><tr ng-repeat="(i, row) in rows" height="{{ 100 / rows.length }}%"><td class="text-center" ng-repeat="(j, el) in row"><button tabindex="-1" type="button" class="btn btn-default" style="width: 100%" ng-class="{\'btn-primary\': el.selected}" ng-click="$select(el.date)" ng-disabled="el.disabled"><span ng-class="{\'text-muted\': el.muted}" ng-bind="el.label"></span></button></td></tr></tbody></table></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/dropdown/dropdown.tpl.js
angular.module('mgcrea.ngStrap.dropdown').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('dropdown/dropdown.tpl.html', '<ul tabindex="-1" class="dropdown-menu" role="menu"><li role="presentation" ng-class="{divider: item.divider}" ng-repeat="item in content"><a role="menuitem" tabindex="-1" ng-href="{{item.href}}" ng-if="!item.divider && item.href" ng-bind="item.text"></a> <a role="menuitem" tabindex="-1" href="javascript:void(0)" ng-if="!item.divider && item.click" ng-click="$eval(item.click);$hide()" ng-bind="item.text"></a></li></ul>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/modal/modal.tpl.js
angular.module('mgcrea.ngStrap.modal').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('modal/modal.tpl.html', '<div class="modal" tabindex="-1" role="dialog"><div class="modal-dialog"><div class="modal-content"><div class="modal-header" ng-show="title"><button type="button" class="close" ng-click="$hide()">&times;</button><h4 class="modal-title" ng-bind="title"></h4></div><div class="modal-body" ng-bind="content"></div><div class="modal-footer"><button type="button" class="btn btn-default" ng-click="$hide()">Close</button></div></div></div></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/popover/popover.tpl.js
angular.module('mgcrea.ngStrap.popover').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('popover/popover.tpl.html', '<div class="popover"><div class="arrow"></div><h3 class="popover-title" ng-bind="title" ng-show="title"></h3><div class="popover-content" ng-bind="content"></div></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/select/select.tpl.js
angular.module('mgcrea.ngStrap.select').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('select/select.tpl.html', '<ul tabindex="-1" class="select dropdown-menu" ng-show="$isVisible()" role="select"><li role="presentation" ng-repeat="match in $matches" ng-class="{active: $isActive($index)}"><a style="cursor: default" role="menuitem" tabindex="-1" ng-click="$select($index, $event)"><span ng-bind="match.label"></span> <i class="glyphicon glyphicon-ok pull-right" ng-if="$isMultiple && $isActive($index)"></i></a></li></ul>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/tab/tab.tpl.js
angular.module('mgcrea.ngStrap.tab').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('tab/tab.tpl.html', '<ul class="nav nav-tabs"><li ng-repeat="pane in panes" ng-class="{active: $index == active}"><a data-toggle="tab" ng-click="setActive($index, $event)" data-index="{{$index}}">{{pane.title}}</a></li></ul><div class="tab-content"><div ng-repeat="pane in panes" class="tab-pane" ng-class="[$index == active ? \'active\' : \'\']" ng-include="pane.template || \'$pane\'"></div></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/timepicker/timepicker.tpl.js
angular.module('mgcrea.ngStrap.timepicker').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('timepicker/timepicker.tpl.html', '<div class="dropdown-menu timepicker" style="min-width: 0px;width: auto"><table height="100%"><thead><tr class="text-center"><th><button tabindex="-1" type="button" class="btn btn-default pull-left" ng-click="$moveIndex(-1, 0)"><i class="glyphicon glyphicon-chevron-up"></i></button></th><th>&nbsp;</th><th><button tabindex="-1" type="button" class="btn btn-default pull-left" ng-click="$moveIndex(-1, 1)"><i class="glyphicon glyphicon-chevron-up"></i></button></th></tr></thead><tbody><tr ng-repeat="(i, row) in rows"><td class="text-center"><button tabindex="-1" style="width: 100%" type="button" class="btn btn-default" ng-class="{\'btn-primary\': row[0].selected}" ng-click="$select(row[0].date, 0)" ng-disabled="row[0].disabled"><span ng-class="{\'text-muted\': row[0].muted}" ng-bind="row[0].label"></span></button></td><td><span ng-bind="i == midIndex ? \':\' : \' \'"></span></td><td class="text-center"><button tabindex="-1" ng-if="row[1].date" style="width: 100%" type="button" class="btn btn-default" ng-class="{\'btn-primary\': row[1].selected}" ng-click="$select(row[1].date, 1)" ng-disabled="row[1].disabled"><span ng-class="{\'text-muted\': row[1].muted}" ng-bind="row[1].label"></span></button></td><td ng-if="showAM">&nbsp;</td><td ng-if="showAM"><button tabindex="-1" ng-show="i == midIndex - !isAM * 1" style="width: 100%" type="button" ng-class="{\'btn-primary\': !!isAM}" class="btn btn-default" ng-click="$switchMeridian()" ng-disabled="el.disabled">AM</button> <button tabindex="-1" ng-show="i == midIndex + 1 - !isAM * 1" style="width: 100%" type="button" ng-class="{\'btn-primary\': !isAM}" class="btn btn-default" ng-click="$switchMeridian()" ng-disabled="el.disabled">PM</button></td></tr></tbody><tfoot><tr class="text-center"><th><button tabindex="-1" type="button" class="btn btn-default pull-left" ng-click="$moveIndex(1, 0)"><i class="glyphicon glyphicon-chevron-down"></i></button></th><th>&nbsp;</th><th><button tabindex="-1" type="button" class="btn btn-default pull-left" ng-click="$moveIndex(1, 1)"><i class="glyphicon glyphicon-chevron-down"></i></button></th></tr></tfoot></table></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/tooltip/tooltip.tpl.js
angular.module('mgcrea.ngStrap.tooltip').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('tooltip/tooltip.tpl.html', '<div class="tooltip in" ng-show="title"><div class="tooltip-arrow"></div><div class="tooltip-inner" ng-bind="title"></div></div>');
  }
]);

// Source: /Users/olivier/Dropbox/Projects/angular-strap/src/typeahead/typeahead.tpl.js
angular.module('mgcrea.ngStrap.typeahead').run([
  '$templateCache',
  function ($templateCache) {
    $templateCache.put('typeahead/typeahead.tpl.html', '<ul tabindex="-1" class="typeahead dropdown-menu" ng-show="$isVisible()" role="select"><li role="presentation" ng-repeat="match in $matches" ng-class="{active: $index == $activeIndex}"><a role="menuitem" tabindex="-1" ng-click="$select($index, $event)" ng-bind="match.label"></a></li></ul>');
  }
]);


})(window, document);

},{}],74:[function(require,module,exports){
/**
 * @license AngularJS v1.2.10
 * (c) 2010-2014 Google, Inc. http://angularjs.org
 * License: MIT
 */
(function(window, angular, undefined) {'use strict';

/* jshint maxlen: false */

/**
 * @ngdoc overview
 * @name ngAnimate
 * @description
 *
 * # ngAnimate
 *
 * The `ngAnimate` module provides support for JavaScript, CSS3 transition and CSS3 keyframe animation hooks within existing core and custom directives.
 *
 * {@installModule animate}
 *
 * <div doc-module-components="ngAnimate"></div>
 *
 * # Usage
 *
 * To see animations in action, all that is required is to define the appropriate CSS classes
 * or to register a JavaScript animation via the myModule.animation() function. The directives that support animation automatically are:
 * `ngRepeat`, `ngInclude`, `ngIf`, `ngSwitch`, `ngShow`, `ngHide`, `ngView` and `ngClass`. Custom directives can take advantage of animation
 * by using the `$animate` service.
 *
 * Below is a more detailed breakdown of the supported animation events provided by pre-existing ng directives:
 *
 * | Directive                                                 | Supported Animations                               |
 * |---------------------------------------------------------- |----------------------------------------------------|
 * | {@link ng.directive:ngRepeat#usage_animations ngRepeat}         | enter, leave and move                              |
 * | {@link ngRoute.directive:ngView#usage_animations ngView}        | enter and leave                                    |
 * | {@link ng.directive:ngInclude#usage_animations ngInclude}       | enter and leave                                    |
 * | {@link ng.directive:ngSwitch#usage_animations ngSwitch}         | enter and leave                                    |
 * | {@link ng.directive:ngIf#usage_animations ngIf}                 | enter and leave                                    |
 * | {@link ng.directive:ngClass#usage_animations ngClass}           | add and remove                                     |
 * | {@link ng.directive:ngShow#usage_animations ngShow & ngHide}    | add and remove (the ng-hide class value)           |
 *
 * You can find out more information about animations upon visiting each directive page.
 *
 * Below is an example of how to apply animations to a directive that supports animation hooks:
 *
 * <pre>
 * <style type="text/css">
 * .slide.ng-enter, .slide.ng-leave {
 *   -webkit-transition:0.5s linear all;
 *   transition:0.5s linear all;
 * }
 *
 * .slide.ng-enter { }        /&#42; starting animations for enter &#42;/
 * .slide.ng-enter-active { } /&#42; terminal animations for enter &#42;/
 * .slide.ng-leave { }        /&#42; starting animations for leave &#42;/
 * .slide.ng-leave-active { } /&#42; terminal animations for leave &#42;/
 * </style>
 *
 * <!--
 * the animate service will automatically add .ng-enter and .ng-leave to the element
 * to trigger the CSS transition/animations
 * -->
 * <ANY class="slide" ng-include="..."></ANY>
 * </pre>
 *
 * Keep in mind that if an animation is running, any child elements cannot be animated until the parent element's
 * animation has completed.
 *
 * <h2>CSS-defined Animations</h2>
 * The animate service will automatically apply two CSS classes to the animated element and these two CSS classes
 * are designed to contain the start and end CSS styling. Both CSS transitions and keyframe animations are supported
 * and can be used to play along with this naming structure.
 *
 * The following code below demonstrates how to perform animations using **CSS transitions** with Angular:
 *
 * <pre>
 * <style type="text/css">
 * /&#42;
 *  The animate class is apart of the element and the ng-enter class
 *  is attached to the element once the enter animation event is triggered
 * &#42;/
 * .reveal-animation.ng-enter {
 *  -webkit-transition: 1s linear all; /&#42; Safari/Chrome &#42;/
 *  transition: 1s linear all; /&#42; All other modern browsers and IE10+ &#42;/
 *
 *  /&#42; The animation preparation code &#42;/
 *  opacity: 0;
 * }
 *
 * /&#42;
 *  Keep in mind that you want to combine both CSS
 *  classes together to avoid any CSS-specificity
 *  conflicts
 * &#42;/
 * .reveal-animation.ng-enter.ng-enter-active {
 *  /&#42; The animation code itself &#42;/
 *  opacity: 1;
 * }
 * </style>
 *
 * <div class="view-container">
 *   <div ng-view class="reveal-animation"></div>
 * </div>
 * </pre>
 *
 * The following code below demonstrates how to perform animations using **CSS animations** with Angular:
 *
 * <pre>
 * <style type="text/css">
 * .reveal-animation.ng-enter {
 *   -webkit-animation: enter_sequence 1s linear; /&#42; Safari/Chrome &#42;/
 *   animation: enter_sequence 1s linear; /&#42; IE10+ and Future Browsers &#42;/
 * }
 * &#64-webkit-keyframes enter_sequence {
 *   from { opacity:0; }
 *   to { opacity:1; }
 * }
 * &#64keyframes enter_sequence {
 *   from { opacity:0; }
 *   to { opacity:1; }
 * }
 * </style>
 *
 * <div class="view-container">
 *   <div ng-view class="reveal-animation"></div>
 * </div>
 * </pre>
 *
 * Both CSS3 animations and transitions can be used together and the animate service will figure out the correct duration and delay timing.
 *
 * Upon DOM mutation, the event class is added first (something like `ng-enter`), then the browser prepares itself to add
 * the active class (in this case `ng-enter-active`) which then triggers the animation. The animation module will automatically
 * detect the CSS code to determine when the animation ends. Once the animation is over then both CSS classes will be
 * removed from the DOM. If a browser does not support CSS transitions or CSS animations then the animation will start and end
 * immediately resulting in a DOM element that is at its final state. This final state is when the DOM element
 * has no CSS transition/animation classes applied to it.
 *
 * <h3>CSS Staggering Animations</h3>
 * A Staggering animation is a collection of animations that are issued with a slight delay in between each successive operation resulting in a
 * curtain-like effect. The ngAnimate module, as of 1.2.0, supports staggering animations and the stagger effect can be
 * performed by creating a **ng-EVENT-stagger** CSS class and attaching that class to the base CSS class used for
 * the animation. The style property expected within the stagger class can either be a **transition-delay** or an
 * **animation-delay** property (or both if your animation contains both transitions and keyframe animations).
 *
 * <pre>
 * .my-animation.ng-enter {
 *   /&#42; standard transition code &#42;/
 *   -webkit-transition: 1s linear all;
 *   transition: 1s linear all;
 *   opacity:0;
 * }
 * .my-animation.ng-enter-stagger {
 *   /&#42; this will have a 100ms delay between each successive leave animation &#42;/
 *   -webkit-transition-delay: 0.1s;
 *   transition-delay: 0.1s;
 *
 *   /&#42; in case the stagger doesn't work then these two values
 *    must be set to 0 to avoid an accidental CSS inheritance &#42;/
 *   -webkit-transition-duration: 0s;
 *   transition-duration: 0s;
 * }
 * .my-animation.ng-enter.ng-enter-active {
 *   /&#42; standard transition styles &#42;/
 *   opacity:1;
 * }
 * </pre>
 *
 * Staggering animations work by default in ngRepeat (so long as the CSS class is defined). Outside of ngRepeat, to use staggering animations
 * on your own, they can be triggered by firing multiple calls to the same event on $animate. However, the restrictions surrounding this
 * are that each of the elements must have the same CSS className value as well as the same parent element. A stagger operation
 * will also be reset if more than 10ms has passed after the last animation has been fired.
 *
 * The following code will issue the **ng-leave-stagger** event on the element provided:
 *
 * <pre>
 * var kids = parent.children();
 *
 * $animate.leave(kids[0]); //stagger index=0
 * $animate.leave(kids[1]); //stagger index=1
 * $animate.leave(kids[2]); //stagger index=2
 * $animate.leave(kids[3]); //stagger index=3
 * $animate.leave(kids[4]); //stagger index=4
 *
 * $timeout(function() {
 *   //stagger has reset itself
 *   $animate.leave(kids[5]); //stagger index=0
 *   $animate.leave(kids[6]); //stagger index=1
 * }, 100, false);
 * </pre>
 *
 * Stagger animations are currently only supported within CSS-defined animations.
 *
 * <h2>JavaScript-defined Animations</h2>
 * In the event that you do not want to use CSS3 transitions or CSS3 animations or if you wish to offer animations on browsers that do not
 * yet support CSS transitions/animations, then you can make use of JavaScript animations defined inside of your AngularJS module.
 *
 * <pre>
 * //!annotate="YourApp" Your AngularJS Module|Replace this or ngModule with the module that you used to define your application.
 * var ngModule = angular.module('YourApp', ['ngAnimate']);
 * ngModule.animation('.my-crazy-animation', function() {
 *   return {
 *     enter: function(element, done) {
 *       //run the animation here and call done when the animation is complete
 *       return function(cancelled) {
 *         //this (optional) function will be called when the animation
 *         //completes or when the animation is cancelled (the cancelled
 *         //flag will be set to true if cancelled).
 *       };
 *     },
 *     leave: function(element, done) { },
 *     move: function(element, done) { },
 *
 *     //animation that can be triggered before the class is added
 *     beforeAddClass: function(element, className, done) { },
 *
 *     //animation that can be triggered after the class is added
 *     addClass: function(element, className, done) { },
 *
 *     //animation that can be triggered before the class is removed
 *     beforeRemoveClass: function(element, className, done) { },
 *
 *     //animation that can be triggered after the class is removed
 *     removeClass: function(element, className, done) { }
 *   };
 * });
 * </pre>
 *
 * JavaScript-defined animations are created with a CSS-like class selector and a collection of events which are set to run
 * a javascript callback function. When an animation is triggered, $animate will look for a matching animation which fits
 * the element's CSS class attribute value and then run the matching animation event function (if found).
 * In other words, if the CSS classes present on the animated element match any of the JavaScript animations then the callback function will
 * be executed. It should be also noted that only simple, single class selectors are allowed (compound class selectors are not supported).
 *
 * Within a JavaScript animation, an object containing various event callback animation functions is expected to be returned.
 * As explained above, these callbacks are triggered based on the animation event. Therefore if an enter animation is run,
 * and the JavaScript animation is found, then the enter callback will handle that animation (in addition to the CSS keyframe animation
 * or transition code that is defined via a stylesheet).
 *
 */

angular.module('ngAnimate', ['ng'])

  /**
   * @ngdoc object
   * @name ngAnimate.$animateProvider
   * @description
   *
   * The `$animateProvider` allows developers to register JavaScript animation event handlers directly inside of a module.
   * When an animation is triggered, the $animate service will query the $animate service to find any animations that match
   * the provided name value.
   *
   * Requires the {@link ngAnimate `ngAnimate`} module to be installed.
   *
   * Please visit the {@link ngAnimate `ngAnimate`} module overview page learn more about how to use animations in your application.
   *
   */
  .factory('$$animateReflow', ['$window', '$timeout', function($window, $timeout) {
    var requestAnimationFrame = $window.requestAnimationFrame       ||
                                $window.webkitRequestAnimationFrame ||
                                function(fn) {
                                  return $timeout(fn, 10, false);
                                };

    var cancelAnimationFrame = $window.cancelAnimationFrame       ||
                               $window.webkitCancelAnimationFrame ||
                               function(timer) {
                                 return $timeout.cancel(timer);
                               };
    return function(fn) {
      var id = requestAnimationFrame(fn);
      return function() {
        cancelAnimationFrame(id);
      };
    };
  }])

  .config(['$provide', '$animateProvider', function($provide, $animateProvider) {
    var noop = angular.noop;
    var forEach = angular.forEach;
    var selectors = $animateProvider.$$selectors;

    var ELEMENT_NODE = 1;
    var NG_ANIMATE_STATE = '$$ngAnimateState';
    var NG_ANIMATE_CLASS_NAME = 'ng-animate';
    var rootAnimateState = {running: true};

    function extractElementNode(element) {
      for(var i = 0; i < element.length; i++) {
        var elm = element[i];
        if(elm.nodeType == ELEMENT_NODE) {
          return elm;
        }
      }
    }

    function isMatchingElement(elm1, elm2) {
      return extractElementNode(elm1) == extractElementNode(elm2);
    }

    $provide.decorator('$animate', ['$delegate', '$injector', '$sniffer', '$rootElement', '$timeout', '$rootScope', '$document',
                            function($delegate,   $injector,   $sniffer,   $rootElement,   $timeout,   $rootScope,   $document) {

      $rootElement.data(NG_ANIMATE_STATE, rootAnimateState);

      // disable animations during bootstrap, but once we bootstrapped, wait again
      // for another digest until enabling animations. The reason why we digest twice
      // is because all structural animations (enter, leave and move) all perform a
      // post digest operation before animating. If we only wait for a single digest
      // to pass then the structural animation would render its animation on page load.
      // (which is what we're trying to avoid when the application first boots up.)
      $rootScope.$$postDigest(function() {
        $rootScope.$$postDigest(function() {
          rootAnimateState.running = false;
        });
      });

      var classNameFilter = $animateProvider.classNameFilter();
      var isAnimatableClassName = !classNameFilter
              ? function() { return true; }
              : function(className) {
                return classNameFilter.test(className);
              };

      function async(fn) {
        return $timeout(fn, 0, false);
      }

      function lookup(name) {
        if (name) {
          var matches = [],
              flagMap = {},
              classes = name.substr(1).split('.');

          //the empty string value is the default animation
          //operation which performs CSS transition and keyframe
          //animations sniffing. This is always included for each
          //element animation procedure if the browser supports
          //transitions and/or keyframe animations
          if ($sniffer.transitions || $sniffer.animations) {
            classes.push('');
          }

          for(var i=0; i < classes.length; i++) {
            var klass = classes[i],
                selectorFactoryName = selectors[klass];
            if(selectorFactoryName && !flagMap[klass]) {
              matches.push($injector.get(selectorFactoryName));
              flagMap[klass] = true;
            }
          }
          return matches;
        }
      }

      /**
       * @ngdoc object
       * @name ngAnimate.$animate
       * @function
       *
       * @description
       * The `$animate` service provides animation detection support while performing DOM operations (enter, leave and move) as well as during addClass and removeClass operations.
       * When any of these operations are run, the $animate service
       * will examine any JavaScript-defined animations (which are defined by using the $animateProvider provider object)
       * as well as any CSS-defined animations against the CSS classes present on the element once the DOM operation is run.
       *
       * The `$animate` service is used behind the scenes with pre-existing directives and animation with these directives
       * will work out of the box without any extra configuration.
       *
       * Requires the {@link ngAnimate `ngAnimate`} module to be installed.
       *
       * Please visit the {@link ngAnimate `ngAnimate`} module overview page learn more about how to use animations in your application.
       *
       */
      return {
        /**
         * @ngdoc function
         * @name ngAnimate.$animate#enter
         * @methodOf ngAnimate.$animate
         * @function
         *
         * @description
         * Appends the element to the parentElement element that resides in the document and then runs the enter animation. Once
         * the animation is started, the following CSS classes will be present on the element for the duration of the animation:
         *
         * Below is a breakdown of each step that occurs during enter animation:
         *
         * | Animation Step                                                                               | What the element class attribute looks like |
         * |----------------------------------------------------------------------------------------------|---------------------------------------------|
         * | 1. $animate.enter(...) is called                                                             | class="my-animation"                        |
         * | 2. element is inserted into the parentElement element or beside the afterElement element     | class="my-animation"                        |
         * | 3. $animate runs any JavaScript-defined animations on the element                            | class="my-animation ng-animate"             |
         * | 4. the .ng-enter class is added to the element                                               | class="my-animation ng-animate ng-enter"    |
         * | 5. $animate scans the element styles to get the CSS transition/animation duration and delay  | class="my-animation ng-animate ng-enter"    |
         * | 6. $animate waits for 10ms (this performs a reflow)                                          | class="my-animation ng-animate ng-enter"    |
         * | 7. the .ng-enter-active and .ng-animate-active classes are added (this triggers the CSS transition/animation) | class="my-animation ng-animate ng-animate-active ng-enter ng-enter-active" |
         * | 8. $animate waits for X milliseconds for the animation to complete                           | class="my-animation ng-animate ng-animate-active ng-enter ng-enter-active" |
         * | 9. The animation ends and all generated CSS classes are removed from the element             | class="my-animation"                        |
         * | 10. The doneCallback() callback is fired (if provided)                                       | class="my-animation"                        |
         *
         * @param {jQuery/jqLite element} element the element that will be the focus of the enter animation
         * @param {jQuery/jqLite element} parentElement the parent element of the element that will be the focus of the enter animation
         * @param {jQuery/jqLite element} afterElement the sibling element (which is the previous element) of the element that will be the focus of the enter animation
         * @param {function()=} doneCallback the callback function that will be called once the animation is complete
        */
        enter : function(element, parentElement, afterElement, doneCallback) {
          this.enabled(false, element);
          $delegate.enter(element, parentElement, afterElement);
          $rootScope.$$postDigest(function() {
            performAnimation('enter', 'ng-enter', element, parentElement, afterElement, noop, doneCallback);
          });
        },

        /**
         * @ngdoc function
         * @name ngAnimate.$animate#leave
         * @methodOf ngAnimate.$animate
         * @function
         *
         * @description
         * Runs the leave animation operation and, upon completion, removes the element from the DOM. Once
         * the animation is started, the following CSS classes will be added for the duration of the animation:
         *
         * Below is a breakdown of each step that occurs during leave animation:
         *
         * | Animation Step                                                                               | What the element class attribute looks like |
         * |----------------------------------------------------------------------------------------------|---------------------------------------------|
         * | 1. $animate.leave(...) is called                                                             | class="my-animation"                        |
         * | 2. $animate runs any JavaScript-defined animations on the element                            | class="my-animation ng-animate"             |
         * | 3. the .ng-leave class is added to the element                                               | class="my-animation ng-animate ng-leave"    |
         * | 4. $animate scans the element styles to get the CSS transition/animation duration and delay  | class="my-animation ng-animate ng-leave"    |
         * | 5. $animate waits for 10ms (this performs a reflow)                                          | class="my-animation ng-animate ng-leave"    |
         * | 6. the .ng-leave-active and .ng-animate-active classes is added (this triggers the CSS transition/animation) | class="my-animation ng-animate ng-animate-active ng-leave ng-leave-active" |
         * | 7. $animate waits for X milliseconds for the animation to complete                           | class="my-animation ng-animate ng-animate-active ng-leave ng-leave-active" |
         * | 8. The animation ends and all generated CSS classes are removed from the element             | class="my-animation"                        |
         * | 9. The element is removed from the DOM                                                       | ...                                         |
         * | 10. The doneCallback() callback is fired (if provided)                                       | ...                                         |
         *
         * @param {jQuery/jqLite element} element the element that will be the focus of the leave animation
         * @param {function()=} doneCallback the callback function that will be called once the animation is complete
        */
        leave : function(element, doneCallback) {
          cancelChildAnimations(element);
          this.enabled(false, element);
          $rootScope.$$postDigest(function() {
            performAnimation('leave', 'ng-leave', element, null, null, function() {
              $delegate.leave(element);
            }, doneCallback);
          });
        },

        /**
         * @ngdoc function
         * @name ngAnimate.$animate#move
         * @methodOf ngAnimate.$animate
         * @function
         *
         * @description
         * Fires the move DOM operation. Just before the animation starts, the animate service will either append it into the parentElement container or
         * add the element directly after the afterElement element if present. Then the move animation will be run. Once
         * the animation is started, the following CSS classes will be added for the duration of the animation:
         *
         * Below is a breakdown of each step that occurs during move animation:
         *
         * | Animation Step                                                                               | What the element class attribute looks like |
         * |----------------------------------------------------------------------------------------------|---------------------------------------------|
         * | 1. $animate.move(...) is called                                                              | class="my-animation"                        |
         * | 2. element is moved into the parentElement element or beside the afterElement element        | class="my-animation"                        |
         * | 3. $animate runs any JavaScript-defined animations on the element                            | class="my-animation ng-animate"             |
         * | 4. the .ng-move class is added to the element                                                | class="my-animation ng-animate ng-move"     |
         * | 5. $animate scans the element styles to get the CSS transition/animation duration and delay  | class="my-animation ng-animate ng-move"     |
         * | 6. $animate waits for 10ms (this performs a reflow)                                          | class="my-animation ng-animate ng-move"     |
         * | 7. the .ng-move-active and .ng-animate-active classes is added (this triggers the CSS transition/animation) | class="my-animation ng-animate ng-animate-active ng-move ng-move-active" |
         * | 8. $animate waits for X milliseconds for the animation to complete                           | class="my-animation ng-animate ng-animate-active ng-move ng-move-active" |
         * | 9. The animation ends and all generated CSS classes are removed from the element             | class="my-animation"                        |
         * | 10. The doneCallback() callback is fired (if provided)                                       | class="my-animation"                        |
         *
         * @param {jQuery/jqLite element} element the element that will be the focus of the move animation
         * @param {jQuery/jqLite element} parentElement the parentElement element of the element that will be the focus of the move animation
         * @param {jQuery/jqLite element} afterElement the sibling element (which is the previous element) of the element that will be the focus of the move animation
         * @param {function()=} doneCallback the callback function that will be called once the animation is complete
        */
        move : function(element, parentElement, afterElement, doneCallback) {
          cancelChildAnimations(element);
          this.enabled(false, element);
          $delegate.move(element, parentElement, afterElement);
          $rootScope.$$postDigest(function() {
            performAnimation('move', 'ng-move', element, parentElement, afterElement, noop, doneCallback);
          });
        },

        /**
         * @ngdoc function
         * @name ngAnimate.$animate#addClass
         * @methodOf ngAnimate.$animate
         *
         * @description
         * Triggers a custom animation event based off the className variable and then attaches the className value to the element as a CSS class.
         * Unlike the other animation methods, the animate service will suffix the className value with {@type -add} in order to provide
         * the animate service the setup and active CSS classes in order to trigger the animation (this will be skipped if no CSS transitions
         * or keyframes are defined on the -add or base CSS class).
         *
         * Below is a breakdown of each step that occurs during addClass animation:
         *
         * | Animation Step                                                                                 | What the element class attribute looks like |
         * |------------------------------------------------------------------------------------------------|---------------------------------------------|
         * | 1. $animate.addClass(element, 'super') is called                                               | class="my-animation"                        |
         * | 2. $animate runs any JavaScript-defined animations on the element                              | class="my-animation ng-animate"             |
         * | 3. the .super-add class are added to the element                                               | class="my-animation ng-animate super-add"   |
         * | 4. $animate scans the element styles to get the CSS transition/animation duration and delay    | class="my-animation ng-animate super-add"   |
         * | 5. $animate waits for 10ms (this performs a reflow)                                            | class="my-animation ng-animate super-add"   |
         * | 6. the .super, .super-add-active and .ng-animate-active classes are added (this triggers the CSS transition/animation) | class="my-animation ng-animate ng-animate-active super super-add super-add-active"          |
         * | 7. $animate waits for X milliseconds for the animation to complete                             | class="my-animation super-add super-add-active"  |
         * | 8. The animation ends and all generated CSS classes are removed from the element               | class="my-animation super"                  |
         * | 9. The super class is kept on the element                                                      | class="my-animation super"                  |
         * | 10. The doneCallback() callback is fired (if provided)                                         | class="my-animation super"                  |
         *
         * @param {jQuery/jqLite element} element the element that will be animated
         * @param {string} className the CSS class that will be added to the element and then animated
         * @param {function()=} doneCallback the callback function that will be called once the animation is complete
        */
        addClass : function(element, className, doneCallback) {
          performAnimation('addClass', className, element, null, null, function() {
            $delegate.addClass(element, className);
          }, doneCallback);
        },

        /**
         * @ngdoc function
         * @name ngAnimate.$animate#removeClass
         * @methodOf ngAnimate.$animate
         *
         * @description
         * Triggers a custom animation event based off the className variable and then removes the CSS class provided by the className value
         * from the element. Unlike the other animation methods, the animate service will suffix the className value with {@type -remove} in
         * order to provide the animate service the setup and active CSS classes in order to trigger the animation (this will be skipped if
         * no CSS transitions or keyframes are defined on the -remove or base CSS classes).
         *
         * Below is a breakdown of each step that occurs during removeClass animation:
         *
         * | Animation Step                                                                                | What the element class attribute looks like     |
         * |-----------------------------------------------------------------------------------------------|---------------------------------------------|
         * | 1. $animate.removeClass(element, 'super') is called                                           | class="my-animation super"                  |
         * | 2. $animate runs any JavaScript-defined animations on the element                             | class="my-animation super ng-animate"       |
         * | 3. the .super-remove class are added to the element                                           | class="my-animation super ng-animate super-remove"|
         * | 4. $animate scans the element styles to get the CSS transition/animation duration and delay   | class="my-animation super ng-animate super-remove"   |
         * | 5. $animate waits for 10ms (this performs a reflow)                                           | class="my-animation super ng-animate super-remove"   |
         * | 6. the .super-remove-active and .ng-animate-active classes are added and .super is removed (this triggers the CSS transition/animation) | class="my-animation ng-animate ng-animate-active super-remove super-remove-active"          |
         * | 7. $animate waits for X milliseconds for the animation to complete                            | class="my-animation ng-animate ng-animate-active super-remove super-remove-active"   |
         * | 8. The animation ends and all generated CSS classes are removed from the element              | class="my-animation"                        |
         * | 9. The doneCallback() callback is fired (if provided)                                         | class="my-animation"                        |
         *
         *
         * @param {jQuery/jqLite element} element the element that will be animated
         * @param {string} className the CSS class that will be animated and then removed from the element
         * @param {function()=} doneCallback the callback function that will be called once the animation is complete
        */
        removeClass : function(element, className, doneCallback) {
          performAnimation('removeClass', className, element, null, null, function() {
            $delegate.removeClass(element, className);
          }, doneCallback);
        },

        /**
         * @ngdoc function
         * @name ngAnimate.$animate#enabled
         * @methodOf ngAnimate.$animate
         * @function
         *
         * @param {boolean=} value If provided then set the animation on or off.
         * @param {jQuery/jqLite element=} element If provided then the element will be used to represent the enable/disable operation
         * @return {boolean} Current animation state.
         *
         * @description
         * Globally enables/disables animations.
         *
        */
        enabled : function(value, element) {
          switch(arguments.length) {
            case 2:
              if(value) {
                cleanup(element);
              } else {
                var data = element.data(NG_ANIMATE_STATE) || {};
                data.disabled = true;
                element.data(NG_ANIMATE_STATE, data);
              }
            break;

            case 1:
              rootAnimateState.disabled = !value;
            break;

            default:
              value = !rootAnimateState.disabled;
            break;
          }
          return !!value;
         }
      };

      /*
        all animations call this shared animation triggering function internally.
        The animationEvent variable refers to the JavaScript animation event that will be triggered
        and the className value is the name of the animation that will be applied within the
        CSS code. Element, parentElement and afterElement are provided DOM elements for the animation
        and the onComplete callback will be fired once the animation is fully complete.
      */
      function performAnimation(animationEvent, className, element, parentElement, afterElement, domOperation, doneCallback) {
        var currentClassName, classes, node = extractElementNode(element);
        if(node) {
          currentClassName = node.className;
          classes = currentClassName + ' ' + className;
        }

        //transcluded directives may sometimes fire an animation using only comment nodes
        //best to catch this early on to prevent any animation operations from occurring
        if(!node || !isAnimatableClassName(classes)) {
          fireDOMOperation();
          fireBeforeCallbackAsync();
          fireAfterCallbackAsync();
          closeAnimation();
          return;
        }

        var animationLookup = (' ' + classes).replace(/\s+/g,'.');
        if (!parentElement) {
          parentElement = afterElement ? afterElement.parent() : element.parent();
        }

        var matches = lookup(animationLookup);
        var isClassBased = animationEvent == 'addClass' || animationEvent == 'removeClass';
        var ngAnimateState = element.data(NG_ANIMATE_STATE) || {};

        //skip the animation if animations are disabled, a parent is already being animated,
        //the element is not currently attached to the document body or then completely close
        //the animation if any matching animations are not found at all.
        //NOTE: IE8 + IE9 should close properly (run closeAnimation()) in case a NO animation is not found.
        if (animationsDisabled(element, parentElement) || matches.length === 0) {
          fireDOMOperation();
          fireBeforeCallbackAsync();
          fireAfterCallbackAsync();
          closeAnimation();
          return;
        }

        var animations = [];

        //only add animations if the currently running animation is not structural
        //or if there is no animation running at all
        var allowAnimations = isClassBased ?
          !ngAnimateState.disabled && (!ngAnimateState.running || !ngAnimateState.structural) :
          true;

        if(allowAnimations) {
          forEach(matches, function(animation) {
            //add the animation to the queue to if it is allowed to be cancelled
            if(!animation.allowCancel || animation.allowCancel(element, animationEvent, className)) {
              var beforeFn, afterFn = animation[animationEvent];

              //Special case for a leave animation since there is no point in performing an
              //animation on a element node that has already been removed from the DOM
              if(animationEvent == 'leave') {
                beforeFn = afterFn;
                afterFn = null; //this must be falsy so that the animation is skipped for leave
              } else {
                beforeFn = animation['before' + animationEvent.charAt(0).toUpperCase() + animationEvent.substr(1)];
              }
              animations.push({
                before : beforeFn,
                after : afterFn
              });
            }
          });
        }

        //this would mean that an animation was not allowed so let the existing
        //animation do it's thing and close this one early
        if(animations.length === 0) {
          fireDOMOperation();
          fireBeforeCallbackAsync();
          fireAfterCallbackAsync();
          fireDoneCallbackAsync();
          return;
        }

        var ONE_SPACE = ' ';
        //this value will be searched for class-based CSS className lookup. Therefore,
        //we prefix and suffix the current className value with spaces to avoid substring
        //lookups of className tokens
        var futureClassName = ONE_SPACE + currentClassName + ONE_SPACE;
        if(ngAnimateState.running) {
          //if an animation is currently running on the element then lets take the steps
          //to cancel that animation and fire any required callbacks
          $timeout.cancel(ngAnimateState.closeAnimationTimeout);
          cleanup(element);
          cancelAnimations(ngAnimateState.animations);

          //in the event that the CSS is class is quickly added and removed back
          //then we don't want to wait until after the reflow to add/remove the CSS
          //class since both class animations may run into a race condition.
          //The code below will check to see if that is occurring and will
          //immediately remove the former class before the reflow so that the
          //animation can snap back to the original animation smoothly
          var isFullyClassBasedAnimation = isClassBased && !ngAnimateState.structural;
          var isRevertingClassAnimation = isFullyClassBasedAnimation &&
                                          ngAnimateState.className == className &&
                                          animationEvent != ngAnimateState.event;

          //if the class is removed during the reflow then it will revert the styles temporarily
          //back to the base class CSS styling causing a jump-like effect to occur. This check
          //here ensures that the domOperation is only performed after the reflow has commenced
          if(ngAnimateState.beforeComplete || isRevertingClassAnimation) {
            (ngAnimateState.done || noop)(true);
          } else if(isFullyClassBasedAnimation) {
            //class-based animations will compare element className values after cancelling the
            //previous animation to see if the element properties already contain the final CSS
            //class and if so then the animation will be skipped. Since the domOperation will
            //be performed only after the reflow is complete then our element's className value
            //will be invalid. Therefore the same string manipulation that would occur within the
            //DOM operation will be performed below so that the class comparison is valid...
            futureClassName = ngAnimateState.event == 'removeClass' ?
              futureClassName.replace(ONE_SPACE + ngAnimateState.className + ONE_SPACE, ONE_SPACE) :
              futureClassName + ngAnimateState.className + ONE_SPACE;
          }
        }

        //There is no point in perform a class-based animation if the element already contains
        //(on addClass) or doesn't contain (on removeClass) the className being animated.
        //The reason why this is being called after the previous animations are cancelled
        //is so that the CSS classes present on the element can be properly examined.
        var classNameToken = ONE_SPACE + className + ONE_SPACE;
        if((animationEvent == 'addClass'    && futureClassName.indexOf(classNameToken) >= 0) ||
           (animationEvent == 'removeClass' && futureClassName.indexOf(classNameToken) == -1)) {
          fireDOMOperation();
          fireBeforeCallbackAsync();
          fireAfterCallbackAsync();
          fireDoneCallbackAsync();
          return;
        }

        //the ng-animate class does nothing, but it's here to allow for
        //parent animations to find and cancel child animations when needed
        element.addClass(NG_ANIMATE_CLASS_NAME);

        element.data(NG_ANIMATE_STATE, {
          running:true,
          event:animationEvent,
          className:className,
          structural:!isClassBased,
          animations:animations,
          done:onBeforeAnimationsComplete
        });

        //first we run the before animations and when all of those are complete
        //then we perform the DOM operation and run the next set of animations
        invokeRegisteredAnimationFns(animations, 'before', onBeforeAnimationsComplete);

        function onBeforeAnimationsComplete(cancelled) {
          fireDOMOperation();
          if(cancelled === true) {
            closeAnimation();
            return;
          }

          //set the done function to the final done function
          //so that the DOM event won't be executed twice by accident
          //if the after animation is cancelled as well
          var data = element.data(NG_ANIMATE_STATE);
          if(data) {
            data.done = closeAnimation;
            element.data(NG_ANIMATE_STATE, data);
          }
          invokeRegisteredAnimationFns(animations, 'after', closeAnimation);
        }

        function invokeRegisteredAnimationFns(animations, phase, allAnimationFnsComplete) {
          phase == 'after' ?
            fireAfterCallbackAsync() :
            fireBeforeCallbackAsync();

          var endFnName = phase + 'End';
          forEach(animations, function(animation, index) {
            var animationPhaseCompleted = function() {
              progress(index, phase);
            };

            //there are no before functions for enter + move since the DOM
            //operations happen before the performAnimation method fires
            if(phase == 'before' && (animationEvent == 'enter' || animationEvent == 'move')) {
              animationPhaseCompleted();
              return;
            }

            if(animation[phase]) {
              animation[endFnName] = isClassBased ?
                animation[phase](element, className, animationPhaseCompleted) :
                animation[phase](element, animationPhaseCompleted);
            } else {
              animationPhaseCompleted();
            }
          });

          function progress(index, phase) {
            var phaseCompletionFlag = phase + 'Complete';
            var currentAnimation = animations[index];
            currentAnimation[phaseCompletionFlag] = true;
            (currentAnimation[endFnName] || noop)();

            for(var i=0;i<animations.length;i++) {
              if(!animations[i][phaseCompletionFlag]) return;
            }

            allAnimationFnsComplete();
          }
        }

        function fireDOMCallback(animationPhase) {
          element.triggerHandler('$animate:' + animationPhase, {
            event : animationEvent,
            className : className
          });
        }

        function fireBeforeCallbackAsync() {
          async(function() {
            fireDOMCallback('before');
          });
        }

        function fireAfterCallbackAsync() {
          async(function() {
            fireDOMCallback('after');
          });
        }

        function fireDoneCallbackAsync() {
          async(function() {
            fireDOMCallback('close');
            doneCallback && doneCallback();
          });
        }

        //it is less complicated to use a flag than managing and cancelling
        //timeouts containing multiple callbacks.
        function fireDOMOperation() {
          if(!fireDOMOperation.hasBeenRun) {
            fireDOMOperation.hasBeenRun = true;
            domOperation();
          }
        }

        function closeAnimation() {
          if(!closeAnimation.hasBeenRun) {
            closeAnimation.hasBeenRun = true;
            var data = element.data(NG_ANIMATE_STATE);
            if(data) {
              /* only structural animations wait for reflow before removing an
                 animation, but class-based animations don't. An example of this
                 failing would be when a parent HTML tag has a ng-class attribute
                 causing ALL directives below to skip animations during the digest */
              if(isClassBased) {
                cleanup(element);
              } else {
                data.closeAnimationTimeout = async(function() {
                  cleanup(element);
                });
                element.data(NG_ANIMATE_STATE, data);
              }
            }
            fireDoneCallbackAsync();
          }
        }
      }

      function cancelChildAnimations(element) {
        var node = extractElementNode(element);
        forEach(node.querySelectorAll('.' + NG_ANIMATE_CLASS_NAME), function(element) {
          element = angular.element(element);
          var data = element.data(NG_ANIMATE_STATE);
          if(data) {
            cancelAnimations(data.animations);
            cleanup(element);
          }
        });
      }

      function cancelAnimations(animations) {
        var isCancelledFlag = true;
        forEach(animations, function(animation) {
          if(!animation.beforeComplete) {
            (animation.beforeEnd || noop)(isCancelledFlag);
          }
          if(!animation.afterComplete) {
            (animation.afterEnd || noop)(isCancelledFlag);
          }
        });
      }

      function cleanup(element) {
        if(isMatchingElement(element, $rootElement)) {
          if(!rootAnimateState.disabled) {
            rootAnimateState.running = false;
            rootAnimateState.structural = false;
          }
        } else {
          element.removeClass(NG_ANIMATE_CLASS_NAME);
          element.removeData(NG_ANIMATE_STATE);
        }
      }

      function animationsDisabled(element, parentElement) {
        if (rootAnimateState.disabled) return true;

        if(isMatchingElement(element, $rootElement)) {
          return rootAnimateState.disabled || rootAnimateState.running;
        }

        do {
          //the element did not reach the root element which means that it
          //is not apart of the DOM. Therefore there is no reason to do
          //any animations on it
          if(parentElement.length === 0) break;

          var isRoot = isMatchingElement(parentElement, $rootElement);
          var state = isRoot ? rootAnimateState : parentElement.data(NG_ANIMATE_STATE);
          var result = state && (!!state.disabled || !!state.running);
          if(isRoot || result) {
            return result;
          }

          if(isRoot) return true;
        }
        while(parentElement = parentElement.parent());

        return true;
      }
    }]);

    $animateProvider.register('', ['$window', '$sniffer', '$timeout', '$$animateReflow',
                           function($window,   $sniffer,   $timeout,   $$animateReflow) {
      // Detect proper transitionend/animationend event names.
      var CSS_PREFIX = '', TRANSITION_PROP, TRANSITIONEND_EVENT, ANIMATION_PROP, ANIMATIONEND_EVENT;

      // If unprefixed events are not supported but webkit-prefixed are, use the latter.
      // Otherwise, just use W3C names, browsers not supporting them at all will just ignore them.
      // Note: Chrome implements `window.onwebkitanimationend` and doesn't implement `window.onanimationend`
      // but at the same time dispatches the `animationend` event and not `webkitAnimationEnd`.
      // Register both events in case `window.onanimationend` is not supported because of that,
      // do the same for `transitionend` as Safari is likely to exhibit similar behavior.
      // Also, the only modern browser that uses vendor prefixes for transitions/keyframes is webkit
      // therefore there is no reason to test anymore for other vendor prefixes: http://caniuse.com/#search=transition
      if (window.ontransitionend === undefined && window.onwebkittransitionend !== undefined) {
        CSS_PREFIX = '-webkit-';
        TRANSITION_PROP = 'WebkitTransition';
        TRANSITIONEND_EVENT = 'webkitTransitionEnd transitionend';
      } else {
        TRANSITION_PROP = 'transition';
        TRANSITIONEND_EVENT = 'transitionend';
      }

      if (window.onanimationend === undefined && window.onwebkitanimationend !== undefined) {
        CSS_PREFIX = '-webkit-';
        ANIMATION_PROP = 'WebkitAnimation';
        ANIMATIONEND_EVENT = 'webkitAnimationEnd animationend';
      } else {
        ANIMATION_PROP = 'animation';
        ANIMATIONEND_EVENT = 'animationend';
      }

      var DURATION_KEY = 'Duration';
      var PROPERTY_KEY = 'Property';
      var DELAY_KEY = 'Delay';
      var ANIMATION_ITERATION_COUNT_KEY = 'IterationCount';
      var NG_ANIMATE_PARENT_KEY = '$$ngAnimateKey';
      var NG_ANIMATE_CSS_DATA_KEY = '$$ngAnimateCSS3Data';
      var ELAPSED_TIME_MAX_DECIMAL_PLACES = 3;
      var CLOSING_TIME_BUFFER = 1.5;
      var ONE_SECOND = 1000;

      var animationCounter = 0;
      var lookupCache = {};
      var parentCounter = 0;
      var animationReflowQueue = [];
      var animationElementQueue = [];
      var cancelAnimationReflow;
      var closingAnimationTime = 0;
      var timeOut = false;
      function afterReflow(element, callback) {
        if(cancelAnimationReflow) {
          cancelAnimationReflow();
        }

        animationReflowQueue.push(callback);

        var node = extractElementNode(element);
        element = angular.element(node);
        animationElementQueue.push(element);

        var elementData = element.data(NG_ANIMATE_CSS_DATA_KEY);

        var stagger = elementData.stagger;
        var staggerTime = elementData.itemIndex * (Math.max(stagger.animationDelay, stagger.transitionDelay) || 0);

        var animationTime = (elementData.maxDelay + elementData.maxDuration) * CLOSING_TIME_BUFFER;
        closingAnimationTime = Math.max(closingAnimationTime, (staggerTime + animationTime) * ONE_SECOND);

        //by placing a counter we can avoid an accidental
        //race condition which may close an animation when
        //a follow-up animation is midway in its animation
        elementData.animationCount = animationCounter;

        cancelAnimationReflow = $$animateReflow(function() {
          forEach(animationReflowQueue, function(fn) {
            fn();
          });

          //copy the list of elements so that successive
          //animations won't conflict if they're added before
          //the closing animation timeout has run
          var elementQueueSnapshot = [];
          var animationCounterSnapshot = animationCounter;
          forEach(animationElementQueue, function(elm) {
            elementQueueSnapshot.push(elm);
          });

          $timeout(function() {
            closeAllAnimations(elementQueueSnapshot, animationCounterSnapshot);
            elementQueueSnapshot = null;
          }, closingAnimationTime, false);

          animationReflowQueue = [];
          animationElementQueue = [];
          cancelAnimationReflow = null;
          lookupCache = {};
          closingAnimationTime = 0;
          animationCounter++;
        });
      }

      function closeAllAnimations(elements, count) {
        forEach(elements, function(element) {
          var elementData = element.data(NG_ANIMATE_CSS_DATA_KEY);
          if(elementData && elementData.animationCount == count) {
            (elementData.closeAnimationFn || noop)();
          }
        });
      }

      function getElementAnimationDetails(element, cacheKey) {
        var data = cacheKey ? lookupCache[cacheKey] : null;
        if(!data) {
          var transitionDuration = 0;
          var transitionDelay = 0;
          var animationDuration = 0;
          var animationDelay = 0;
          var transitionDelayStyle;
          var animationDelayStyle;
          var transitionDurationStyle;
          var transitionPropertyStyle;

          //we want all the styles defined before and after
          forEach(element, function(element) {
            if (element.nodeType == ELEMENT_NODE) {
              var elementStyles = $window.getComputedStyle(element) || {};

              transitionDurationStyle = elementStyles[TRANSITION_PROP + DURATION_KEY];

              transitionDuration = Math.max(parseMaxTime(transitionDurationStyle), transitionDuration);

              transitionPropertyStyle = elementStyles[TRANSITION_PROP + PROPERTY_KEY];

              transitionDelayStyle = elementStyles[TRANSITION_PROP + DELAY_KEY];

              transitionDelay  = Math.max(parseMaxTime(transitionDelayStyle), transitionDelay);

              animationDelayStyle = elementStyles[ANIMATION_PROP + DELAY_KEY];

              animationDelay   = Math.max(parseMaxTime(animationDelayStyle), animationDelay);

              var aDuration  = parseMaxTime(elementStyles[ANIMATION_PROP + DURATION_KEY]);

              if(aDuration > 0) {
                aDuration *= parseInt(elementStyles[ANIMATION_PROP + ANIMATION_ITERATION_COUNT_KEY], 10) || 1;
              }

              animationDuration = Math.max(aDuration, animationDuration);
            }
          });
          data = {
            total : 0,
            transitionPropertyStyle: transitionPropertyStyle,
            transitionDurationStyle: transitionDurationStyle,
            transitionDelayStyle: transitionDelayStyle,
            transitionDelay: transitionDelay,
            transitionDuration: transitionDuration,
            animationDelayStyle: animationDelayStyle,
            animationDelay: animationDelay,
            animationDuration: animationDuration
          };
          if(cacheKey) {
            lookupCache[cacheKey] = data;
          }
        }
        return data;
      }

      function parseMaxTime(str) {
        var maxValue = 0;
        var values = angular.isString(str) ?
          str.split(/\s*,\s*/) :
          [];
        forEach(values, function(value) {
          maxValue = Math.max(parseFloat(value) || 0, maxValue);
        });
        return maxValue;
      }

      function getCacheKey(element) {
        var parentElement = element.parent();
        var parentID = parentElement.data(NG_ANIMATE_PARENT_KEY);
        if(!parentID) {
          parentElement.data(NG_ANIMATE_PARENT_KEY, ++parentCounter);
          parentID = parentCounter;
        }
        return parentID + '-' + extractElementNode(element).className;
      }

      function animateSetup(element, className, calculationDecorator) {
        var cacheKey = getCacheKey(element);
        var eventCacheKey = cacheKey + ' ' + className;
        var stagger = {};
        var itemIndex = lookupCache[eventCacheKey] ? ++lookupCache[eventCacheKey].total : 0;

        if(itemIndex > 0) {
          var staggerClassName = className + '-stagger';
          var staggerCacheKey = cacheKey + ' ' + staggerClassName;
          var applyClasses = !lookupCache[staggerCacheKey];

          applyClasses && element.addClass(staggerClassName);

          stagger = getElementAnimationDetails(element, staggerCacheKey);

          applyClasses && element.removeClass(staggerClassName);
        }

        /* the animation itself may need to add/remove special CSS classes
         * before calculating the anmation styles */
        calculationDecorator = calculationDecorator ||
                               function(fn) { return fn(); };

        element.addClass(className);

        var timings = calculationDecorator(function() {
          return getElementAnimationDetails(element, eventCacheKey);
        });

        /* there is no point in performing a reflow if the animation
           timeout is empty (this would cause a flicker bug normally
           in the page. There is also no point in performing an animation
           that only has a delay and no duration */
        var maxDelay = Math.max(timings.transitionDelay, timings.animationDelay);
        var maxDuration = Math.max(timings.transitionDuration, timings.animationDuration);
        if(maxDuration === 0) {
          element.removeClass(className);
          return false;
        }

        //temporarily disable the transition so that the enter styles
        //don't animate twice (this is here to avoid a bug in Chrome/FF).
        var activeClassName = '';
        timings.transitionDuration > 0 ?
          blockTransitions(element) :
          blockKeyframeAnimations(element);

        forEach(className.split(' '), function(klass, i) {
          activeClassName += (i > 0 ? ' ' : '') + klass + '-active';
        });

        element.data(NG_ANIMATE_CSS_DATA_KEY, {
          className : className,
          activeClassName : activeClassName,
          maxDuration : maxDuration,
          maxDelay : maxDelay,
          classes : className + ' ' + activeClassName,
          timings : timings,
          stagger : stagger,
          itemIndex : itemIndex
        });

        return true;
      }

      function blockTransitions(element) {
        extractElementNode(element).style[TRANSITION_PROP + PROPERTY_KEY] = 'none';
      }

      function blockKeyframeAnimations(element) {
        extractElementNode(element).style[ANIMATION_PROP] = 'none 0s';
      }

      function unblockTransitions(element) {
        var prop = TRANSITION_PROP + PROPERTY_KEY;
        var node = extractElementNode(element);
        if(node.style[prop] && node.style[prop].length > 0) {
          node.style[prop] = '';
        }
      }

      function unblockKeyframeAnimations(element) {
        var prop = ANIMATION_PROP;
        var node = extractElementNode(element);
        if(node.style[prop] && node.style[prop].length > 0) {
          node.style[prop] = '';
        }
      }

      function animateRun(element, className, activeAnimationComplete) {
        var elementData = element.data(NG_ANIMATE_CSS_DATA_KEY);
        var node = extractElementNode(element);
        if(node.className.indexOf(className) == -1 || !elementData) {
          activeAnimationComplete();
          return;
        }

        var timings = elementData.timings;
        var stagger = elementData.stagger;
        var maxDuration = elementData.maxDuration;
        var activeClassName = elementData.activeClassName;
        var maxDelayTime = Math.max(timings.transitionDelay, timings.animationDelay) * ONE_SECOND;
        var startTime = Date.now();
        var css3AnimationEvents = ANIMATIONEND_EVENT + ' ' + TRANSITIONEND_EVENT;
        var itemIndex = elementData.itemIndex;

        var style = '', appliedStyles = [];
        if(timings.transitionDuration > 0) {
          var propertyStyle = timings.transitionPropertyStyle;
          if(propertyStyle.indexOf('all') == -1) {
            style += CSS_PREFIX + 'transition-property: ' + propertyStyle + ';';
            style += CSS_PREFIX + 'transition-duration: ' + timings.transitionDurationStyle + ';';
            appliedStyles.push(CSS_PREFIX + 'transition-property');
            appliedStyles.push(CSS_PREFIX + 'transition-duration');
          }
        }

        if(itemIndex > 0) {
          if(stagger.transitionDelay > 0 && stagger.transitionDuration === 0) {
            var delayStyle = timings.transitionDelayStyle;
            style += CSS_PREFIX + 'transition-delay: ' +
                     prepareStaggerDelay(delayStyle, stagger.transitionDelay, itemIndex) + '; ';
            appliedStyles.push(CSS_PREFIX + 'transition-delay');
          }

          if(stagger.animationDelay > 0 && stagger.animationDuration === 0) {
            style += CSS_PREFIX + 'animation-delay: ' +
                     prepareStaggerDelay(timings.animationDelayStyle, stagger.animationDelay, itemIndex) + '; ';
            appliedStyles.push(CSS_PREFIX + 'animation-delay');
          }
        }

        if(appliedStyles.length > 0) {
          //the element being animated may sometimes contain comment nodes in
          //the jqLite object, so we're safe to use a single variable to house
          //the styles since there is always only one element being animated
          var oldStyle = node.getAttribute('style') || '';
          node.setAttribute('style', oldStyle + ' ' + style);
        }

        element.on(css3AnimationEvents, onAnimationProgress);
        element.addClass(activeClassName);
        elementData.closeAnimationFn = function() {
          onEnd();
          activeAnimationComplete();
        };
        return onEnd;

        // This will automatically be called by $animate so
        // there is no need to attach this internally to the
        // timeout done method.
        function onEnd(cancelled) {
          element.off(css3AnimationEvents, onAnimationProgress);
          element.removeClass(activeClassName);
          animateClose(element, className);
          var node = extractElementNode(element);
          for (var i in appliedStyles) {
            node.style.removeProperty(appliedStyles[i]);
          }
        }

        function onAnimationProgress(event) {
          event.stopPropagation();
          var ev = event.originalEvent || event;
          var timeStamp = ev.$manualTimeStamp || ev.timeStamp || Date.now();
          
          /* Firefox (or possibly just Gecko) likes to not round values up
           * when a ms measurement is used for the animation */
          var elapsedTime = parseFloat(ev.elapsedTime.toFixed(ELAPSED_TIME_MAX_DECIMAL_PLACES));

          /* $manualTimeStamp is a mocked timeStamp value which is set
           * within browserTrigger(). This is only here so that tests can
           * mock animations properly. Real events fallback to event.timeStamp,
           * or, if they don't, then a timeStamp is automatically created for them.
           * We're checking to see if the timeStamp surpasses the expected delay,
           * but we're using elapsedTime instead of the timeStamp on the 2nd
           * pre-condition since animations sometimes close off early */
          if(Math.max(timeStamp - startTime, 0) >= maxDelayTime && elapsedTime >= maxDuration) {
            activeAnimationComplete();
          }
        }
      }

      function prepareStaggerDelay(delayStyle, staggerDelay, index) {
        var style = '';
        forEach(delayStyle.split(','), function(val, i) {
          style += (i > 0 ? ',' : '') +
                   (index * staggerDelay + parseInt(val, 10)) + 's';
        });
        return style;
      }

      function animateBefore(element, className, calculationDecorator) {
        if(animateSetup(element, className, calculationDecorator)) {
          return function(cancelled) {
            cancelled && animateClose(element, className);
          };
        }
      }

      function animateAfter(element, className, afterAnimationComplete) {
        if(element.data(NG_ANIMATE_CSS_DATA_KEY)) {
          return animateRun(element, className, afterAnimationComplete);
        } else {
          animateClose(element, className);
          afterAnimationComplete();
        }
      }

      function animate(element, className, animationComplete) {
        //If the animateSetup function doesn't bother returning a
        //cancellation function then it means that there is no animation
        //to perform at all
        var preReflowCancellation = animateBefore(element, className);
        if(!preReflowCancellation) {
          animationComplete();
          return;
        }

        //There are two cancellation functions: one is before the first
        //reflow animation and the second is during the active state
        //animation. The first function will take care of removing the
        //data from the element which will not make the 2nd animation
        //happen in the first place
        var cancel = preReflowCancellation;
        afterReflow(element, function() {
          unblockTransitions(element);
          unblockKeyframeAnimations(element);
          //once the reflow is complete then we point cancel to
          //the new cancellation function which will remove all of the
          //animation properties from the active animation
          cancel = animateAfter(element, className, animationComplete);
        });

        return function(cancelled) {
          (cancel || noop)(cancelled);
        };
      }

      function animateClose(element, className) {
        element.removeClass(className);
        element.removeData(NG_ANIMATE_CSS_DATA_KEY);
      }

      return {
        allowCancel : function(element, animationEvent, className) {
          //always cancel the current animation if it is a
          //structural animation
          var oldClasses = (element.data(NG_ANIMATE_CSS_DATA_KEY) || {}).classes;
          if(!oldClasses || ['enter','leave','move'].indexOf(animationEvent) >= 0) {
            return true;
          }

          var parentElement = element.parent();
          var clone = angular.element(extractElementNode(element).cloneNode());

          //make the element super hidden and override any CSS style values
          clone.attr('style','position:absolute; top:-9999px; left:-9999px');
          clone.removeAttr('id');
          clone.empty();

          forEach(oldClasses.split(' '), function(klass) {
            clone.removeClass(klass);
          });

          var suffix = animationEvent == 'addClass' ? '-add' : '-remove';
          clone.addClass(suffixClasses(className, suffix));
          parentElement.append(clone);

          var timings = getElementAnimationDetails(clone);
          clone.remove();

          return Math.max(timings.transitionDuration, timings.animationDuration) > 0;
        },

        enter : function(element, animationCompleted) {
          return animate(element, 'ng-enter', animationCompleted);
        },

        leave : function(element, animationCompleted) {
          return animate(element, 'ng-leave', animationCompleted);
        },

        move : function(element, animationCompleted) {
          return animate(element, 'ng-move', animationCompleted);
        },

        beforeAddClass : function(element, className, animationCompleted) {
          var cancellationMethod = animateBefore(element, suffixClasses(className, '-add'), function(fn) {

            /* when a CSS class is added to an element then the transition style that
             * is applied is the transition defined on the element when the CSS class
             * is added at the time of the animation. This is how CSS3 functions
             * outside of ngAnimate. */
            element.addClass(className);
            var timings = fn();
            element.removeClass(className);
            return timings;
          });

          if(cancellationMethod) {
            afterReflow(element, function() {
              unblockTransitions(element);
              unblockKeyframeAnimations(element);
              animationCompleted();
            });
            return cancellationMethod;
          }
          animationCompleted();
        },

        addClass : function(element, className, animationCompleted) {
          return animateAfter(element, suffixClasses(className, '-add'), animationCompleted);
        },

        beforeRemoveClass : function(element, className, animationCompleted) {
          var cancellationMethod = animateBefore(element, suffixClasses(className, '-remove'), function(fn) {
            /* when classes are removed from an element then the transition style
             * that is applied is the transition defined on the element without the
             * CSS class being there. This is how CSS3 functions outside of ngAnimate.
             * http://plnkr.co/edit/j8OzgTNxHTb4n3zLyjGW?p=preview */
            var klass = element.attr('class');
            element.removeClass(className);
            var timings = fn();
            element.attr('class', klass);
            return timings;
          });

          if(cancellationMethod) {
            afterReflow(element, function() {
              unblockTransitions(element);
              unblockKeyframeAnimations(element);
              animationCompleted();
            });
            return cancellationMethod;
          }
          animationCompleted();
        },

        removeClass : function(element, className, animationCompleted) {
          return animateAfter(element, suffixClasses(className, '-remove'), animationCompleted);
        }
      };

      function suffixClasses(classes, suffix) {
        var className = '';
        classes = angular.isArray(classes) ? classes : classes.split(/\s+/);
        forEach(classes, function(klass, i) {
          if(klass && klass.length > 0) {
            className += (i > 0 ? ' ' : '') + klass + suffix;
          }
        });
        return className;
      }
    }]);
  }]);


})(window, window.angular);

},{}],75:[function(require,module,exports){
/**
 * State-based routing for AngularJS
 * @version v0.2.7
 * @link http://angular-ui.github.com/
 * @license MIT License, http://www.opensource.org/licenses/MIT
 */

/* commonjs package manager support (eg componentjs) */
if (typeof module !== "undefined" && typeof exports !== "undefined" && module.exports === exports){
  module.exports = 'ui.router';
}

(function (window, angular, undefined) {
/*jshint globalstrict:true*/
/*global angular:false*/
'use strict';

var isDefined = angular.isDefined,
    isFunction = angular.isFunction,
    isString = angular.isString,
    isObject = angular.isObject,
    isArray = angular.isArray,
    forEach = angular.forEach,
    extend = angular.extend,
    copy = angular.copy;

function inherit(parent, extra) {
  return extend(new (extend(function() {}, { prototype: parent }))(), extra);
}

function merge(dst) {
  forEach(arguments, function(obj) {
    if (obj !== dst) {
      forEach(obj, function(value, key) {
        if (!dst.hasOwnProperty(key)) dst[key] = value;
      });
    }
  });
  return dst;
}

/**
 * Finds the common ancestor path between two states.
 *
 * @param {Object} first The first state.
 * @param {Object} second The second state.
 * @return {Array} Returns an array of state names in descending order, not including the root.
 */
function ancestors(first, second) {
  var path = [];

  for (var n in first.path) {
    if (first.path[n] === "") continue;
    if (!second.path[n]) break;
    path.push(first.path[n]);
  }
  return path;
}

/**
 * IE8-safe wrapper for `Object.keys()`.
 *
 * @param {Object} object A JavaScript object.
 * @return {Array} Returns the keys of the object as an array.
 */
function keys(object) {
  if (Object.keys) {
    return Object.keys(object);
  }
  var result = [];

  angular.forEach(object, function(val, key) {
    result.push(key);
  });
  return result;
}

/**
 * IE8-safe wrapper for `Array.prototype.indexOf()`.
 *
 * @param {Array} array A JavaScript array.
 * @param {*} value A value to search the array for.
 * @return {Number} Returns the array index value of `value`, or `-1` if not present.
 */
function arraySearch(array, value) {
  if (Array.prototype.indexOf) {
    return array.indexOf(value, Number(arguments[2]) || 0);
  }
  var len = array.length >>> 0, from = Number(arguments[2]) || 0;
  from = (from < 0) ? Math.ceil(from) : Math.floor(from);

  if (from < 0) from += len;

  for (; from < len; from++) {
    if (from in array && array[from] === value) return from;
  }
  return -1;
}

/**
 * Merges a set of parameters with all parameters inherited between the common parents of the
 * current state and a given destination state.
 *
 * @param {Object} currentParams The value of the current state parameters ($stateParams).
 * @param {Object} newParams The set of parameters which will be composited with inherited params.
 * @param {Object} $current Internal definition of object representing the current state.
 * @param {Object} $to Internal definition of object representing state to transition to.
 */
function inheritParams(currentParams, newParams, $current, $to) {
  var parents = ancestors($current, $to), parentParams, inherited = {}, inheritList = [];

  for (var i in parents) {
    if (!parents[i].params || !parents[i].params.length) continue;
    parentParams = parents[i].params;

    for (var j in parentParams) {
      if (arraySearch(inheritList, parentParams[j]) >= 0) continue;
      inheritList.push(parentParams[j]);
      inherited[parentParams[j]] = currentParams[parentParams[j]];
    }
  }
  return extend({}, inherited, newParams);
}

/**
 * Normalizes a set of values to string or `null`, filtering them by a list of keys.
 *
 * @param {Array} keys The list of keys to normalize/return.
 * @param {Object} values An object hash of values to normalize.
 * @return {Object} Returns an object hash of normalized string values.
 */
function normalize(keys, values) {
  var normalized = {};

  forEach(keys, function (name) {
    var value = values[name];
    normalized[name] = (value != null) ? String(value) : null;
  });
  return normalized;
}

/**
 * Performs a non-strict comparison of the subset of two objects, defined by a list of keys.
 *
 * @param {Object} a The first object.
 * @param {Object} b The second object.
 * @param {Array} keys The list of keys within each object to compare. If the list is empty or not specified,
 *                     it defaults to the list of keys in `a`.
 * @return {Boolean} Returns `true` if the keys match, otherwise `false`.
 */
function equalForKeys(a, b, keys) {
  if (!keys) {
    keys = [];
    for (var n in a) keys.push(n); // Used instead of Object.keys() for IE8 compatibility
  }

  for (var i=0; i<keys.length; i++) {
    var k = keys[i];
    if (a[k] != b[k]) return false; // Not '===', values aren't necessarily normalized
  }
  return true;
}

/**
 * Returns the subset of an object, based on a list of keys.
 *
 * @param {Array} keys
 * @param {Object} values
 * @return {Boolean} Returns a subset of `values`.
 */
function filterByKeys(keys, values) {
  var filtered = {};

  forEach(keys, function (name) {
    filtered[name] = values[name];
  });
  return filtered;
}

angular.module('ui.router.util', ['ng']);
angular.module('ui.router.router', ['ui.router.util']);
angular.module('ui.router.state', ['ui.router.router', 'ui.router.util']);
angular.module('ui.router', ['ui.router.state']);
angular.module('ui.router.compat', ['ui.router']);


/**
 * Service (`ui-util`). Manages resolution of (acyclic) graphs of promises.
 * @module $resolve
 * @requires $q
 * @requires $injector
 */
$Resolve.$inject = ['$q', '$injector'];
function $Resolve(  $q,    $injector) {
  
  var VISIT_IN_PROGRESS = 1,
      VISIT_DONE = 2,
      NOTHING = {},
      NO_DEPENDENCIES = [],
      NO_LOCALS = NOTHING,
      NO_PARENT = extend($q.when(NOTHING), { $$promises: NOTHING, $$values: NOTHING });
  

  /**
   * Studies a set of invocables that are likely to be used multiple times.
   *      $resolve.study(invocables)(locals, parent, self)
   * is equivalent to
   *      $resolve.resolve(invocables, locals, parent, self)
   * but the former is more efficient (in fact `resolve` just calls `study` internally).
   * See {@link module:$resolve/resolve} for details.
   * @function
   * @param {Object} invocables
   * @return {Function}
   */
  this.study = function (invocables) {
    if (!isObject(invocables)) throw new Error("'invocables' must be an object");
    
    // Perform a topological sort of invocables to build an ordered plan
    var plan = [], cycle = [], visited = {};
    function visit(value, key) {
      if (visited[key] === VISIT_DONE) return;
      
      cycle.push(key);
      if (visited[key] === VISIT_IN_PROGRESS) {
        cycle.splice(0, cycle.indexOf(key));
        throw new Error("Cyclic dependency: " + cycle.join(" -> "));
      }
      visited[key] = VISIT_IN_PROGRESS;
      
      if (isString(value)) {
        plan.push(key, [ function() { return $injector.get(value); }], NO_DEPENDENCIES);
      } else {
        var params = $injector.annotate(value);
        forEach(params, function (param) {
          if (param !== key && invocables.hasOwnProperty(param)) visit(invocables[param], param);
        });
        plan.push(key, value, params);
      }
      
      cycle.pop();
      visited[key] = VISIT_DONE;
    }
    forEach(invocables, visit);
    invocables = cycle = visited = null; // plan is all that's required
    
    function isResolve(value) {
      return isObject(value) && value.then && value.$$promises;
    }
    
    return function (locals, parent, self) {
      if (isResolve(locals) && self === undefined) {
        self = parent; parent = locals; locals = null;
      }
      if (!locals) locals = NO_LOCALS;
      else if (!isObject(locals)) {
        throw new Error("'locals' must be an object");
      }       
      if (!parent) parent = NO_PARENT;
      else if (!isResolve(parent)) {
        throw new Error("'parent' must be a promise returned by $resolve.resolve()");
      }
      
      // To complete the overall resolution, we have to wait for the parent
      // promise and for the promise for each invokable in our plan.
      var resolution = $q.defer(),
          result = resolution.promise,
          promises = result.$$promises = {},
          values = extend({}, locals),
          wait = 1 + plan.length/3,
          merged = false;
          
      function done() {
        // Merge parent values we haven't got yet and publish our own $$values
        if (!--wait) {
          if (!merged) merge(values, parent.$$values); 
          result.$$values = values;
          result.$$promises = true; // keep for isResolve()
          resolution.resolve(values);
        }
      }
      
      function fail(reason) {
        result.$$failure = reason;
        resolution.reject(reason);
      }
      
      // Short-circuit if parent has already failed
      if (isDefined(parent.$$failure)) {
        fail(parent.$$failure);
        return result;
      }
      
      // Merge parent values if the parent has already resolved, or merge
      // parent promises and wait if the parent resolve is still in progress.
      if (parent.$$values) {
        merged = merge(values, parent.$$values);
        done();
      } else {
        extend(promises, parent.$$promises);
        parent.then(done, fail);
      }
      
      // Process each invocable in the plan, but ignore any where a local of the same name exists.
      for (var i=0, ii=plan.length; i<ii; i+=3) {
        if (locals.hasOwnProperty(plan[i])) done();
        else invoke(plan[i], plan[i+1], plan[i+2]);
      }
      
      function invoke(key, invocable, params) {
        // Create a deferred for this invocation. Failures will propagate to the resolution as well.
        var invocation = $q.defer(), waitParams = 0;
        function onfailure(reason) {
          invocation.reject(reason);
          fail(reason);
        }
        // Wait for any parameter that we have a promise for (either from parent or from this
        // resolve; in that case study() will have made sure it's ordered before us in the plan).
        forEach(params, function (dep) {
          if (promises.hasOwnProperty(dep) && !locals.hasOwnProperty(dep)) {
            waitParams++;
            promises[dep].then(function (result) {
              values[dep] = result;
              if (!(--waitParams)) proceed();
            }, onfailure);
          }
        });
        if (!waitParams) proceed();
        function proceed() {
          if (isDefined(result.$$failure)) return;
          try {
            invocation.resolve($injector.invoke(invocable, self, values));
            invocation.promise.then(function (result) {
              values[key] = result;
              done();
            }, onfailure);
          } catch (e) {
            onfailure(e);
          }
        }
        // Publish promise synchronously; invocations further down in the plan may depend on it.
        promises[key] = invocation.promise;
      }
      
      return result;
    };
  };
  
  /**
   * Resolves a set of invocables. An invocable is a function to be invoked via `$injector.invoke()`,
   * and can have an arbitrary number of dependencies. An invocable can either return a value directly,
   * or a `$q` promise. If a promise is returned it will be resolved and the resulting value will be
   * used instead. Dependencies of invocables are resolved (in this order of precedence)
   *
   * - from the specified `locals`
   * - from another invocable that is part of this `$resolve` call
   * - from an invocable that is inherited from a `parent` call to `$resolve` (or recursively
   *   from any ancestor `$resolve` of that parent).
   *
   * The return value of `$resolve` is a promise for an object that contains (in this order of precedence)
   *
   * - any `locals` (if specified)
   * - the resolved return values of all injectables
   * - any values inherited from a `parent` call to `$resolve` (if specified)
   *
   * The promise will resolve after the `parent` promise (if any) and all promises returned by injectables
   * have been resolved. If any invocable (or `$injector.invoke`) throws an exception, or if a promise
   * returned by an invocable is rejected, the `$resolve` promise is immediately rejected with the same error.
   * A rejection of a `parent` promise (if specified) will likewise be propagated immediately. Once the
   * `$resolve` promise has been rejected, no further invocables will be called.
   * 
   * Cyclic dependencies between invocables are not permitted and will caues `$resolve` to throw an
   * error. As a special case, an injectable can depend on a parameter with the same name as the injectable,
   * which will be fulfilled from the `parent` injectable of the same name. This allows inherited values
   * to be decorated. Note that in this case any other injectable in the same `$resolve` with the same
   * dependency would see the decorated value, not the inherited value.
   *
   * Note that missing dependencies -- unlike cyclic dependencies -- will cause an (asynchronous) rejection
   * of the `$resolve` promise rather than a (synchronous) exception.
   *
   * Invocables are invoked eagerly as soon as all dependencies are available. This is true even for
   * dependencies inherited from a `parent` call to `$resolve`.
   *
   * As a special case, an invocable can be a string, in which case it is taken to be a service name
   * to be passed to `$injector.get()`. This is supported primarily for backwards-compatibility with the
   * `resolve` property of `$routeProvider` routes.
   *
   * @function
   * @param {Object.<string, Function|string>} invocables  functions to invoke or `$injector` services to fetch.
   * @param {Object.<string, *>} [locals]  values to make available to the injectables
   * @param {Promise.<Object>} [parent]  a promise returned by another call to `$resolve`.
   * @param {Object} [self]  the `this` for the invoked methods
   * @return {Promise.<Object>}  Promise for an object that contains the resolved return value
   *    of all invocables, as well as any inherited and local values.
   */
  this.resolve = function (invocables, locals, parent, self) {
    return this.study(invocables)(locals, parent, self);
  };
}

angular.module('ui.router.util').service('$resolve', $Resolve);


/**
 * Service. Manages loading of templates.
 * @constructor
 * @name $templateFactory
 * @requires $http
 * @requires $templateCache
 * @requires $injector
 */
$TemplateFactory.$inject = ['$http', '$templateCache', '$injector'];
function $TemplateFactory(  $http,   $templateCache,   $injector) {

  /**
   * Creates a template from a configuration object. 
   * @function
   * @name $templateFactory#fromConfig
   * @methodOf $templateFactory
   * @param {Object} config  Configuration object for which to load a template. The following
   *    properties are search in the specified order, and the first one that is defined is
   *    used to create the template:
   * @param {string|Function} config.template  html string template or function to load via
   *    {@link $templateFactory#fromString fromString}.
   * @param {string|Function} config.templateUrl  url to load or a function returning the url
   *    to load via {@link $templateFactory#fromUrl fromUrl}.
   * @param {Function} config.templateProvider  function to invoke via
   *    {@link $templateFactory#fromProvider fromProvider}.
   * @param {Object} params  Parameters to pass to the template function.
   * @param {Object} [locals] Locals to pass to `invoke` if the template is loaded via a
   *      `templateProvider`. Defaults to `{ params: params }`.
   * @return {string|Promise.<string>}  The template html as a string, or a promise for that string,
   *      or `null` if no template is configured.
   */
  this.fromConfig = function (config, params, locals) {
    return (
      isDefined(config.template) ? this.fromString(config.template, params) :
      isDefined(config.templateUrl) ? this.fromUrl(config.templateUrl, params) :
      isDefined(config.templateProvider) ? this.fromProvider(config.templateProvider, params, locals) :
      null
    );
  };

  /**
   * Creates a template from a string or a function returning a string.
   * @function
   * @name $templateFactory#fromString
   * @methodOf $templateFactory
   * @param {string|Function} template  html template as a string or function that returns an html
   *      template as a string.
   * @param {Object} params  Parameters to pass to the template function.
   * @return {string|Promise.<string>}  The template html as a string, or a promise for that string.
   */
  this.fromString = function (template, params) {
    return isFunction(template) ? template(params) : template;
  };

  /**
   * Loads a template from the a URL via `$http` and `$templateCache`.
   * @function
   * @name $templateFactory#fromUrl
   * @methodOf $templateFactory
   * @param {string|Function} url  url of the template to load, or a function that returns a url.
   * @param {Object} params  Parameters to pass to the url function.
   * @return {string|Promise.<string>}  The template html as a string, or a promise for that string.
   */
  this.fromUrl = function (url, params) {
    if (isFunction(url)) url = url(params);
    if (url == null) return null;
    else return $http
        .get(url, { cache: $templateCache })
        .then(function(response) { return response.data; });
  };

  /**
   * Creates a template by invoking an injectable provider function.
   * @function
   * @name $templateFactory#fromUrl
   * @methodOf $templateFactory
   * @param {Function} provider Function to invoke via `$injector.invoke`
   * @param {Object} params Parameters for the template.
   * @param {Object} [locals] Locals to pass to `invoke`. Defaults to `{ params: params }`.
   * @return {string|Promise.<string>} The template html as a string, or a promise for that string.
   */
  this.fromProvider = function (provider, params, locals) {
    return $injector.invoke(provider, null, locals || { params: params });
  };
}

angular.module('ui.router.util').service('$templateFactory', $TemplateFactory);

/**
 * Matches URLs against patterns and extracts named parameters from the path or the search
 * part of the URL. A URL pattern consists of a path pattern, optionally followed by '?' and a list
 * of search parameters. Multiple search parameter names are separated by '&'. Search parameters
 * do not influence whether or not a URL is matched, but their values are passed through into
 * the matched parameters returned by {@link UrlMatcher#exec exec}.
 * 
 * Path parameter placeholders can be specified using simple colon/catch-all syntax or curly brace
 * syntax, which optionally allows a regular expression for the parameter to be specified:
 *
 * * ':' name - colon placeholder
 * * '*' name - catch-all placeholder
 * * '{' name '}' - curly placeholder
 * * '{' name ':' regexp '}' - curly placeholder with regexp. Should the regexp itself contain
 *   curly braces, they must be in matched pairs or escaped with a backslash.
 *
 * Parameter names may contain only word characters (latin letters, digits, and underscore) and
 * must be unique within the pattern (across both path and search parameters). For colon 
 * placeholders or curly placeholders without an explicit regexp, a path parameter matches any
 * number of characters other than '/'. For catch-all placeholders the path parameter matches
 * any number of characters.
 * 
 * ### Examples
 * 
 * * '/hello/' - Matches only if the path is exactly '/hello/'. There is no special treatment for
 *   trailing slashes, and patterns have to match the entire path, not just a prefix.
 * * '/user/:id' - Matches '/user/bob' or '/user/1234!!!' or even '/user/' but not '/user' or
 *   '/user/bob/details'. The second path segment will be captured as the parameter 'id'.
 * * '/user/{id}' - Same as the previous example, but using curly brace syntax.
 * * '/user/{id:[^/]*}' - Same as the previous example.
 * * '/user/{id:[0-9a-fA-F]{1,8}}' - Similar to the previous example, but only matches if the id
 *   parameter consists of 1 to 8 hex digits.
 * * '/files/{path:.*}' - Matches any URL starting with '/files/' and captures the rest of the
 *   path into the parameter 'path'.
 * * '/files/*path' - ditto.
 *
 * @constructor
 * @param {string} pattern  the pattern to compile into a matcher.
 *
 * @property {string} prefix  A static prefix of this pattern. The matcher guarantees that any
 *   URL matching this matcher (i.e. any string for which {@link UrlMatcher#exec exec()} returns
 *   non-null) will start with this prefix.
 */
function UrlMatcher(pattern) {

  // Find all placeholders and create a compiled pattern, using either classic or curly syntax:
  //   '*' name
  //   ':' name
  //   '{' name '}'
  //   '{' name ':' regexp '}'
  // The regular expression is somewhat complicated due to the need to allow curly braces
  // inside the regular expression. The placeholder regexp breaks down as follows:
  //    ([:*])(\w+)               classic placeholder ($1 / $2)
  //    \{(\w+)(?:\:( ... ))?\}   curly brace placeholder ($3) with optional regexp ... ($4)
  //    (?: ... | ... | ... )+    the regexp consists of any number of atoms, an atom being either
  //    [^{}\\]+                  - anything other than curly braces or backslash
  //    \\.                       - a backslash escape
  //    \{(?:[^{}\\]+|\\.)*\}     - a matched set of curly braces containing other atoms
  var placeholder = /([:*])(\w+)|\{(\w+)(?:\:((?:[^{}\\]+|\\.|\{(?:[^{}\\]+|\\.)*\})+))?\}/g,
      names = {}, compiled = '^', last = 0, m,
      segments = this.segments = [],
      params = this.params = [];

  function addParameter(id) {
    if (!/^\w+(-+\w+)*$/.test(id)) throw new Error("Invalid parameter name '" + id + "' in pattern '" + pattern + "'");
    if (names[id]) throw new Error("Duplicate parameter name '" + id + "' in pattern '" + pattern + "'");
    names[id] = true;
    params.push(id);
  }

  function quoteRegExp(string) {
    return string.replace(/[\\\[\]\^$*+?.()|{}]/g, "\\$&");
  }

  this.source = pattern;

  // Split into static segments separated by path parameter placeholders.
  // The number of segments is always 1 more than the number of parameters.
  var id, regexp, segment;
  while ((m = placeholder.exec(pattern))) {
    id = m[2] || m[3]; // IE[78] returns '' for unmatched groups instead of null
    regexp = m[4] || (m[1] == '*' ? '.*' : '[^/]*');
    segment = pattern.substring(last, m.index);
    if (segment.indexOf('?') >= 0) break; // we're into the search part
    compiled += quoteRegExp(segment) + '(' + regexp + ')';
    addParameter(id);
    segments.push(segment);
    last = placeholder.lastIndex;
  }
  segment = pattern.substring(last);

  // Find any search parameter names and remove them from the last segment
  var i = segment.indexOf('?');
  if (i >= 0) {
    var search = this.sourceSearch = segment.substring(i);
    segment = segment.substring(0, i);
    this.sourcePath = pattern.substring(0, last+i);

    // Allow parameters to be separated by '?' as well as '&' to make concat() easier
    forEach(search.substring(1).split(/[&?]/), addParameter);
  } else {
    this.sourcePath = pattern;
    this.sourceSearch = '';
  }

  compiled += quoteRegExp(segment) + '$';
  segments.push(segment);
  this.regexp = new RegExp(compiled);
  this.prefix = segments[0];
}

/**
 * Returns a new matcher for a pattern constructed by appending the path part and adding the
 * search parameters of the specified pattern to this pattern. The current pattern is not
 * modified. This can be understood as creating a pattern for URLs that are relative to (or
 * suffixes of) the current pattern.
 *
 * ### Example
 * The following two matchers are equivalent:
 * ```
 * new UrlMatcher('/user/{id}?q').concat('/details?date');
 * new UrlMatcher('/user/{id}/details?q&date');
 * ```
 *
 * @param {string} pattern  The pattern to append.
 * @return {UrlMatcher}  A matcher for the concatenated pattern.
 */
UrlMatcher.prototype.concat = function (pattern) {
  // Because order of search parameters is irrelevant, we can add our own search
  // parameters to the end of the new pattern. Parse the new pattern by itself
  // and then join the bits together, but it's much easier to do this on a string level.
  return new UrlMatcher(this.sourcePath + pattern + this.sourceSearch);
};

UrlMatcher.prototype.toString = function () {
  return this.source;
};

/**
 * Tests the specified path against this matcher, and returns an object containing the captured
 * parameter values, or null if the path does not match. The returned object contains the values
 * of any search parameters that are mentioned in the pattern, but their value may be null if
 * they are not present in `searchParams`. This means that search parameters are always treated
 * as optional.
 *
 * ### Example
 * ```
 * new UrlMatcher('/user/{id}?q&r').exec('/user/bob', { x:'1', q:'hello' });
 * // returns { id:'bob', q:'hello', r:null }
 * ```
 *
 * @param {string} path  The URL path to match, e.g. `$location.path()`.
 * @param {Object} searchParams  URL search parameters, e.g. `$location.search()`.
 * @return {Object}  The captured parameter values.
 */
UrlMatcher.prototype.exec = function (path, searchParams) {
  var m = this.regexp.exec(path);
  if (!m) return null;

  var params = this.params, nTotal = params.length,
    nPath = this.segments.length-1,
    values = {}, i;

  if (nPath !== m.length - 1) throw new Error("Unbalanced capture group in route '" + this.source + "'");

  for (i=0; i<nPath; i++) values[params[i]] = m[i+1];
  for (/**/; i<nTotal; i++) values[params[i]] = searchParams[params[i]];

  return values;
};

/**
 * Returns the names of all path and search parameters of this pattern in an unspecified order.
 * @return {Array.<string>}  An array of parameter names. Must be treated as read-only. If the
 *    pattern has no parameters, an empty array is returned.
 */
UrlMatcher.prototype.parameters = function () {
  return this.params;
};

/**
 * Creates a URL that matches this pattern by substituting the specified values
 * for the path and search parameters. Null values for path parameters are
 * treated as empty strings.
 *
 * ### Example
 * ```
 * new UrlMatcher('/user/{id}?q').format({ id:'bob', q:'yes' });
 * // returns '/user/bob?q=yes'
 * ```
 *
 * @param {Object} values  the values to substitute for the parameters in this pattern.
 * @return {string}  the formatted URL (path and optionally search part).
 */
UrlMatcher.prototype.format = function (values) {
  var segments = this.segments, params = this.params;
  if (!values) return segments.join('');

  var nPath = segments.length-1, nTotal = params.length,
    result = segments[0], i, search, value;

  for (i=0; i<nPath; i++) {
    value = values[params[i]];
    // TODO: Maybe we should throw on null here? It's not really good style to use '' and null interchangeabley
    if (value != null) result += encodeURIComponent(value);
    result += segments[i+1];
  }
  for (/**/; i<nTotal; i++) {
    value = values[params[i]];
    if (value != null) {
      result += (search ? '&' : '?') + params[i] + '=' + encodeURIComponent(value);
      search = true;
    }
  }

  return result;
};

/**
 * Service. Factory for {@link UrlMatcher} instances. The factory is also available to providers
 * under the name `$urlMatcherFactoryProvider`.
 * @constructor
 * @name $urlMatcherFactory
 */
function $UrlMatcherFactory() {
  /**
   * Creates a {@link UrlMatcher} for the specified pattern.
   * @function
   * @name $urlMatcherFactory#compile
   * @methodOf $urlMatcherFactory
   * @param {string} pattern  The URL pattern.
   * @return {UrlMatcher}  The UrlMatcher.
   */
  this.compile = function (pattern) {
    return new UrlMatcher(pattern);
  };

  /**
   * Returns true if the specified object is a UrlMatcher, or false otherwise.
   * @function
   * @name $urlMatcherFactory#isMatcher
   * @methodOf $urlMatcherFactory
   * @param {Object} o
   * @return {boolean}
   */
  this.isMatcher = function (o) {
    return isObject(o) && isFunction(o.exec) && isFunction(o.format) && isFunction(o.concat);
  };

  this.$get = function () {
    return this;
  };
}

// Register as a provider so it's available to other providers
angular.module('ui.router.util').provider('$urlMatcherFactory', $UrlMatcherFactory);


$UrlRouterProvider.$inject = ['$urlMatcherFactoryProvider'];
function $UrlRouterProvider(  $urlMatcherFactory) {
  var rules = [], 
      otherwise = null;

  // Returns a string that is a prefix of all strings matching the RegExp
  function regExpPrefix(re) {
    var prefix = /^\^((?:\\[^a-zA-Z0-9]|[^\\\[\]\^$*+?.()|{}]+)*)/.exec(re.source);
    return (prefix != null) ? prefix[1].replace(/\\(.)/g, "$1") : '';
  }

  // Interpolates matched values into a String.replace()-style pattern
  function interpolate(pattern, match) {
    return pattern.replace(/\$(\$|\d{1,2})/, function (m, what) {
      return match[what === '$' ? 0 : Number(what)];
    });
  }

  this.rule =
    function (rule) {
      if (!isFunction(rule)) throw new Error("'rule' must be a function");
      rules.push(rule);
      return this;
    };

  this.otherwise =
    function (rule) {
      if (isString(rule)) {
        var redirect = rule;
        rule = function () { return redirect; };
      }
      else if (!isFunction(rule)) throw new Error("'rule' must be a function");
      otherwise = rule;
      return this;
    };


  function handleIfMatch($injector, handler, match) {
    if (!match) return false;
    var result = $injector.invoke(handler, handler, { $match: match });
    return isDefined(result) ? result : true;
  }

  this.when =
    function (what, handler) {
      var redirect, handlerIsString = isString(handler);
      if (isString(what)) what = $urlMatcherFactory.compile(what);

      if (!handlerIsString && !isFunction(handler) && !isArray(handler))
        throw new Error("invalid 'handler' in when()");

      var strategies = {
        matcher: function (what, handler) {
          if (handlerIsString) {
            redirect = $urlMatcherFactory.compile(handler);
            handler = ['$match', function ($match) { return redirect.format($match); }];
          }
          return extend(function ($injector, $location) {
            return handleIfMatch($injector, handler, what.exec($location.path(), $location.search()));
          }, {
            prefix: isString(what.prefix) ? what.prefix : ''
          });
        },
        regex: function (what, handler) {
          if (what.global || what.sticky) throw new Error("when() RegExp must not be global or sticky");

          if (handlerIsString) {
            redirect = handler;
            handler = ['$match', function ($match) { return interpolate(redirect, $match); }];
          }
          return extend(function ($injector, $location) {
            return handleIfMatch($injector, handler, what.exec($location.path()));
          }, {
            prefix: regExpPrefix(what)
          });
        }
      };

      var check = { matcher: $urlMatcherFactory.isMatcher(what), regex: what instanceof RegExp };

      for (var n in check) {
        if (check[n]) {
          return this.rule(strategies[n](what, handler));
        }
      }

      throw new Error("invalid 'what' in when()");
    };

  this.$get =
    [        '$location', '$rootScope', '$injector',
    function ($location,   $rootScope,   $injector) {
      // TODO: Optimize groups of rules with non-empty prefix into some sort of decision tree
      function update(evt) {
        if (evt && evt.defaultPrevented) return;
        function check(rule) {
          var handled = rule($injector, $location);
          if (handled) {
            if (isString(handled)) $location.replace().url(handled);
            return true;
          }
          return false;
        }
        var n=rules.length, i;
        for (i=0; i<n; i++) {
          if (check(rules[i])) return;
        }
        // always check otherwise last to allow dynamic updates to the set of rules
        if (otherwise) check(otherwise);
      }

      $rootScope.$on('$locationChangeSuccess', update);

      return {
        sync: function () {
          update();
        }
      };
    }];
}

angular.module('ui.router.router').provider('$urlRouter', $UrlRouterProvider);

$StateProvider.$inject = ['$urlRouterProvider', '$urlMatcherFactoryProvider', '$locationProvider'];
function $StateProvider(   $urlRouterProvider,   $urlMatcherFactory,           $locationProvider) {

  var root, states = {}, $state, queue = {}, abstractKey = 'abstract';

  // Builds state properties from definition passed to registerState()
  var stateBuilder = {

    // Derive parent state from a hierarchical name only if 'parent' is not explicitly defined.
    // state.children = [];
    // if (parent) parent.children.push(state);
    parent: function(state) {
      if (isDefined(state.parent) && state.parent) return findState(state.parent);
      // regex matches any valid composite state name
      // would match "contact.list" but not "contacts"
      var compositeName = /^(.+)\.[^.]+$/.exec(state.name);
      return compositeName ? findState(compositeName[1]) : root;
    },

    // inherit 'data' from parent and override by own values (if any)
    data: function(state) {
      if (state.parent && state.parent.data) {
        state.data = state.self.data = extend({}, state.parent.data, state.data);
      }
      return state.data;
    },

    // Build a URLMatcher if necessary, either via a relative or absolute URL
    url: function(state) {
      var url = state.url;

      if (isString(url)) {
        if (url.charAt(0) == '^') {
          return $urlMatcherFactory.compile(url.substring(1));
        }
        return (state.parent.navigable || root).url.concat(url);
      }

      if ($urlMatcherFactory.isMatcher(url) || url == null) {
        return url;
      }
      throw new Error("Invalid url '" + url + "' in state '" + state + "'");
    },

    // Keep track of the closest ancestor state that has a URL (i.e. is navigable)
    navigable: function(state) {
      return state.url ? state : (state.parent ? state.parent.navigable : null);
    },

    // Derive parameters for this state and ensure they're a super-set of parent's parameters
    params: function(state) {
      if (!state.params) {
        return state.url ? state.url.parameters() : state.parent.params;
      }
      if (!isArray(state.params)) throw new Error("Invalid params in state '" + state + "'");
      if (state.url) throw new Error("Both params and url specicified in state '" + state + "'");
      return state.params;
    },

    // If there is no explicit multi-view configuration, make one up so we don't have
    // to handle both cases in the view directive later. Note that having an explicit
    // 'views' property will mean the default unnamed view properties are ignored. This
    // is also a good time to resolve view names to absolute names, so everything is a
    // straight lookup at link time.
    views: function(state) {
      var views = {};

      forEach(isDefined(state.views) ? state.views : { '': state }, function (view, name) {
        if (name.indexOf('@') < 0) name += '@' + state.parent.name;
        views[name] = view;
      });
      return views;
    },

    ownParams: function(state) {
      if (!state.parent) {
        return state.params;
      }
      var paramNames = {}; forEach(state.params, function (p) { paramNames[p] = true; });

      forEach(state.parent.params, function (p) {
        if (!paramNames[p]) {
          throw new Error("Missing required parameter '" + p + "' in state '" + state.name + "'");
        }
        paramNames[p] = false;
      });
      var ownParams = [];

      forEach(paramNames, function (own, p) {
        if (own) ownParams.push(p);
      });
      return ownParams;
    },

    // Keep a full path from the root down to this state as this is needed for state activation.
    path: function(state) {
      return state.parent ? state.parent.path.concat(state) : []; // exclude root from path
    },

    // Speed up $state.contains() as it's used a lot
    includes: function(state) {
      var includes = state.parent ? extend({}, state.parent.includes) : {};
      includes[state.name] = true;
      return includes;
    },

    $delegates: {}
  };

  function isRelative(stateName) {
    return stateName.indexOf(".") === 0 || stateName.indexOf("^") === 0;
  }

  function findState(stateOrName, base) {
    var isStr = isString(stateOrName),
        name  = isStr ? stateOrName : stateOrName.name,
        path  = isRelative(name);

    if (path) {
      if (!base) throw new Error("No reference point given for path '"  + name + "'");
      var rel = name.split("."), i = 0, pathLength = rel.length, current = base;

      for (; i < pathLength; i++) {
        if (rel[i] === "" && i === 0) {
          current = base;
          continue;
        }
        if (rel[i] === "^") {
          if (!current.parent) throw new Error("Path '" + name + "' not valid for state '" + base.name + "'");
          current = current.parent;
          continue;
        }
        break;
      }
      rel = rel.slice(i).join(".");
      name = current.name + (current.name && rel ? "." : "") + rel;
    }
    var state = states[name];

    if (state && (isStr || (!isStr && (state === stateOrName || state.self === stateOrName)))) {
      return state;
    }
    return undefined;
  }

  function queueState(parentName, state) {
    if (!queue[parentName]) {
      queue[parentName] = [];
    }
    queue[parentName].push(state);
  }

  function registerState(state) {
    // Wrap a new object around the state so we can store our private details easily.
    state = inherit(state, {
      self: state,
      resolve: state.resolve || {},
      toString: function() { return this.name; }
    });

    var name = state.name;
    if (!isString(name) || name.indexOf('@') >= 0) throw new Error("State must have a valid name");
    if (states.hasOwnProperty(name)) throw new Error("State '" + name + "'' is already defined");

    // Get parent name
    var parentName = (name.indexOf('.') !== -1) ? name.substring(0, name.lastIndexOf('.'))
        : (isString(state.parent)) ? state.parent
        : '';

    // If parent is not registered yet, add state to queue and register later
    if (parentName && !states[parentName]) {
      return queueState(parentName, state.self);
    }

    for (var key in stateBuilder) {
      if (isFunction(stateBuilder[key])) state[key] = stateBuilder[key](state, stateBuilder.$delegates[key]);
    }
    states[name] = state;

    // Register the state in the global state list and with $urlRouter if necessary.
    if (!state[abstractKey] && state.url) {
      $urlRouterProvider.when(state.url, ['$match', '$stateParams', function ($match, $stateParams) {
        if ($state.$current.navigable != state || !equalForKeys($match, $stateParams)) {
          $state.transitionTo(state, $match, { location: false });
        }
      }]);
    }

    // Register any queued children
    if (queue[name]) {
      for (var i = 0; i < queue[name].length; i++) {
        registerState(queue[name][i]);
      }
    }

    return state;
  }


  // Implicit root state that is always active
  root = registerState({
    name: '',
    url: '^',
    views: null,
    'abstract': true
  });
  root.navigable = null;


  // .decorator()
  // .decorator(name)
  // .decorator(name, function)
  this.decorator = decorator;
  function decorator(name, func) {
    /*jshint validthis: true */
    if (isString(name) && !isDefined(func)) {
      return stateBuilder[name];
    }
    if (!isFunction(func) || !isString(name)) {
      return this;
    }
    if (stateBuilder[name] && !stateBuilder.$delegates[name]) {
      stateBuilder.$delegates[name] = stateBuilder[name];
    }
    stateBuilder[name] = func;
    return this;
  }

  // .state(state)
  // .state(name, state)
  this.state = state;
  function state(name, definition) {
    /*jshint validthis: true */
    if (isObject(name)) definition = name;
    else definition.name = name;
    registerState(definition);
    return this;
  }

  // $urlRouter is injected just to ensure it gets instantiated
  this.$get = $get;
  $get.$inject = ['$rootScope', '$q', '$view', '$injector', '$resolve', '$stateParams', '$location', '$urlRouter'];
  function $get(   $rootScope,   $q,   $view,   $injector,   $resolve,   $stateParams,   $location,   $urlRouter) {

    var TransitionSuperseded = $q.reject(new Error('transition superseded'));
    var TransitionPrevented = $q.reject(new Error('transition prevented'));
    var TransitionAborted = $q.reject(new Error('transition aborted'));
    var TransitionFailed = $q.reject(new Error('transition failed'));
    var currentLocation = $location.url();

    function syncUrl() {
      if ($location.url() !== currentLocation) {
        $location.url(currentLocation);
        $location.replace();
      }
    }

    root.locals = { resolve: null, globals: { $stateParams: {} } };
    $state = {
      params: {},
      current: root.self,
      $current: root,
      transition: null
    };

    $state.reload = function reload() {
      $state.transitionTo($state.current, $stateParams, { reload: true, inherit: false, notify: false });
    };

    $state.go = function go(to, params, options) {
      return this.transitionTo(to, params, extend({ inherit: true, relative: $state.$current }, options));
    };

    $state.transitionTo = function transitionTo(to, toParams, options) {
      toParams = toParams || {};
      options = extend({
        location: true, inherit: false, relative: null, notify: true, reload: false, $retry: false
      }, options || {});

      var from = $state.$current, fromParams = $state.params, fromPath = from.path;
      var evt, toState = findState(to, options.relative);

      if (!isDefined(toState)) {
        // Broadcast not found event and abort the transition if prevented
        var redirect = { to: to, toParams: toParams, options: options };
        evt = $rootScope.$broadcast('$stateNotFound', redirect, from.self, fromParams);
        if (evt.defaultPrevented) {
          syncUrl();
          return TransitionAborted;
        }

        // Allow the handler to return a promise to defer state lookup retry
        if (evt.retry) {
          if (options.$retry) {
            syncUrl();
            return TransitionFailed;
          }
          var retryTransition = $state.transition = $q.when(evt.retry);
          retryTransition.then(function() {
            if (retryTransition !== $state.transition) return TransitionSuperseded;
            redirect.options.$retry = true;
            return $state.transitionTo(redirect.to, redirect.toParams, redirect.options);
          }, function() {
            return TransitionAborted;
          });
          syncUrl();
          return retryTransition;
        }

        // Always retry once if the $stateNotFound was not prevented
        // (handles either redirect changed or state lazy-definition)
        to = redirect.to;
        toParams = redirect.toParams;
        options = redirect.options;
        toState = findState(to, options.relative);
        if (!isDefined(toState)) {
          if (options.relative) throw new Error("Could not resolve '" + to + "' from state '" + options.relative + "'");
          throw new Error("No such state '" + to + "'");
        }
      }
      if (toState[abstractKey]) throw new Error("Cannot transition to abstract state '" + to + "'");
      if (options.inherit) toParams = inheritParams($stateParams, toParams || {}, $state.$current, toState);
      to = toState;

      var toPath = to.path;

      // Starting from the root of the path, keep all levels that haven't changed
      var keep, state, locals = root.locals, toLocals = [];
      for (keep = 0, state = toPath[keep];
           state && state === fromPath[keep] && equalForKeys(toParams, fromParams, state.ownParams) && !options.reload;
           keep++, state = toPath[keep]) {
        locals = toLocals[keep] = state.locals;
      }

      // If we're going to the same state and all locals are kept, we've got nothing to do.
      // But clear 'transition', as we still want to cancel any other pending transitions.
      // TODO: We may not want to bump 'transition' if we're called from a location change that we've initiated ourselves,
      // because we might accidentally abort a legitimate transition initiated from code?
      if (shouldTriggerReload(to, from, locals, options) ) {
        if ( to.self.reloadOnSearch !== false )
          syncUrl();
        $state.transition = null;
        return $q.when($state.current);
      }

      // Normalize/filter parameters before we pass them to event handlers etc.
      toParams = normalize(to.params, toParams || {});

      // Broadcast start event and cancel the transition if requested
      if (options.notify) {
        evt = $rootScope.$broadcast('$stateChangeStart', to.self, toParams, from.self, fromParams);
        if (evt.defaultPrevented) {
          syncUrl();
          return TransitionPrevented;
        }
      }

      // Resolve locals for the remaining states, but don't update any global state just
      // yet -- if anything fails to resolve the current state needs to remain untouched.
      // We also set up an inheritance chain for the locals here. This allows the view directive
      // to quickly look up the correct definition for each view in the current state. Even
      // though we create the locals object itself outside resolveState(), it is initially
      // empty and gets filled asynchronously. We need to keep track of the promise for the
      // (fully resolved) current locals, and pass this down the chain.
      var resolved = $q.when(locals);
      for (var l=keep; l<toPath.length; l++, state=toPath[l]) {
        locals = toLocals[l] = inherit(locals);
        resolved = resolveState(state, toParams, state===to, resolved, locals);
      }

      // Once everything is resolved, we are ready to perform the actual transition
      // and return a promise for the new state. We also keep track of what the
      // current promise is, so that we can detect overlapping transitions and
      // keep only the outcome of the last transition.
      var transition = $state.transition = resolved.then(function () {
        var l, entering, exiting;

        if ($state.transition !== transition) return TransitionSuperseded;

        // Exit 'from' states not kept
        for (l=fromPath.length-1; l>=keep; l--) {
          exiting = fromPath[l];
          if (exiting.self.onExit) {
            $injector.invoke(exiting.self.onExit, exiting.self, exiting.locals.globals);
          }
          exiting.locals = null;
        }

        // Enter 'to' states not kept
        for (l=keep; l<toPath.length; l++) {
          entering = toPath[l];
          entering.locals = toLocals[l];
          if (entering.self.onEnter) {
            $injector.invoke(entering.self.onEnter, entering.self, entering.locals.globals);
          }
        }

        // Run it again, to catch any transitions in callbacks
        if ($state.transition !== transition) return TransitionSuperseded;

        // Update globals in $state
        $state.$current = to;
        $state.current = to.self;
        $state.params = toParams;
        copy($state.params, $stateParams);
        $state.transition = null;

        // Update $location
        var toNav = to.navigable;
        if (options.location && toNav) {
          $location.url(toNav.url.format(toNav.locals.globals.$stateParams));

          if (options.location === 'replace') {
            $location.replace();
          }
        }

        if (options.notify) {
          $rootScope.$broadcast('$stateChangeSuccess', to.self, toParams, from.self, fromParams);
        }
        currentLocation = $location.url();

        return $state.current;
      }, function (error) {
        if ($state.transition !== transition) return TransitionSuperseded;

        $state.transition = null;
        $rootScope.$broadcast('$stateChangeError', to.self, toParams, from.self, fromParams, error);
        syncUrl();

        return $q.reject(error);
      });

      return transition;
    };

    $state.is = function is(stateOrName, params) {
      var state = findState(stateOrName);

      if (!isDefined(state)) {
        return undefined;
      }

      if ($state.$current !== state) {
        return false;
      }

      return isDefined(params) ? angular.equals($stateParams, params) : true;
    };

    $state.includes = function includes(stateOrName, params) {
      var state = findState(stateOrName);
      if (!isDefined(state)) {
        return undefined;
      }

      if (!isDefined($state.$current.includes[state.name])) {
        return false;
      }

      var validParams = true;
      angular.forEach(params, function(value, key) {
        if (!isDefined($stateParams[key]) || $stateParams[key] !== value) {
          validParams = false;
        }
      });
      return validParams;
    };

    $state.href = function href(stateOrName, params, options) {
      options = extend({ lossy: true, inherit: false, absolute: false, relative: $state.$current }, options || {});
      var state = findState(stateOrName, options.relative);
      if (!isDefined(state)) return null;

      params = inheritParams($stateParams, params || {}, $state.$current, state);
      var nav = (state && options.lossy) ? state.navigable : state;
      var url = (nav && nav.url) ? nav.url.format(normalize(state.params, params || {})) : null;
      if (!$locationProvider.html5Mode() && url) {
        url = "#" + $locationProvider.hashPrefix() + url;
      }
      if (options.absolute && url) {
        url = $location.protocol() + '://' + 
              $location.host() + 
              ($location.port() == 80 || $location.port() == 443 ? '' : ':' + $location.port()) + 
              (!$locationProvider.html5Mode() && url ? '/' : '') + 
              url;
      }
      return url;
    };

    $state.get = function (stateOrName, context) {
      if (!isDefined(stateOrName)) {
        var list = [];
        forEach(states, function(state) { list.push(state.self); });
        return list;
      }
      var state = findState(stateOrName, context);
      return (state && state.self) ? state.self : null;
    };

    function resolveState(state, params, paramsAreFiltered, inherited, dst) {
      // Make a restricted $stateParams with only the parameters that apply to this state if
      // necessary. In addition to being available to the controller and onEnter/onExit callbacks,
      // we also need $stateParams to be available for any $injector calls we make during the
      // dependency resolution process.
      var $stateParams = (paramsAreFiltered) ? params : filterByKeys(state.params, params);
      var locals = { $stateParams: $stateParams };

      // Resolve 'global' dependencies for the state, i.e. those not specific to a view.
      // We're also including $stateParams in this; that way the parameters are restricted
      // to the set that should be visible to the state, and are independent of when we update
      // the global $state and $stateParams values.
      dst.resolve = $resolve.resolve(state.resolve, locals, dst.resolve, state);
      var promises = [ dst.resolve.then(function (globals) {
        dst.globals = globals;
      }) ];
      if (inherited) promises.push(inherited);

      // Resolve template and dependencies for all views.
      forEach(state.views, function (view, name) {
        var injectables = (view.resolve && view.resolve !== state.resolve ? view.resolve : {});
        injectables.$template = [ function () {
          return $view.load(name, { view: view, locals: locals, params: $stateParams, notify: false }) || '';
        }];

        promises.push($resolve.resolve(injectables, locals, dst.resolve, state).then(function (result) {
          // References to the controller (only instantiated at link time)
          if (isFunction(view.controllerProvider) || isArray(view.controllerProvider)) {
            var injectLocals = angular.extend({}, injectables, locals);
            result.$$controller = $injector.invoke(view.controllerProvider, null, injectLocals);
          } else {
            result.$$controller = view.controller;
          }
          // Provide access to the state itself for internal use
          result.$$state = state;
          dst[name] = result;
        }));
      });

      // Wait for all the promises and then return the activation object
      return $q.all(promises).then(function (values) {
        return dst;
      });
    }

    return $state;
  }

  function shouldTriggerReload(to, from, locals, options) {
    if ( to === from && ((locals === from.locals && !options.reload) || (to.self.reloadOnSearch === false)) ) {
      return true;
    }
  }
}

angular.module('ui.router.state')
  .value('$stateParams', {})
  .provider('$state', $StateProvider);


$ViewProvider.$inject = [];
function $ViewProvider() {

  this.$get = $get;
  $get.$inject = ['$rootScope', '$templateFactory'];
  function $get(   $rootScope,   $templateFactory) {
    return {
      // $view.load('full.viewName', { template: ..., controller: ..., resolve: ..., async: false, params: ... })
      load: function load(name, options) {
        var result, defaults = {
          template: null, controller: null, view: null, locals: null, notify: true, async: true, params: {}
        };
        options = extend(defaults, options);

        if (options.view) {
          result = $templateFactory.fromConfig(options.view, options.params, options.locals);
        }
        if (result && options.notify) {
          $rootScope.$broadcast('$viewContentLoading', options);
        }
        return result;
      }
    };
  }
}

angular.module('ui.router.state').provider('$view', $ViewProvider);


$ViewDirective.$inject = ['$state', '$compile', '$controller', '$injector', '$anchorScroll'];
function $ViewDirective(   $state,   $compile,   $controller,   $injector,   $anchorScroll) {
  var $animator = $injector.has('$animator') ? $injector.get('$animator') : false;
  var viewIsUpdating = false;

  var directive = {
    restrict: 'ECA',
    terminal: true,
    priority: 1000,
    transclude: true,
    compile: function (element, attr, transclude) {
      return function(scope, element, attr) {
        var viewScope, viewLocals,
            name = attr[directive.name] || attr.name || '',
            onloadExp = attr.onload || '',
            animate = $animator && $animator(scope, attr),
            initialView = transclude(scope);

        // Returns a set of DOM manipulation functions based on whether animation
        // should be performed
        var renderer = function(doAnimate) {
          return ({
            "true": {
              remove: function(element) { animate.leave(element.contents(), element); },
              restore: function(compiled, element) { animate.enter(compiled, element); },
              populate: function(template, element) {
                var contents = angular.element('<div></div>').html(template).contents();
                animate.enter(contents, element);
                return contents;
              }
            },
            "false": {
              remove: function(element) { element.html(''); },
              restore: function(compiled, element) { element.append(compiled); },
              populate: function(template, element) {
                element.html(template);
                return element.contents();
              }
            }
          })[doAnimate.toString()];
        };

        // Put back the compiled initial view
        element.append(initialView);

        // Find the details of the parent view directive (if any) and use it
        // to derive our own qualified view name, then hang our own details
        // off the DOM so child directives can find it.
        var parent = element.parent().inheritedData('$uiView');
        if (name.indexOf('@') < 0) name  = name + '@' + (parent ? parent.state.name : '');
        var view = { name: name, state: null };
        element.data('$uiView', view);

        var eventHook = function() {
          if (viewIsUpdating) return;
          viewIsUpdating = true;

          try { updateView(true); } catch (e) {
            viewIsUpdating = false;
            throw e;
          }
          viewIsUpdating = false;
        };

        scope.$on('$stateChangeSuccess', eventHook);
        scope.$on('$viewContentLoading', eventHook);
        updateView(false);

        function updateView(doAnimate) {
          var locals = $state.$current && $state.$current.locals[name];
          if (locals === viewLocals) return; // nothing to do
          var render = renderer(animate && doAnimate);

          // Remove existing content
          render.remove(element);

          // Destroy previous view scope
          if (viewScope) {
            viewScope.$destroy();
            viewScope = null;
          }

          if (!locals) {
            viewLocals = null;
            view.state = null;

            // Restore the initial view
            return render.restore(initialView, element);
          }

          viewLocals = locals;
          view.state = locals.$$state;

          var link = $compile(render.populate(locals.$template, element));
          viewScope = scope.$new();

          if (locals.$$controller) {
            locals.$scope = viewScope;
            var controller = $controller(locals.$$controller, locals);
            element.children().data('$ngControllerController', controller);
          }
          link(viewScope);
          viewScope.$emit('$viewContentLoaded');
          if (onloadExp) viewScope.$eval(onloadExp);

          // TODO: This seems strange, shouldn't $anchorScroll listen for $viewContentLoaded if necessary?
          // $anchorScroll might listen on event...
          $anchorScroll();
        }
      };
    }
  };
  return directive;
}

angular.module('ui.router.state').directive('uiView', $ViewDirective);

function parseStateRef(ref) {
  var parsed = ref.replace(/\n/g, " ").match(/^([^(]+?)\s*(\((.*)\))?$/);
  if (!parsed || parsed.length !== 4) throw new Error("Invalid state ref '" + ref + "'");
  return { state: parsed[1], paramExpr: parsed[3] || null };
}

function stateContext(el) {
  var stateData = el.parent().inheritedData('$uiView');

  if (stateData && stateData.state && stateData.state.name) {
    return stateData.state;
  }
}

$StateRefDirective.$inject = ['$state', '$timeout'];
function $StateRefDirective($state, $timeout) {
  return {
    restrict: 'A',
    require: '?^uiSrefActive',
    link: function(scope, element, attrs, uiSrefActive) {
      var ref = parseStateRef(attrs.uiSref);
      var params = null, url = null, base = stateContext(element) || $state.$current;
      var isForm = element[0].nodeName === "FORM";
      var attr = isForm ? "action" : "href", nav = true;

      var update = function(newVal) {
        if (newVal) params = newVal;
        if (!nav) return;

        var newHref = $state.href(ref.state, params, { relative: base });

        if (!newHref) {
          nav = false;
          return false;
        }
        element[0][attr] = newHref;
        if (uiSrefActive) {
          uiSrefActive.$$setStateInfo(ref.state, params);
        }
      };

      if (ref.paramExpr) {
        scope.$watch(ref.paramExpr, function(newVal, oldVal) {
          if (newVal !== params) update(newVal);
        }, true);
        params = scope.$eval(ref.paramExpr);
      }
      update();

      if (isForm) return;

      element.bind("click", function(e) {
        var button = e.which || e.button;

        if ((button === 0 || button == 1) && !e.ctrlKey && !e.metaKey && !e.shiftKey) {
          // HACK: This is to allow ng-clicks to be processed before the transition is initiated:
          $timeout(function() {
            scope.$apply(function() {
              $state.go(ref.state, params, { relative: base });
            });
          });
          e.preventDefault();
        }
      });
    }
  };
}

$StateActiveDirective.$inject = ['$state', '$stateParams', '$interpolate'];
function $StateActiveDirective($state, $stateParams, $interpolate) {
  return {
    restrict: "A",
    controller: function($scope, $element, $attrs) {
      var state, params, activeClass;

      // There probably isn't much point in $observing this
      activeClass = $interpolate($attrs.uiSrefActive || '', false)($scope);

      // Allow uiSref to communicate with uiSrefActive
      this.$$setStateInfo = function(newState, newParams) {
        state = $state.get(newState, stateContext($element));
        params = newParams;
        update();
      };

      $scope.$on('$stateChangeSuccess', update);

      // Update route state
      function update() {
        if ($state.$current.self === state && matchesParams()) {
          $element.addClass(activeClass);
        } else {
          $element.removeClass(activeClass);
        }
      }

      function matchesParams() {
        return !params || equalForKeys(params, $stateParams);
      }
    }
  };
}

angular.module('ui.router.state')
  .directive('uiSref', $StateRefDirective)
  .directive('uiSrefActive', $StateActiveDirective);

$RouteProvider.$inject = ['$stateProvider', '$urlRouterProvider'];
function $RouteProvider(  $stateProvider,    $urlRouterProvider) {

  var routes = [];

  onEnterRoute.$inject = ['$$state'];
  function onEnterRoute(   $$state) {
    /*jshint validthis: true */
    this.locals = $$state.locals.globals;
    this.params = this.locals.$stateParams;
  }

  function onExitRoute() {
    /*jshint validthis: true */
    this.locals = null;
    this.params = null;
  }

  this.when = when;
  function when(url, route) {
    /*jshint validthis: true */
    if (route.redirectTo != null) {
      // Redirect, configure directly on $urlRouterProvider
      var redirect = route.redirectTo, handler;
      if (isString(redirect)) {
        handler = redirect; // leave $urlRouterProvider to handle
      } else if (isFunction(redirect)) {
        // Adapt to $urlRouterProvider API
        handler = function (params, $location) {
          return redirect(params, $location.path(), $location.search());
        };
      } else {
        throw new Error("Invalid 'redirectTo' in when()");
      }
      $urlRouterProvider.when(url, handler);
    } else {
      // Regular route, configure as state
      $stateProvider.state(inherit(route, {
        parent: null,
        name: 'route:' + encodeURIComponent(url),
        url: url,
        onEnter: onEnterRoute,
        onExit: onExitRoute
      }));
    }
    routes.push(route);
    return this;
  }

  this.$get = $get;
  $get.$inject = ['$state', '$rootScope', '$routeParams'];
  function $get(   $state,   $rootScope,   $routeParams) {

    var $route = {
      routes: routes,
      params: $routeParams,
      current: undefined
    };

    function stateAsRoute(state) {
      return (state.name !== '') ? state : undefined;
    }

    $rootScope.$on('$stateChangeStart', function (ev, to, toParams, from, fromParams) {
      $rootScope.$broadcast('$routeChangeStart', stateAsRoute(to), stateAsRoute(from));
    });

    $rootScope.$on('$stateChangeSuccess', function (ev, to, toParams, from, fromParams) {
      $route.current = stateAsRoute(to);
      $rootScope.$broadcast('$routeChangeSuccess', stateAsRoute(to), stateAsRoute(from));
      copy(toParams, $route.params);
    });

    $rootScope.$on('$stateChangeError', function (ev, to, toParams, from, fromParams, error) {
      $rootScope.$broadcast('$routeChangeError', stateAsRoute(to), stateAsRoute(from), error);
    });

    return $route;
  }
}

angular.module('ui.router.compat')
  .provider('$route', $RouteProvider)
  .directive('ngView', $ViewDirective);
})(window, window.angular);
},{}],76:[function(require,module,exports){
var _this = this;

module.exports = function() {
  var Session;
  Session = function(Users, $q, BloomSettings) {
    var loadPromise;
    _this.me = BloomSettings.user;
    _this.loadOnce = false;
    loadPromise = $q.defer();
    Users.get(_this.me).then(function(data) {
      _this.data = data;
      return loadPromise.resolve(_this.data);
    });
    _this.load = function() {
      return loadPromise.promise;
    };
    return _this;
  };
  return angular.module('bloom.session', ['bloom.users', 'bloom.settings']).service('Session', Session);
};


},{}],77:[function(require,module,exports){
module.exports = function() {
  var API, BloomSettings;
  API = function($q, $http, BloomAPIUrl, BloomAPIKey, BloomData) {
    var _this = this;
    this.url = BloomAPIUrl;
    this.addKeys = function(params) {
      return _.extend(params, {
        apiKey: BloomAPIKey,
        bloomData: BloomData
      });
    };
    this.process = function(promise) {
      var def;
      def = $q.defer();
      promise.then(function(res) {
        return def.resolve(res.data);
      });
      return def.promise;
    };
    this.get = function(url, params) {
      if (params == null) {
        params = {};
      }
      params = _this.addKeys(params);
      return $http.get(_this.url + url, {
        params: params
      });
    };
    this.post = function(url, params) {
      if (params == null) {
        params = {};
      }
      params = _this.addKeys(params);
      return $http.post(_this.url + url, params);
    };
    this.put = function(url, params) {
      if (params == null) {
        params = {};
      }
      params = _this.addKeys(params);
      return $http.put(_this.url + url, params);
    };
    this["delete"] = function(url, params) {
      if (params == null) {
        params = {};
      }
      params = _this.addKeys(params);
      return $http["delete"](_this.url + url, {
        params: params
      });
    };
    return this;
  };
  BloomSettings = function(API, $q, $timeout) {
    var _this = this;
    this.token = 'abc';
    this.user = 'xnick';
    this.loggedIn = false;
    this.commentsIdToData = function() {
      var def;
      def = $q.defer();
      $timeout(function() {
        return def.resolve({
          title: "title " + (Math.random() * 1000),
          url: "posts/omg"
        });
      }, 2000);
      return def.promise;
    };
    this.getUser = function(_id) {
      var def;
      def = $q.defer();
      $timeout(function() {
        var user;
        user = _.findWhere(demoUsers, {
          _id: _id
        });
        def.resolve(user);
        user.avatarUrl = "/images/users/" + user._id + ".png";
        return user.profileLink = "/users/" + user._id;
      }, 50);
      return def.promise;
    };
    return this;
  };
  return angular.module('bloom.settings', []).service('API', API);
};


},{}],78:[function(require,module,exports){
var global=typeof self !== "undefined" ? self : typeof window !== "undefined" ? window : {};!function(e){if("object"==typeof exports)module.exports=e();else if("function"==typeof define&&define.amd)define(e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.jade=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);throw new Error("Cannot find module '"+o+"'")}var f=n[o]={exports:{}};t[o][0].call(f.exports,function(e){var n=t[o][1][e];return s(n?n:e)},f,f.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(_dereq_,module,exports){
'use strict';

/**
 * Merge two attribute objects giving precedence
 * to values in object `b`. Classes are special-cased
 * allowing for arrays and merging/joining appropriately
 * resulting in a string.
 *
 * @param {Object} a
 * @param {Object} b
 * @return {Object} a
 * @api private
 */

exports.merge = function merge(a, b) {
  if (arguments.length === 1) {
    var attrs = a[0];
    for (var i = 1; i < a.length; i++) {
      attrs = merge(attrs, a[i]);
    }
    return attrs;
  }
  var ac = a['class'];
  var bc = b['class'];

  if (ac || bc) {
    ac = ac || [];
    bc = bc || [];
    if (!Array.isArray(ac)) ac = [ac];
    if (!Array.isArray(bc)) bc = [bc];
    a['class'] = ac.concat(bc).filter(nulls);
  }

  for (var key in b) {
    if (key != 'class') {
      a[key] = b[key];
    }
  }

  return a;
};

/**
 * Filter null `val`s.
 *
 * @param {*} val
 * @return {Boolean}
 * @api private
 */

function nulls(val) {
  return val != null && val !== '';
}

/**
 * join array as classes.
 *
 * @param {*} val
 * @return {String}
 */
exports.joinClasses = joinClasses;
function joinClasses(val) {
  return Array.isArray(val) ? val.map(joinClasses).filter(nulls).join(' ') : val;
}

/**
 * Render the given classes.
 *
 * @param {Array} classes
 * @param {Array.<Boolean>} escaped
 * @return {String}
 */
exports.cls = function cls(classes, escaped) {
  var buf = [];
  for (var i = 0; i < classes.length; i++) {
    if (escaped && escaped[i]) {
      buf.push(exports.escape(joinClasses([classes[i]])));
    } else {
      buf.push(joinClasses(classes[i]));
    }
  }
  var text = joinClasses(buf);
  if (text.length) {
    return ' class="' + text + '"';
  } else {
    return '';
  }
};

/**
 * Render the given attribute.
 *
 * @param {String} key
 * @param {String} val
 * @param {Boolean} escaped
 * @param {Boolean} terse
 * @return {String}
 */
exports.attr = function attr(key, val, escaped, terse) {
  if ('boolean' == typeof val || null == val) {
    if (val) {
      return ' ' + (terse ? key : key + '="' + key + '"');
    } else {
      return '';
    }
  } else if (0 == key.indexOf('data') && 'string' != typeof val) {
    return ' ' + key + "='" + JSON.stringify(val).replace(/'/g, '&apos;') + "'";
  } else if (escaped) {
    return ' ' + key + '="' + exports.escape(val) + '"';
  } else {
    return ' ' + key + '="' + val + '"';
  }
};

/**
 * Render the given attributes object.
 *
 * @param {Object} obj
 * @param {Object} escaped
 * @return {String}
 */
exports.attrs = function attrs(obj, terse){
  var buf = [];

  var keys = Object.keys(obj);

  if (keys.length) {
    for (var i = 0; i < keys.length; ++i) {
      var key = keys[i]
        , val = obj[key];

      if ('class' == key) {
        if (val = joinClasses(val)) {
          buf.push(' ' + key + '="' + val + '"');
        }
      } else {
        buf.push(exports.attr(key, val, false, terse));
      }
    }
  }

  return buf.join('');
};

/**
 * Escape the given string of `html`.
 *
 * @param {String} html
 * @return {String}
 * @api private
 */

exports.escape = function escape(html){
  var result = String(html)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
  if (result === '' + html) return html;
  else return result;
};

/**
 * Re-throw the given `err` in context to the
 * the jade in `filename` at the given `lineno`.
 *
 * @param {Error} err
 * @param {String} filename
 * @param {String} lineno
 * @api private
 */

exports.rethrow = function rethrow(err, filename, lineno, str){
  if (!(err instanceof Error)) throw err;
  if ((typeof window != 'undefined' || !filename) && !str) {
    err.message += ' on line ' + lineno;
    throw err;
  }
  try {
    str =  str || _dereq_('fs').readFileSync(filename, 'utf8')
  } catch (ex) {
    rethrow(err, null, lineno)
  }
  var context = 3
    , lines = str.split('\n')
    , start = Math.max(lineno - context, 0)
    , end = Math.min(lines.length, lineno + context);

  // Error context
  var context = lines.slice(start, end).map(function(line, i){
    var curr = i + start + 1;
    return (curr == lineno ? '  > ' : '    ')
      + curr
      + '| '
      + line;
  }).join('\n');

  // Alter exception message
  err.path = filename;
  err.message = (filename || 'Jade') + ':' + lineno
    + '\n' + context + '\n\n' + err.message;
  throw err;
};

},{"fs":2}],2:[function(_dereq_,module,exports){

},{}]},{},[1])
(1)
});
},{}]},{},[1])