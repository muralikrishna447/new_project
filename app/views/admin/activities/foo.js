var goog = goog || {};
goog.global = this;
goog.DEBUG = !0;
goog.LOCALE = "en";
goog.TRUSTED_SITE = !0;
goog.provide = function (a) {
    goog.exportPath_(a)
};
goog.setTestOnly = function (a) {
    if (!goog.DEBUG)throw a = a || "", Error("Importing test-only code into non-debug environment" + a ? ": " + a : ".");
};
goog.exportPath_ = function (a, b, c) {
    a = a.split(".");
    c = c || goog.global;
    !(a[0]in c) && c.execScript && c.execScript("var " + a[0]);
    for (var d; a.length && (d = a.shift());)!a.length && goog.isDef(b) ? c[d] = b : c = c[d] ? c[d] : c[d] = {}
};
goog.getObjectByName = function (a, b) {
    for (var c = a.split("."), d = b || goog.global, e; e = c.shift();)if (goog.isDefAndNotNull(d[e]))d = d[e]; else return null;
    return d
};
goog.globalize = function (a, b) {
    var c = b || goog.global, d;
    for (d in a)c[d] = a[d]
};
goog.addDependency = function () {
};
goog.useStrictRequires = !1;
goog.ENABLE_DEBUG_LOADER = !0;
goog.require = function () {
};
goog.basePath = "";
goog.nullFunction = function () {
};
goog.identityFunction = function (a) {
    return a
};
goog.abstractMethod = function () {
    throw Error("unimplemented abstract method");
};
goog.addSingletonGetter = function (a) {
    a.getInstance = function () {
        if (a.instance_)return a.instance_;
        goog.DEBUG && (goog.instantiatedSingletons_[goog.instantiatedSingletons_.length] = a);
        return a.instance_ = new a
    }
};
goog.instantiatedSingletons_ = [];
goog.typeOf = function (a) {
    var b = typeof a;
    if ("object" == b)if (a) {
        if (a instanceof Array)return"array";
        if (a instanceof Object)return b;
        var c = Object.prototype.toString.call(a);
        if ("[object Window]" == c)return"object";
        if ("[object Array]" == c || "number" == typeof a.length && "undefined" != typeof a.splice && "undefined" != typeof a.propertyIsEnumerable && !a.propertyIsEnumerable("splice"))return"array";
        if ("[object Function]" == c || "undefined" != typeof a.call && "undefined" != typeof a.propertyIsEnumerable && !a.propertyIsEnumerable("call"))return"function"
    } else return"null";
    else if ("function" == b && "undefined" == typeof a.call)return"object";
    return b
};
goog.isDef = function (a) {
    return void 0 !== a
};
goog.isNull = function (a) {
    return null === a
};
goog.isDefAndNotNull = function (a) {
    return null != a
};
goog.isArray = function (a) {
    return"array" == goog.typeOf(a)
};
goog.isArrayLike = function (a) {
    var b = goog.typeOf(a);
    return"array" == b || "object" == b && "number" == typeof a.length
};
goog.isDateLike = function (a) {
    return goog.isObject(a) && "function" == typeof a.getFullYear
};
goog.isString = function (a) {
    return"string" == typeof a
};
goog.isBoolean = function (a) {
    return"boolean" == typeof a
};
goog.isNumber = function (a) {
    return"number" == typeof a
};
goog.isFunction = function (a) {
    return"function" == goog.typeOf(a)
};
goog.isObject = function (a) {
    var b = typeof a;
    return"object" == b && null != a || "function" == b
};
goog.getUid = function (a) {
    return a[goog.UID_PROPERTY_] || (a[goog.UID_PROPERTY_] = ++goog.uidCounter_)
};
goog.removeUid = function (a) {
    "removeAttribute"in a && a.removeAttribute(goog.UID_PROPERTY_);
    try {
        delete a[goog.UID_PROPERTY_]
    } catch (b) {
    }
};
goog.UID_PROPERTY_ = "closure_uid_" + (1E9 * Math.random() >>> 0);
goog.uidCounter_ = 0;
goog.getHashCode = goog.getUid;
goog.removeHashCode = goog.removeUid;
goog.cloneObject = function (a) {
    var b = goog.typeOf(a);
    if ("object" == b || "array" == b) {
        if (a.clone)return a.clone();
        var b = "array" == b ? [] : {}, c;
        for (c in a)b[c] = goog.cloneObject(a[c]);
        return b
    }
    return a
};
goog.bindNative_ = function (a, b, c) {
    return a.call.apply(a.bind, arguments)
};
goog.bindJs_ = function (a, b, c) {
    if (!a)throw Error();
    if (2 < arguments.length) {
        var d = Array.prototype.slice.call(arguments, 2);
        return function () {
            var c = Array.prototype.slice.call(arguments);
            Array.prototype.unshift.apply(c, d);
            return a.apply(b, c)
        }
    }
    return function () {
        return a.apply(b, arguments)
    }
};
goog.bind = function (a, b, c) {
    goog.bind = Function.prototype.bind && -1 != Function.prototype.bind.toString().indexOf("native code") ? goog.bindNative_ : goog.bindJs_;
    return goog.bind.apply(null, arguments)
};
goog.partial = function (a, b) {
    var c = Array.prototype.slice.call(arguments, 1);
    return function () {
        var b = Array.prototype.slice.call(arguments);
        b.unshift.apply(b, c);
        return a.apply(this, b)
    }
};
goog.mixin = function (a, b) {
    for (var c in b)a[c] = b[c]
};
goog.now = goog.TRUSTED_SITE && Date.now || function () {
    return+new Date
};
goog.globalEval = function (a) {
    if (goog.global.execScript)goog.global.execScript(a, "JavaScript"); else if (goog.global.eval)if (null == goog.evalWorksForGlobals_ && (goog.global.eval("var _et_ = 1;"), "undefined" != typeof goog.global._et_ ? (delete goog.global._et_, goog.evalWorksForGlobals_ = !0) : goog.evalWorksForGlobals_ = !1), goog.evalWorksForGlobals_)goog.global.eval(a); else {
        var b = goog.global.document, c = b.createElement("script");
        c.type = "text/javascript";
        c.defer = !1;
        c.appendChild(b.createTextNode(a));
        b.body.appendChild(c);
        b.body.removeChild(c)
    } else throw Error("goog.globalEval not available");
};
goog.evalWorksForGlobals_ = null;
goog.getCssName = function (a, b) {
    var c = function (a) {
        return goog.cssNameMapping_[a] || a
    }, d = function (a) {
        a = a.split("-");
        for (var b = [], d = 0; d < a.length; d++)b.push(c(a[d]));
        return b.join("-")
    }, d = goog.cssNameMapping_ ? "BY_WHOLE" == goog.cssNameMappingStyle_ ? c : d : function (a) {
        return a
    };
    return b ? a + "-" + d(b) : d(a)
};
goog.setCssNameMapping = function (a, b) {
    goog.cssNameMapping_ = a;
    goog.cssNameMappingStyle_ = b
};
goog.getMsg = function (a, b) {
    var c = b || {}, d;
    for (d in c) {
        var e = ("" + c[d]).replace(/\$/g, "$$$$");
        a = a.replace(RegExp("\\{\\$" + d + "\\}", "gi"), e)
    }
    return a
};
goog.getMsgWithFallback = function (a) {
    return a
};
goog.exportSymbol = function (a, b, c) {
    goog.exportPath_(a, b, c)
};
goog.exportProperty = function (a, b, c) {
    a[b] = c
};
goog.inherits = function (a, b) {
    function c() {
    }

    c.prototype = b.prototype;
    a.superClass_ = b.prototype;
    a.prototype = new c;
    a.prototype.constructor = a
};
goog.base = function (a, b, c) {
    var d = arguments.callee.caller;
    if (d.superClass_)return d.superClass_.constructor.apply(a, Array.prototype.slice.call(arguments, 1));
    for (var e = Array.prototype.slice.call(arguments, 2), f = !1, g = a.constructor; g; g = g.superClass_ && g.superClass_.constructor)if (g.prototype[b] === d)f = !0; else if (f)return g.prototype[b].apply(a, e);
    if (a[b] === d)return a.constructor.prototype[b].apply(a, e);
    throw Error("goog.base called from a method of one name to a method of a different name");
};
goog.scope = function (a) {
    a.call(goog.global)
};
goog.MODIFY_FUNCTION_PROTOTYPES = !0;
goog.MODIFY_FUNCTION_PROTOTYPES && (Function.prototype.bind = Function.prototype.bind || function (a, b) {
    if (1 < arguments.length) {
        var c = Array.prototype.slice.call(arguments, 1);
        c.unshift(this, a);
        return goog.bind.apply(null, c)
    }
    return goog.bind(this, a)
}, Function.prototype.partial = function (a) {
    var b = Array.prototype.slice.call(arguments);
    b.unshift(this, null);
    return goog.bind.apply(null, b)
}, Function.prototype.inherits = function (a) {
    goog.inherits(this, a)
}, Function.prototype.mixin = function (a) {
    goog.mixin(this.prototype,
        a)
});
var ww = {raf:{}, util:{}}, _gaq = _gaq || void 0;
ww.testMode = -1 < window.location.href.indexOf("test");
ww.util.floatComplexGaussianRandom = function () {
    var a, b, c, d = [];
    do a = 2 * Math.random() - 1, b = 2 * Math.random() - 1, c = a * a + b * b; while (1 <= c);
    c = Math.sqrt(-1 * Math.log(c) / c);
    d[0] = a * c;
    d[1] = b * c;
    return d
};
ww.util.rightNow = function () {
    return window.performance && window.performance.now ? window.performance.now() : +new Date
};
ww.util.pad = function (a, b) {
    for (var c = "" + a; c.length < b;)c = "0" + c;
    return c
};
ww.util.trackEvent = function (a, b, c) {
    "undefined" !== typeof ga && ga("send", "event", a, b, null, c)
};
ww.util.throttle = function (a, b) {
    var c, d, e, f, g = 0, h = function () {
        g = ww.util.rightNow();
        e = null;
        f = a.apply(c, d)
    };
    return function () {
        var k = ww.util.rightNow(), n = b - (k - g);
        c = this;
        d = arguments;
        0 >= n ? (clearTimeout(e), e = null, g = k, f = a.apply(c, d)) : e || (e = setTimeout(h, n));
        return f
    }
};
ww.util.getAudioContextConstructor = function () {
    return"undefined" !== typeof AudioContext ? AudioContext : "undefined" !== typeof webkitAudioContext ? webkitAudioContext : null
};
ww.util.getPointerEventNames = function (a, b) {
    var c = [], d, e;
    "up" === a ? (d = "touchend", e = "mouseup") : "move" === a ? (d = "touchmove", e = "mousemove") : "down" === a && (d = "touchstart", e = "mousedown");
    var f = navigator.userAgent.match(/(Windows)/i) ? !0 : !1, g = navigator.userAgent.match(/(Touch)/i) ? !0 : !1, h = navigator.userAgent.match(/(CrOS)/i) ? !0 : !1;
    f || h ? ((Modernizr.touch || g) && c.push(d + "." + b), c.push(e + "." + b)) : Modernizr.touch ? c.push(d + "." + b) : c.push(e + "." + b);
    return c.join(" ")
};
(function () {
    for (var a = 0, b = ["ms", "moz", "webkit", "o"], c = 0; c < b.length && !window.requestAnimationFrame; ++c)window.requestAnimationFrame = window[b[c] + "RequestAnimationFrame"], window.cancelAnimationFrame = window[b[c] + "CancelAnimationFrame"] || window[b[c] + "CancelRequestAnimationFrame"];
    window.requestAnimationFrame || (window.requestAnimationFrame = function (b) {
        var c = (new Date).getTime(), f = Math.max(0, 16 - (c - a)), g = window.setTimeout(function () {
            b(c + f)
        }, f);
        a = c + f;
        return g
    });
    window.cancelAnimationFrame || (window.cancelAnimationFrame =
        function (a) {
            clearTimeout(a)
        })
})();
ww.raf.subscribers_ = {};
ww.raf.isRunning_ = !1;
ww.raf.lastTime_ = 0;
ww.raf.currentFrame_ = null;
ww.raf.onFrame_ = function (a) {
    a = a || ww.util.rightNow();
    var b = a - ww.raf.lastTime_, c;
    for (c in ww.raf.subscribers_)if (ww.raf.subscribers_.hasOwnProperty(c)) {
        var d = ww.raf.subscribers_[c];
        d[1].call(d[0], b)
    }
    ww.raf.lastTime_ = a;
    ww.raf.isRunning_ && (ww.raf.currentFrame_ = requestAnimationFrame(ww.raf.onFrame_))
};
ww.raf.updateStatus_ = function () {
    var a = 0, b;
    for (b in ww.raf.subscribers_)ww.raf.subscribers_.hasOwnProperty(b) && a++;
    0 < a ? ww.raf.isRunning_ || (ww.raf.isRunning_ = !0, ww.raf.lastTime_ = ww.util.rightNow(), requestAnimationFrame(ww.raf.onFrame_)) : (ww.raf.isRunning_ = !1, ww.raf.currentFrame_ && (cancelAnimationFrame(ww.raf.currentFrame_), ww.raf.currentFrame_ = null))
};
ww.raf.subscribe = function (a, b, c) {
    ww.raf.subscribers_[a] = [b, c];
    ww.raf.updateStatus_()
};
ww.raf.unsubscribe = function (a) {
    delete ww.raf.subscribers_[a];
    ww.raf.updateStatus_()
};
ww.PatternMatcher = function (a) {
    this.currentPattern_ = "";
    this.maxPatternLength_ = 15;
    this.setupPatternMatchers_(a)
};
ww.PatternMatcher.prototype.setupPatternMatchers_ = function (a) {
    var b = {}, c, d;
    for (c in a)a.hasOwnProperty(c) && a[c].pattern && (d = a[c], b[c] = {klass:d.klass, binaryPattern:ww.util.pad(d.pattern.toString(2), d.len)});
    this.matchers_ = [];
    for (c in b)if (b.hasOwnProperty(c)) {
        d = b[c];
        for (a = 0; a < d.binaryPattern.length; a++)this.matchers_.push({key:c, matcher:RegExp("^" + d.binaryPattern.slice(0, a + 1)), isPartial:a + 1 != d.binaryPattern.length})
    }
};
ww.PatternMatcher.prototype.addCharacter = function (a, b) {
    this.currentPattern_ += a;
    this.currentPattern_.length > this.maxPatternLength_ && (this.currentPattern_ = this.currentPattern_.slice(-this.maxPatternLength_, this.currentPattern_.length));
    b(this.currentPattern_, this.runMatchers_())
};
ww.PatternMatcher.prototype.reset = function () {
    this.currentPattern_ = ""
};
ww.PatternMatcher.prototype.runMatchers_ = function () {
    for (var a = [], b = 0; b < this.matchers_.length; b++) {
        var c = this.matchers_[b], d = c.matcher.toString().length - 3;
        if (d === this.currentPattern_.length && c.matcher.test(this.currentPattern_) && (a.push({matcher:c, len:d, isPartial:c.isPartial}), !c.isPartial))return c
    }
    for (var e, c = b = 0; c < a.length; c++)a[c].len > b && (e = a[c].matcher, b = a[c].len);
    return e
};
ww.mode = {};
ww.mode.Core = function (a, b, c, d, e, f, g) {
    this.prefix_ = Modernizr.prefixed("transform");
    this.assetPrefix_ = b || "";
    this.containerElem_ = a;
    this.name_ = c;
    this.hasFocus = !1;
    a = ww.util.getAudioContextConstructor();
    if (this.wantsAudio_ = d && a || !1)ww.mode.Core.audioContext = ww.mode.Core.audioContext || new a, this.audioContext_ = ww.mode.Core.audioContext;
    this.wantsDrawing_ = e || !1;
    this.wantsPhysics_ = f || !1;
    this.wantsRetina_ = this.requestsRetina_ = g && 1 < window.devicePixelRatio || !1;
    this.wantsRenderLoop_ = this.wantsDrawing_ || this.wantsPhysics_ ||
        !1;
    this.$window_ = $(window);
    this.height_ = this.width_ = 0;
    this.$bounds = this.find(".bounds");
    this.$letterI_ = this.find(".letter-i");
    this.$letterO_ = this.find(".letter-o");
    var h = this;
    setTimeout(function () {
        h.log("Starting preload");
        h.loadSounds_(function () {
            h.log("Preload complete");
            h.init();
            h.onResize(!0);
            var a = ww.mode.findModeByName(h.name_);
            a.pattern && (h.$back = $('<div class="back"></div>'), h.$back.prependTo(h.containerElem_), a = ww.util.pad(a.pattern.toString(2), a.len), a = a.replace(/1/g, '<span class="i"></span>').replace(/0/g,
                '<span class="o"></span>'), $('<div class="code">' + a + "</div>").prependTo(h.containerElem_));
            h.focus_();
            h.ready_()
        })
    }, 10)
};
ww.mode.Core.prototype.find = function (a) {
    return $(this.containerElem_).find(a)
};
ww.mode.Core.prototype.log = function () {
};
ww.mode.Core.prototype.init = function () {
    this.log("Init");
    this.hasInited_ = !0;
    this.wantsPhysics_ && this.resetPhysicsWorld_();
    this.paperCanvas_ && (paper = this.paperScope_)
};
ww.mode.Core.prototype.bindEvent_ = function (a, b, c) {
    a = $(a);
    b = ww.util.getPointerEventNames(b, this.name_);
    a.bind(b, c)
};
ww.mode.Core.prototype.unbindEvent_ = function (a, b) {
    var c = $(a), d = ww.util.getPointerEventNames(b, this.name_);
    c.unbind(d)
};
ww.mode.Core.prototype.showReload = function (a, b) {
    var c = this;
    this.$reloadModal_ || (this.$reloadModal_ = $(this.containerElem_).find(".reload"), this.$reloadModal_.length || (this.$reloadModal_ = $("<div class='reload'></div>").appendTo(this.containerElem_)));
    this.$reloadModal_.hide();
    var d = ww.util.getPointerEventNames("up", "reload");
    this.$reloadModal_.bind(d, function () {
        b ? c.$reloadModal_.fadeOut() : c.$reloadModal_.hide();
        "function" === typeof a && a()
    });
    b ? this.$reloadModal_.fadeIn() : this.$reloadModal_.show()
};
ww.mode.Core.prototype.onResize = function (a) {
    this.width_ = $(this.containerElem_).width();
    this.height_ = $(this.containerElem_).height();
    this.requestsRetina_ && (this.wantsRetina_ = !(1024 < this.height_ || 1024 < this.width_));
    var b = 1;
    this.wantsRetina_ && (1024 === this.width_ && (this.width_ -= 2, this.height_ -= 2), b = 2);
    this.log("Resize " + this.width_ + "x" + this.height_);
    this.updateBounds();
    this.paperCanvas_ && (paper = this.paperScope_, this.paperCanvas_.width = this.width_ * b, this.paperCanvas_.height = this.height_ * b, paper.view.setViewSize(this.width_ *
        b, this.height_ * b), $(this.paperCanvas_).css({width:this.width_, height:this.height_}));
    a && this.redraw()
};
ww.mode.Core.prototype.updateBounds = function () {
    var a = 500, b = 0.75 * a, c = 30, d = 60, e = 20;
    this.width_ > this.height_ ? (a = this.height_ - d - e, this.boundsHeight_ = a = Math.min(b, a), this.boundsWidth_ = this.boundsHeight_ * (4 / 3)) : (b = this.width_ - 2 * c, this.boundsWidth_ = a = Math.min(a, b), this.boundsHeight_ = 0.75 * this.boundsWidth_);
    this.boundsCenterX_ = Math.floor(this.width_ / 2);
    this.boundsCenterY_ = Math.floor(this.height_ / 2);
    this.boundsX_ = this.boundsCenterX_ - Math.floor(this.boundsWidth_ / 2);
    this.boundsY_ = this.boundsCenterY_ - Math.floor(this.boundsHeight_ /
        2);
    this.$bounds.css({left:this.boundsX_, top:this.boundsY_, width:this.boundsWidth_, height:this.boundsHeight_})
};
ww.mode.Core.prototype.startRendering = function () {
    this.wantsRenderLoop_ && (this.timeElapsed_ = this.framesRendered_ = 0, ww.raf.subscribe(this.name_, this, this.renderFrame))
};
ww.mode.Core.prototype.stopRendering = function () {
    this.wantsRenderLoop_ && ww.raf.unsubscribe(this.name_)
};
ww.mode.Core.prototype.renderFrame = function (a) {
    this.timeElapsed_ += a;
    a *= 0.001;
    0.5 < a && (a = 0.016);
    this.wantsPhysics_ && this.stepPhysics(a);
    TWEEN.update(this.timeElapsed_);
    if (this.wantsDrawing_)this.onFrame(a);
    this.framesRendered_++
};
ww.mode.Core.prototype.redraw = function () {
    if (this.wantsDrawing_)this.onFrame(0)
};
ww.mode.Core.prototype.onFrame = function () {
    if (this.paperCanvas_ && 0 < this.paperCanvas_.width && 0 < this.paperCanvas_.height) {
        var a = 1;
        this.wantsRetina_ && (a = 2);
        paper = this.paperScope_;
        var b = this.paperCanvas_.getContext("2d");
        b.save();
        b.scale(a, a);
        paper.view.draw();
        b.restore()
    }
};
ww.mode.Core.prototype.loadSounds_ = function (a) {
    if (this.wantsAudio_) {
        var b = this, c = 0, d;
        for (d in this.unloadedSounds_)this.unloadedSounds_.hasOwnProperty(d) && c++;
        if (0 >= c)a(); else for (d in this.unloadedSounds_)this.unloadedSounds_.hasOwnProperty(d) && function (d) {
            var f = b.assetPrefix_ + "sounds/" + b.name_ + "/" + d;
            b.log('Requested sound "' + f + '"');
            b.fetchSoundBufferFromURL_(f, function () {
                c--;
                delete b.unloadedSounds_[f];
                0 === c && a()
            })
        }(d)
    } else a()
};
ww.mode.Core.prototype.ready_ = function () {
    if (window.onModeReady)window.onModeReady(this);
    this.log("Is ready");
    this.sendMessage_(this.name_ + ".ready")
};
ww.mode.Core.prototype.postMessage = function (a) {
    this.log("Got message: " + a.name, a);
    "focus" === a.name ? this.focus_() : "unfocus" === a.name && this.unfocus_()
};
ww.mode.Core.prototype.sendMessage_ = function (a, b) {
    window.app && window.app.postMessage && window.app.postMessage({name:a, data:b})
};
ww.mode.Core.prototype.goBack = function () {
    this.sendMessage_("goToHome")
};
ww.mode.Core.prototype.trackEvent_ = function (a, b) {
    var c = "mode-" + this._name;
    ww.util.trackEvent(c, a, b)
};
ww.mode.Core.prototype.focus_ = function () {
    this.hasFocus || (this.paperCanvas_ && (paper = this.paperScope_), this.hasInited_ && this.init(), this.willFocus(), this.log("Got focus"), this.hasFocus = !0, this.startRendering(), this.didFocus())
};
ww.mode.Core.prototype.willFocus = function () {
};
ww.mode.Core.prototype.didFocus = function () {
    var a = this, b = ww.util.getPointerEventNames("up", this.name_);
    this.$letterI_.bind(b, function () {
        a.activateI()
    });
    this.$letterO_.bind(b, function () {
        a.activateO()
    });
    this.$back && this.$back.bind(b, function () {
        a.goBack()
    });
    $(document).bind("keyup." + this.name_, function (b) {
        if (105 === b.keyCode || 49 === b.keyCode || 73 === b.keyCode)a.activateI(); else if (111 === b.keyCode || 48 === b.keyCode || 79 === b.keyCode)a.activateO(); else if (27 === b.keyCode)a.goBack(); else return;
        b.preventDefault();
        b.stopPropagation();
        return!1
    })
};
ww.mode.Core.prototype.unfocus_ = function () {
    this.hasFocus && (this.log("Lost focus"), this.hasFocus = !1, this.stopRendering(), this.didUnfocus())
};
ww.mode.Core.prototype.didUnfocus = function () {
    var a = ww.util.getPointerEventNames("up", this.name_);
    this.$letterI_.unbind(a);
    this.$letterO_.unbind(a);
    this.$back && this.$back.unbind(a);
    this.$reloadModal_ && (this.$reloadModal_.hide(), this.$reloadModal_.unbind(ww.util.getPointerEventNames("up", "reload")));
    $(document).unbind("keyup." + this.name_)
};
ww.mode.Core.prototype.getLoadedSoundBufferFromURL_ = function (a) {
    this.soundBuffersFromURL_ = this.soundBuffersFromURL_ || {};
    if (this.soundBuffersFromURL_[a])return this.soundBuffersFromURL_[a]
};
ww.mode.Core.prototype.fetchSoundBufferFromURL_ = function (a, b) {
    this.soundBuffersFromURL_ = this.soundBuffersFromURL_ || {};
    b = b || function () {
    };
    if (this.soundBuffersFromURL_[a])b(this.soundBuffersFromURL_[a]); else {
        var c = new XMLHttpRequest;
        c.open("GET", a, !0);
        c.responseType = "arraybuffer";
        var d = this;
        c.onload = function () {
            var e = d.getAudioContext_();
            e.decodeAudioData(c.response, function (c) {
                d.soundBuffersFromURL_[a] = c;
                b(d.soundBuffersFromURL_[a])
            })
        };
        c.send()
    }
};
ww.mode.Core.prototype.getPhysicsWorld_ = function (a) {
    return this.physicsWorld_ ? this.physicsWorld_ : this.physicsWorld_ = new Physics(a)
};
ww.mode.Core.prototype.resetPhysicsWorld_ = function () {
    this.physicsWorld_ && this.physicsWorld_.destroy && this.physicsWorld_.destroy();
    this.physicsWorld_ = null
};
ww.mode.Core.prototype.stepPhysics = function (a) {
    if (0 < a) {
        var b = this.getPhysicsWorld_();
        b.integrate(a);
        if (this.paperCanvas_)for (a = 0; a < b.particles.length; a++) {
            var c = b.particles[a];
            "undefined" !== typeof c.drawObj && c.drawObj.position && (c.drawObj.position.x = c.pos.x, c.drawObj.position.y = c.pos.y)
        }
    }
};
ww.mode.Core.prototype.getAudioContext_ = function () {
    return this.audioContext_
};
ww.mode.Core.prototype.preloadSound = function (a) {
    this.unloadedSounds_ = this.unloadedSounds_ || {};
    this.unloadedSounds_[a] = !0
};
ww.mode.Core.prototype.playSound = function (a, b, c) {
    if (this.wantsAudio_) {
        var d = this.assetPrefix_ + "sounds/" + this.name_ + "/" + a;
        this.log('Playing sound "' + a + '"');
        a = this.getAudioContext_();
        var d = this.getLoadedSoundBufferFromURL_(d), e = a.createBufferSource(), f = a.createGainNode();
        f.gain.value = 0.1;
        e.buffer = d;
        e.loop = c || !1;
        e.connect(f);
        f.connect(a.destination);
        e.noteOn(0);
        "function" === typeof b && b(e)
    }
};
ww.mode.Core.prototype.activateI = function () {
    this.log('Activated "I"');
    this.trackEvent_("activated-i")
};
ww.mode.Core.prototype.activateO = function () {
    this.log('Activated "O"');
    this.trackEvent_("activated-o")
};
ww.mode.Core.prototype.transformElem_ = function (a, b) {
    a.style[this.prefix_] = b
};
ww.mode.Core.prototype.getPaperCanvas_ = function (a) {
    if (!this.paperCanvas_) {
        this.paperCanvas_ = document.createElement("canvas");
        var b = 1;
        this.wantsRetina_ && (b = 2);
        this.paperCanvas_.width = this.width_ * b;
        this.paperCanvas_.height = this.height_ * b;
        $(this.paperCanvas_).css({width:this.width_, height:this.height_});
        $(this.containerElem_).prepend(this.paperCanvas_);
        paper = new paper.PaperScope;
        paper.setup(this.paperCanvas_);
        this.paperScope_ = paper;
        a && $(this.paperCanvas_).remove()
    }
    return this.paperCanvas_
};
ww.mode.Core.prototype.addTween = function (a) {
    a.start(this.timeElapsed_)
};
ww.mode.Core.prototype.getCoords = function (a) {
    var b = [
        {x:0, y:0}
    ];
    a.originalEvent.changedTouches ? (b.x = a.originalEvent.changedTouches[0].pageX, b.y = a.originalEvent.changedTouches[0].pageY) : (b.x = a.pageX, b.y = a.pageY);
    return b
};
ww.mode.Core.prototype.setPaperShapeData = function () {
    this.iWidth = 0.2 * this.boundsWidth_;
    this.iHeight = 0.43058824 * this.boundsWidth_;
    this.iX = this.boundsX_ + 0.10352941 * this.boundsWidth_;
    this.iY = this.boundsY_ + 0.16 * this.boundsWidth_;
    this.iCenter = new paper.Point(this.iX + this.iWidth / 2, this.iY + this.iHeight / 2);
    this.oRad = 0.22588235 * this.boundsWidth_;
    this.oX = this.boundsX_ + 0.69647059 * this.boundsWidth_;
    this.oY = this.boundsY_ + 0.37411765 * this.boundsWidth_;
    this.oCenter = new paper.Point(this.oX, this.oY);
    this.slashStartX =
        this.boundsX_ + 0.50352941 * this.boundsWidth_;
    this.slashStartY = this.boundsY_ + 0.06823529 * this.boundsWidth_;
    this.slashEndX = this.boundsX_ + 0.32 * this.boundsWidth_;
    this.slashEndY = this.boundsY_ + 0.68705882 * this.boundsWidth_;
    this.slashWidth = 0.02212389 * this.boundsWidth_;
    this.find(".year-mark") && this.find(".year-mark").css({left:this.boundsX_ + 0.85411765 * this.boundsWidth_, top:this.boundsY_ + 0.08705882 * this.boundsWidth_})
};
ww.mode.AsciiMode = function (a, b) {
    this.preloadSound("i.mp3");
    this.preloadSound("o.mp3");
    ww.mode.Core.call(this, a, b, "ascii", !0, !0, !0);
    this.getPaperCanvas_(!0)
};
goog.inherits(ww.mode.AsciiMode, ww.mode.Core);
ww.mode.AsciiMode.prototype.activateI = function () {
    ww.mode.AsciiMode.superClass_.activateI.call(this);
    this.pushPoints_(this.paperI_, this.lastClick_, 10);
    this.playSound("i.mp3")
};
ww.mode.AsciiMode.prototype.activateO = function () {
    ww.mode.AsciiMode.superClass_.activateO.call(this);
    this.pushPoints_(this.paperO_, this.lastClick_, 10);
    this.playSound("o.mp3")
};
ww.mode.AsciiMode.prototype.drawI_ = function () {
    this.paperI_ && this.paperI_.remove();
    var a = new paper.Point(this.iX, this.iY), b = new paper.Size(this.iWidth, this.iHeight), a = new paper.Rectangle(a, b);
    this.paperI_ = new paper.Path.Rectangle(a);
    this.paperI_.closed = !0;
    this.paperI_.vectors = [];
    for (a = 0; a < this.paperI_.segments.length; a++)b = this.paperI_.segments[a].point.clone(), b = b.subtract(this.iCenter), b.velocity = 0, b.acceleration = 5 * Math.random() + 10, b.bounce = 0.1 * Math.random() + 1.05, this.paperI_.vectors.push(b)
};
ww.mode.AsciiMode.prototype.fillI_ = function () {
    var a = [
        ["#000", 0],
        ["#eee", 1]
    ], a = new paper.Gradient(a), b = this.paperI_.position.clone();
    b.x -= this.iWidth / 2;
    var c = this.paperI_.position.clone();
    c.x += this.iWidth / 2;
    a = new paper.GradientColor(a, b, c);
    this.paperI_.fillColor = a
};
ww.mode.AsciiMode.prototype.drawO_ = function () {
    this.paperO_ && this.paperO_.remove();
    this.paperO_ = new paper.Path.RegularPolygon(this.oCenter, 6, this.oRad);
    this.paperO_.smooth();
    this.paperO_.vectors = [];
    for (var a = 0; a < this.paperO_.segments.length; a++) {
        var b = this.paperO_.segments[a].point.clone(), b = b.subtract(this.oCenter);
        b.velocity = 0;
        b.acceleration = 5 * Math.random() + 10;
        b.bounce = 0.1 * Math.random() + 1.05;
        this.paperO_.vectors.push(b)
    }
};
ww.mode.AsciiMode.prototype.fillO_ = function () {
    var a = [
        ["#000", 0],
        ["#eee", 1]
    ], a = new paper.Gradient(a), b = this.paperO_.position.clone();
    b.x -= this.oRad;
    var c = this.paperO_.position.clone();
    c.x += this.oRad;
    a = new paper.GradientColor(a, b, c);
    this.paperO_.fillColor = a
};
ww.mode.AsciiMode.prototype.drawSlash_ = function () {
    this.paperSlash_ ? (this.slashStart_.x = this.slashStartX, this.slashStart_.y = this.slashStartY, this.slashEnd_.x = this.slashEndX, this.slashEnd_.y = this.slashEndY, this.paperSlash_.segments[0].point = this.slashStart_, this.paperSlash_.segments[1].point = this.slashEnd_, this.paperSlash_.strokeWidth = this.slashWidth) : (this.slashStart_ = new paper.Point(this.slashStartX, this.slashStartY), this.slashEnd_ = new paper.Point(this.slashEndX, this.slashEndY), this.paperSlash_ = new paper.Path,
        this.paperSlash_.strokeWidth = this.slashWidth, this.paperSlash_.strokeColor = "#ebebeb", this.paperSlash_.add(this.slashStart_, this.slashEnd_))
};
ww.mode.AsciiMode.prototype.draw13_ = function (a) {
    a.css({width:0.33333333 * this.oRad, height:0.25555556 * this.oRad, left:this.oX + 0.38888889 * this.oRad, top:this.oY - this.oRad - 0.37777778 * this.oRad})
};
ww.mode.AsciiMode.prototype.init = function () {
    ww.mode.AsciiMode.superClass_.init.call(this);
    this.world_ = this.getPhysicsWorld_();
    this.lastClick_ = new paper.Point(this.oX, this.oY);
    0 < this.paperCanvas_.height && (this.drawSlash_(), this.drawI_(), this.drawO_())
};
ww.mode.AsciiMode.prototype.didFocus = function () {
    ww.mode.AsciiMode.superClass_.didFocus.call(this);
    this.$canvas_ = $("#ascii-canvas");
    this.$canvas_.css({"z-index":3});
    this.canvas_ = this.$canvas_[0];
    this.canvas_.width = this.width_;
    this.canvas_.height = this.height_;
    var a = this, b = ww.util.getPointerEventNames("down", this.name_);
    this.$canvas_.bind(b, function (b) {
        b.preventDefault();
        b.stopPropagation();
        a.lastClick_ = new paper.Point(a.getCoords(b).x, a.getCoords(b).y);
        a.lastClick_.getDistance(a.paperO_.position) < a.oRad &&
            a.hasFocus && a.activateO();
        Math.abs(a.lastClick_.x - a.paperI_.position.x) < a.iWidth / 2 && Math.abs(a.lastClick_.y - a.paperI_.position.y) < a.iHeight / 2 && a.hasFocus && a.activateI()
    });
    b = ww.util.getPointerEventNames("move", this.name_);
    this.$canvas_.bind(b, function (b) {
        b.preventDefault();
        b.stopPropagation();
        b = new paper.Point(a.getCoords(b).x, a.getCoords(b).y);
        b.getDistance(a.paperO_.position) < a.oRad || Math.abs(b.x - a.paperI_.position.x) < a.iWidth / 2 && Math.abs(b.y - a.paperI_.position.y) < a.iHeight / 2 ? a.hasFocus && (document.getElementById("ascii-canvas").style.cursor =
            "pointer") : document.getElementById("ascii-canvas").style.cursor = "default"
    })
};
ww.mode.AsciiMode.prototype.didUnfocus = function () {
    ww.mode.AsciiMode.superClass_.didUnfocus.call(this);
    var a = ww.util.getPointerEventNames("down", this.name_);
    this.$canvas_.unbind(a);
    a = ww.util.getPointerEventNames("move", this.name_);
    this.$canvas_.unbind(a)
};
ww.mode.AsciiMode.prototype.onResize = function (a) {
    ww.mode.AsciiMode.superClass_.onResize.call(this, !1);
    this.setPaperShapeData();
    this.drawSlash_();
    this.drawI_();
    this.drawO_();
    a && this.redraw()
};
ww.mode.AsciiMode.prototype.pushPoints_ = function (a, b, c) {
    for (var d = 0; d < a.vectors.length; d++) {
        var e = a.vectors[d], f;
        a === this.paperO_ ? (f = e.add(this.oCenter), f = f.subtract(b), f = Math.max(0, this.oRad - f.length)) : (f = e.add(this.iCenter), f = f.subtract(b), f = Math.max(0, this.iWidth - f.length));
        e.length += Math.max(4 * f, 100);
        e.velocity += c;
        e.velocity = Math.min(5, e.velocity)
    }
};
ww.mode.AsciiMode.prototype.updateVectors_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], d = new paper.Point(this.iX, this.iY);
        c.velocity = a === this.paperO_ ? ((this.oRad - c.length) / c.acceleration + c.velocity) / c.bounce : ((d.getDistance(this.iCenter) - c.length) / c.acceleration + c.velocity) / c.bounce;
        c.length = Math.max(0, c.length + c.velocity)
    }
};
ww.mode.AsciiMode.prototype.updatePoints_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], c = c.clone();
        a === this.paperO_ ? (this.paperO_.segments[b].point = c.add(this.oCenter), this.paperO_.smooth()) : this.paperI_.segments[b].point = c.add(this.iCenter)
    }
};
ww.mode.AsciiMode.prototype.stepPhysics = function (a) {
    ww.mode.AsciiMode.superClass_.stepPhysics.call(this, a);
    this.paperI_ && this.paperO_ && (this.fillI_(), this.fillO_(), this.updateVectors_(this.paperI_), this.updatePoints_(this.paperI_), this.updateVectors_(this.paperO_), this.updatePoints_(this.paperO_))
};
ww.mode.AsciiMode.prototype.onFrame = function (a) {
    ww.mode.AsciiMode.superClass_.onFrame.call(this, a);
    this.asciifyCanvas_(this.paperCanvas_)
};
ww.mode.BaconMode = function (a, b) {
    this.preloadSound("bacon-sizzle.mp3");
    this.preloadSound("egg-cracked.mp3");
    this.preloadSound("cracked-open.mp3");
    this.preloadSound("eggs-sizzling.mp3");
    ww.mode.Core.call(this, a, b, "bacon", !0, !0, !1)
};
goog.inherits(ww.mode.BaconMode, ww.mode.Core);
ww.mode.BaconMode.prototype.init = function () {
    ww.mode.BaconMode.superClass_.init.call(this);
    this.stillHasShell = !0;
    this.eggWhole_ = $("#egg-whole").css("opacity", 1)[0];
    this.cracks_ = $("[id*=crack-]").css("opacity", 0);
    this.currentCrack_ = 0;
    this.totalCracks_ = this.cracks_.length;
    this.whites_ = $("#egg-whites");
    this.eggOpened_ = $("#egg-cracked").css("opacity", 0);
    this.center_ = this.eggOpened_.attr("cx") + ", " + this.eggOpened_.attr("cy")
};
ww.mode.BaconMode.prototype.activateI = function () {
    ww.mode.BaconMode.superClass_.activateI.call(this);
    var a = this;
    this.playSound("bacon-sizzle.mp3");
    var b = new TWEEN.Tween({scaleY:1, translateY:0});
    b.to({scaleY:1.25, translateY:-20}, 700);
    b.easing(TWEEN.Easing.Elastic.In);
    b.onUpdate(function () {
        a.$letterI_.attr("transform", "scale(1, " + this.scaleY + ") translate(0, " + this.translateY + ")")
    });
    var c = new TWEEN.Tween({scaleY:1.25, translateY:-20});
    c.to({scaleY:1, translateY:0}, 700);
    c.easing(TWEEN.Easing.Elastic.Out);
    c.delay(700);
    c.onUpdate(function () {
        a.$letterI_.attr("transform", "scale(1, " + this.scaleY + ") translate(0, " + this.translateY + ")")
    });
    this.addTween(b);
    this.addTween(c)
};
ww.mode.BaconMode.prototype.activateO = function () {
    ww.mode.BaconMode.superClass_.activateO.call(this);
    this.currentCrack_ < this.totalCracks_ ? (this.cracks_[this.currentCrack_].style.opacity = 1, this.currentCrack_++, this.playSound("egg-cracked.mp3")) : this.stillHasShell ? (this.playSound("cracked-open.mp3"), this.showCracked_()) : (this.playSound("eggs-sizzling.mp3"), this.animateSpinEgg_())
};
ww.mode.BaconMode.prototype.showCracked_ = function () {
    var a = this, b = new TWEEN.Tween({opacity:1});
    b.to({opacity:0}, 200);
    b.onUpdate(function () {
        a.eggWhole_.style.opacity = this.opacity
    });
    b.onComplete(function () {
        a.eggOpened_.css("opacity", 1);
        a.stillHasShell = !1;
        a.animateSpinEgg_()
    });
    this.eggOpened_.css("opacity", 0);
    this.addTween(b)
};
ww.mode.BaconMode.prototype.animateSpinEgg_ = function () {
    var a = this, b = -1 * ~~(250 * Math.random() + 20), c = a.eggOpened_.attr("transform") || "", c = parseInt(c.split("rotate(")[1], 10) || 0, d = ~~Random(-20, 20), e = new TWEEN.Tween({rotate:c});
    e.to({rotate:(c + b / 2) / window.devicePixelRatio}, 500);
    e.easing(TWEEN.Easing.Elastic.In);
    e.onUpdate(function () {
        a.whites_.attr("transform", "rotate(" + (this.rotate - d) + ", " + a.center_ + ")");
        a.eggOpened_.attr("transform", "rotate(" + this.rotate + ", " + a.center_ + ")")
    });
    a.addTween(e)
};
ww.mode.BowlingMode = function (a, b) {
    this.preloadSound("strike.mp3");
    this.preloadSound("whoosh-1.mp3");
    ww.mode.Core.call(this, a, b, "bowling", !0, !0, !1)
};
goog.inherits(ww.mode.BowlingMode, ww.mode.Core);
ww.mode.BowlingMode.prototype.init = function () {
    ww.mode.BowlingMode.superClass_.init.call(this);
    this.ballWrapper_ = this.find(".letter-o-wrapper");
    this.centerX_ = this.$letterO_.attr("cx");
    this.centerY_ = this.$letterO_.attr("cy");
    this.ballCenter_ = [this.centerX_, this.centerY_];
    this.pinCenter_ = [this.$letterI_.attr("cx"), this.$letterI_.attr("cy")];
    this.isBowling_ = !1
};
ww.mode.BowlingMode.prototype.activateI = function () {
    ww.mode.BowlingMode.superClass_.activateI.call(this);
    if (!this.isBowling_) {
        var a = this, b = 5, c = new TWEEN.Tween({rotate:0});
        c.to({rotate:-b}, 100);
        c.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.pinCenter_[0] + ", " + a.pinCenter_[1] + ")")
        });
        var d = new TWEEN.Tween({rotate:-b});
        d.to({rotate:b}, 200);
        d.onStart(function () {
            a.playSound("whoosh-1.mp3")
        });
        d.delay(100);
        d.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate +
                ", " + a.pinCenter_[0] + ", " + a.pinCenter_[1] + ")")
        });
        b = new TWEEN.Tween({rotate:b});
        b.to({rotate:0}, 100);
        b.delay(300);
        b.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.pinCenter_[0] + ", " + a.pinCenter_[1] + ")")
        });
        this.addTween(c);
        this.addTween(d);
        this.addTween(b)
    }
};
ww.mode.BowlingMode.prototype.activateO = function () {
    ww.mode.BowlingMode.superClass_.activateO.call(this);
    this.playSound("strike.mp3");
    if (!this.isBowling_) {
        this.isBowling_ = !0;
        var a = this, b = ~~Random(360, 380), c = this.ballWrapper_[0].getBoundingClientRect(), d = this.$letterI_[0].getBoundingClientRect(), e = c.width / 3 + c.left - d.right, c = new TWEEN.Tween({rotate:0});
        c.to({rotate:1800}, 1500);
        c.onUpdate(function () {
            a.$letterO_.attr("transform", "rotate(" + this.rotate % 360 + ", " + a.centerX_ + ", " + a.centerY_ + ")")
        });
        d = new TWEEN.Tween({translateX:0});
        d.to({translateX:e}, 600);
        d.delay(1E3);
        d.easing(TWEEN.Easing.Exponential.In);
        d.onUpdate(function () {
            a.ballWrapper_.attr("transform", "translate(" + -this.translateX + ", 0)")
        });
        e = new TWEEN.Tween({rotate:0, scale:1, posX:0});
        e.to({rotate:b, scale:0.5, posX:-20}, 300);
        e.delay(1500);
        e.onUpdate(function () {
            a.$letterI_.attr("transform", "scale(" + this.scale + ") rotate(" + this.rotate + ", " + a.pinCenter_[0] + ", " + a.pinCenter_[1] + ") translate(" + this.posX + ", 0)")
        });
        b = new TWEEN.Tween({opacity:0});
        b.to({opacity:1}, 500);
        b.delay(3E3);
        b.onStart(function () {
            a.ballWrapper_.attr("transform", "translate(0, 0)");
            a.$letterO_.attr("transform", "rotate(0, " + a.ballCenter_[0] + ", " + a.ballCenter_[1] + ")");
            a.$letterI_.attr("transform", "scale(1) rotate(0, " + a.pinCenter_[0] + ", " + a.pinCenter_[1] + ") translate(0, 0)")
        });
        b.onUpdate(function () {
            a.$letterO_[0].style.opacity = this.opacity;
            a.$letterI_[0].style.opacity = this.opacity;
            a.ballWrapper_[0].style.opacity = this.opacity
        });
        b.onComplete(function () {
            a.isBowling_ = !1
        });
        this.addTween(c);
        this.addTween(d);
        this.addTween(e);
        this.addTween(b)
    }
};
ww.mode.BurgerMode = function (a, b) {
    this.preloadSound("bite-1.mp3");
    this.preloadSound("bite-2.mp3");
    ww.mode.Core.call(this, a, b, "burger", !0, !0, !1)
};
goog.inherits(ww.mode.BurgerMode, ww.mode.Core);
ww.mode.BurgerMode.prototype.init = function () {
    ww.mode.BurgerMode.superClass_.init.call(this);
    this.bitesI_ = $("[id*=hot-dog-bite-]");
    this.maxBitesI_ = this.bitesI_.length;
    this.bitesO_ = $("[id*=burger-bite-]");
    this.maxBitesO_ = this.bitesO_.length
};
ww.mode.BurgerMode.prototype.didFocus = function () {
    ww.mode.BurgerMode.superClass_.didFocus.call(this);
    this.bitesI_.css("opacity", 0);
    this.biteIIndex_ = 0;
    this.bitesO_.css("opacity", 0);
    this.biteOIndex_ = 0;
    this.isReset = !0
};
ww.mode.BurgerMode.prototype.activateI = function () {
    ww.mode.BurgerMode.superClass_.activateI.call(this);
    this.biteIIndex_ < this.maxBitesI_ && (this.bitesI_[this.biteIIndex_].style.opacity = 1, this.biteIIndex_++, this.playSound("bite-2.mp3"));
    if (this.isReset && this.biteIIndex_ === this.maxBitesI_) {
        var a = this, b = new TWEEN.Tween({opacity:0});
        b.to({opacity:1}, 200);
        b.delay(500);
        b.onStart(function () {
            a.bitesI_.css("opacity", 0)
        });
        b.onUpdate(function () {
            a.$letterI_.css("opacity", this.opacity)
        });
        b.onComplete(function () {
            a.isReset =
                !0;
            a.biteIIndex_ = 0
        });
        this.isReset = !1;
        this.addTween(b)
    }
};
ww.mode.BurgerMode.prototype.activateO = function () {
    ww.mode.BurgerMode.superClass_.activateO.call(this);
    this.biteOIndex_ < this.maxBitesO_ && (this.bitesO_[this.biteOIndex_].style.opacity = 1, this.biteOIndex_++, this.playSound("bite-1.mp3"));
    if (this.isReset && this.biteOIndex_ === this.maxBitesO_) {
        var a = this, b = new TWEEN.Tween({opacity:0});
        b.to({opacity:1}, 200);
        b.delay(500);
        b.onStart(function () {
            a.bitesO_.css("opacity", 0)
        });
        b.onUpdate(function () {
            a.$letterO_.css("opacity", this.opacity)
        });
        b.onComplete(function () {
            a.isReset =
                !0;
            a.biteOIndex_ = 0
        });
        this.isReset = !1;
        this.addTween(b)
    }
};
ww.mode.CatMode = function (a, b) {
    this.preloadSound("cat-1.mp3");
    this.preloadSound("cat-2.mp3");
    ww.mode.Core.call(this, a, b, "cat", !0, !0)
};
goog.inherits(ww.mode.CatMode, ww.mode.Core);
ww.mode.CatMode.prototype.activateI = function () {
    ww.mode.CatMode.superClass_.activateI.call(this);
    this.playSound("cat-1.mp3");
    var a = this, b = new TWEEN.Tween({scaleY:1});
    b.to({scaleY:1.55}, 200);
    b.easing(TWEEN.Easing.Bounce.InOut);
    b.onUpdate(function () {
        a.transformElem_(a.$letterI_[0], "scaleY(" + this.scaleY + ")")
    });
    var c = new TWEEN.Tween({scaleY:1.55});
    c.to({scaleY:1}, 200);
    c.easing(TWEEN.Easing.Bounce.InOut);
    c.delay(200);
    c.onUpdate(function () {
        a.transformElem_(a.$letterI_[0], "scaleY(" + this.scaleY + ")")
    });
    this.addTween(b);
    this.addTween(c)
};
ww.mode.CatMode.prototype.activateO = function () {
    ww.mode.CatMode.superClass_.activateO.call(this);
    this.playSound("cat-2.mp3");
    var a = this, b = [~~Random(-50, 50), ~~Random(-50, 50)], c = new TWEEN.Tween({scale:1, x:0, y:0});
    c.to({scale:1.5, x:b[0], y:b[1]}, 200);
    c.easing(TWEEN.Easing.Bounce.InOut);
    c.onUpdate(function () {
        var b = "translate(" + this.x + "px, " + this.y + "px) ", b = b + ("scale(" + this.scale + ")");
        a.transformElem_(a.$letterO_[0], b)
    });
    b = new TWEEN.Tween({scale:1.5, x:b[0], y:b[1]});
    b.to({scale:1, x:0, y:0}, 200);
    b.delay(200);
    b.easing(TWEEN.Easing.Bounce.InOut);
    b.onUpdate(function () {
        var b = "translate(" + this.x + "px, " + this.y + "px) ", b = b + ("scale(" + this.scale + ")");
        a.transformElem_(a.$letterO_[0], b)
    });
    this.addTween(c);
    this.addTween(b)
};
ww.mode.DonutMode = function (a, b) {
    this.preloadSound("bite-1.mp3");
    this.preloadSound("bite-2.mp3");
    ww.mode.Core.call(this, a, b, "donut", !0, !0, !1)
};
goog.inherits(ww.mode.DonutMode, ww.mode.Core);
ww.mode.DonutMode.prototype.init = function () {
    ww.mode.DonutMode.superClass_.init.call(this);
    this.bitesI_ = $("[id*=bar-bite-]");
    this.maxBitesI_ = this.bitesI_.length;
    this.bitesO_ = $("[id*=donut-bite-]");
    this.maxBitesO_ = this.bitesO_.length;
    this.isReset = !0
};
ww.mode.DonutMode.prototype.didFocus = function () {
    ww.mode.DonutMode.superClass_.didFocus.call(this);
    this.bitesI_.css("opacity", 0);
    this.biteIIndex_ = 0;
    this.bitesO_.css("opacity", 0);
    this.biteOIndex_ = 0
};
ww.mode.DonutMode.prototype.activateI = function () {
    ww.mode.DonutMode.superClass_.activateI.call(this);
    this.biteIIndex_ < this.maxBitesI_ && (this.bitesI_[this.biteIIndex_].style.opacity = 1, this.biteIIndex_++, this.playSound("bite-2.mp3"));
    if (this.isReset && this.biteIIndex_ === this.maxBitesI_) {
        var a = this, b = new TWEEN.Tween({opacity:0});
        b.to({opacity:1}, 200);
        b.delay(500);
        b.onStart(function () {
            a.bitesI_.css("opacity", 0)
        });
        b.onUpdate(function () {
            a.$letterI_.css("opacity", this.opacity)
        });
        b.onComplete(function () {
            a.isReset =
                !0;
            a.biteIIndex_ = 0
        });
        this.isReset = !1;
        this.addTween(b)
    }
};
ww.mode.DonutMode.prototype.activateO = function () {
    ww.mode.DonutMode.superClass_.activateO.call(this);
    this.biteOIndex_ < this.maxBitesO_ && (this.bitesO_[this.biteOIndex_].style.opacity = 1, this.biteOIndex_++, this.playSound("bite-1.mp3"));
    if (this.isReset && this.biteOIndex_ === this.maxBitesO_) {
        var a = this, b = new TWEEN.Tween({opacity:0});
        b.to({opacity:1}, 200);
        b.delay(500);
        b.onStart(function () {
            a.bitesO_.css("opacity", 0)
        });
        b.onUpdate(function () {
            a.$letterO_.css("opacity", this.opacity)
        });
        b.onComplete(function () {
            a.isReset =
                !0;
            a.biteOIndex_ = 0
        });
        this.isReset = !1;
        this.addTween(b)
    }
};
ww.mode.EightBitMode = function (a, b) {
    this.preloadSound("i.mp3");
    this.preloadSound("o.mp3");
    this.preloadSound("error.mp3");
    ww.mode.Core.call(this, a, b, "eightbit", !0, !0, !0, !1);
    this.getPaperCanvas_(!0);
    this.frontmostWantsRetina_ = this.frontmostRequestsRetina_ = 1 < window.devicePixelRatio;
    this.canvas_ = document.getElementById("eightbit-canvas")
};
goog.inherits(ww.mode.EightBitMode, ww.mode.Core);
ww.mode.EightBitMode.prototype.activateI = function () {
    ww.mode.EightBitMode.superClass_.activateI.call(this);
    this.pushPoints_(this.paperI_, this.lastClick_, 10);
    this.playSound("i.mp3")
};
ww.mode.EightBitMode.prototype.activateO = function () {
    ww.mode.EightBitMode.superClass_.activateO.call(this);
    this.pushPoints_(this.paperO_, this.lastClick_, 10);
    this.playSound("o.mp3")
};
ww.mode.EightBitMode.prototype.drawI_ = function () {
    this.paperI_ && this.paperI_.remove();
    var a = new paper.Point(this.iX, this.iY), b = new paper.Size(this.iWidth, this.iHeight), a = new paper.Rectangle(a, b);
    this.paperI_ = new paper.Path.Rectangle(a);
    this.paperI_.closed = !0;
    this.paperI_.vectors = [];
    for (a = 0; a < this.paperI_.segments.length; a++)b = this.paperI_.segments[a].point.clone(), b = b.subtract(this.iCenter), b.velocity = 0, b.acceleration = 5 * Math.random() + 10, b.bounce = 0.1 * Math.random() + 1.05, this.paperI_.vectors.push(b)
};
ww.mode.EightBitMode.prototype.fillI_ = function () {
    var a = [
        ["#4487fc", 0],
        ["#826eb1", 1]
    ], a = new paper.Gradient(a), b = this.paperI_.position.clone();
    b.x -= this.iWidth / 2;
    var c = this.paperI_.position.clone();
    c.x += this.iWidth / 2;
    a = new paper.GradientColor(a, b, c);
    this.paperI_.fillColor = a
};
ww.mode.EightBitMode.prototype.drawO_ = function () {
    this.paperO_ && this.paperO_.remove();
    this.paperO_ = new paper.Path.RegularPolygon(this.oCenter, 6, this.oRad);
    this.paperO_.smooth();
    this.paperO_.vectors = [];
    for (var a = 0; a < this.paperO_.segments.length; a++) {
        var b = this.paperO_.segments[a].point.clone(), b = b.subtract(this.oCenter);
        b.velocity = 0;
        b.acceleration = 5 * Math.random() + 10;
        b.bounce = 0.1 * Math.random() + 1.05;
        this.paperO_.vectors.push(b)
    }
};
ww.mode.EightBitMode.prototype.fillO_ = function () {
    var a = [
        ["#93689c", 0],
        ["#df4a40", 1]
    ], a = new paper.Gradient(a), b = this.paperO_.position.clone();
    b.x -= this.oRad;
    var c = this.paperO_.position.clone();
    c.x += this.oRad;
    a = new paper.GradientColor(a, b, c);
    this.paperO_.fillColor = a
};
ww.mode.EightBitMode.prototype.init = function () {
    ww.mode.EightBitMode.superClass_.init.call(this);
    this.world_ = this.getPhysicsWorld_();
    this.lastClick_ = new paper.Point(this.oX, this.oY);
    0 < this.paperCanvas_.height && (this.drawI_(), this.drawO_())
};
ww.mode.EightBitMode.prototype.didFocus = function () {
    ww.mode.EightBitMode.superClass_.didFocus.call(this);
    this.$canvas_ = $(this.canvas_);
    var a = this, b = ww.util.getPointerEventNames("down", this.name_);
    this.$canvas_.bind(b, function (b) {
        b.preventDefault();
        b.stopPropagation();
        a.lastClick_ = new paper.Point(a.getCoords(b).x, a.getCoords(b).y);
        a.lastClick_.getDistance(a.paperO_.position) < a.oRad && a.hasFocus && a.activateO();
        Math.abs(a.lastClick_.x - a.paperI_.position.x) < a.iWidth / 2 && Math.abs(a.lastClick_.y - a.paperI_.position.y) <
            a.iHeight / 2 && a.hasFocus && a.activateI()
    });
    b = ww.util.getPointerEventNames("move", this.name_);
    this.$canvas_.bind(b, function (b) {
        b.preventDefault();
        b.stopPropagation();
        b = new paper.Point(a.getCoords(b).x, a.getCoords(b).y);
        b.getDistance(a.paperO_.position) < a.oRad || Math.abs(b.x - a.paperI_.position.x) < a.iWidth / 2 && Math.abs(b.y - a.paperI_.position.y) < a.iHeight / 2 ? a.hasFocus && (a.canvas_.style.cursor = "pointer") : a.canvas_.style.cursor = "default"
    })
};
ww.mode.EightBitMode.prototype.didUnfocus = function () {
    ww.mode.EightBitMode.superClass_.didUnfocus.call(this);
    this.unbindEvent_($(this.paperCanvas_), "down");
    this.unbindEvent_($(this.paperCanvas_), "move")
};
ww.mode.EightBitMode.prototype.onResize = function (a) {
    ww.mode.EightBitMode.superClass_.onResize.call(this, !1);
    this.frontmostRequestsRetina_ && (this.frontmostWantsRetina_ = !($.browser.safari && 1024 < this.width_));
    this.setPaperShapeData();
    this.drawI_();
    this.drawO_();
    6 * this.height_ < this.width_ && this.playSound("error.mp3");
    var b = 1;
    this.frontmostWantsRetina_ && (b = 2);
    this.canvas_.width = this.width_ * b;
    this.canvas_.height = this.height_ * b;
    $(this.canvas_).css({width:this.width_, height:this.height_});
    a && this.redraw()
};
ww.mode.EightBitMode.prototype.pushPoints_ = function (a, b, c) {
    for (var d = 0; d < a.vectors.length; d++) {
        var e = a.vectors[d], f;
        a === this.paperO_ ? (f = e.add(this.oCenter), f = f.subtract(b), f = Math.max(0, this.oRad - f.length)) : (f = e.add(this.iCenter), f = f.subtract(b), f = Math.max(0, this.iWidth - f.length));
        e.length += Math.max(4 * f, 100);
        e.velocity += c;
        e.velocity = Math.min(5, e.velocity)
    }
};
ww.mode.EightBitMode.prototype.updateVectors_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], d = new paper.Point(this.iX, this.iY);
        c.velocity = a === this.paperO_ ? ((this.oRad - c.length) / c.acceleration + c.velocity) / c.bounce : ((d.getDistance(this.iCenter) - c.length) / c.acceleration + c.velocity) / c.bounce;
        c.length = Math.max(0, c.length + c.velocity)
    }
};
ww.mode.EightBitMode.prototype.updatePoints_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], c = c.clone();
        a === this.paperO_ ? (this.paperO_.segments[b].point = c.add(this.oCenter), this.paperO_.smooth()) : this.paperI_.segments[b].point = c.add(this.iCenter)
    }
};
ww.mode.EightBitMode.prototype.drawPixels_ = function () {
    var a = this.paperCanvas_, b = this.canvas_;
    if (a.width && !(1 > a.width) && a.height && !(1 > a.height)) {
        var c = a.getContext("2d"), d = b.getContext("2d"), a = c.getImageData(0, 0, a.width, a.height);
        d.clearRect(0, 0, b.width + 1, b.height + 1);
        b = ~~(0.0625 * this.width_);
        6 * this.height_ < this.width_ && (b /= 8);
        c = Math.min(Math.round(80 * b) / 4, 980);
        paper = this.paperScope_;
        var e = 1;
        this.frontmostWantsRetina_ && (e = 2);
        d.save();
        d.scale(e, e);
        for (i = 0; i < a.data.length; i += c)if (0 !== a.data[i + 3]) {
            var f =
                a.data[i], g = a.data[i + 1], h = a.data[i + 2], k = Math.ceil(i / 4), e = k % this.width_, k = Math.floor(k / this.width_), f = "rgba(" + f + ", " + g + ", " + h + ", 1)";
            d.fillStyle = f;
            d.fillRect(e - ~~(b / 2), k - ~~(b / 2), b, b)
        }
        d.restore();
        return a.data.length
    }
};
ww.mode.EightBitMode.prototype.stepPhysics = function (a) {
    ww.mode.EightBitMode.superClass_.stepPhysics.call(this, a);
    this.paperI_ && this.paperO_ && (this.fillI_(), this.fillO_(), this.updateVectors_(this.paperI_), this.updatePoints_(this.paperI_), this.updateVectors_(this.paperO_), this.updatePoints_(this.paperO_), this.frontmostWantsRetina_ ? (this.paperI_.scale(0.65), this.paperO_.scale(0.65)) : (this.paperI_.scale(0.55), this.paperO_.scale(0.55)))
};
ww.mode.EightBitMode.prototype.onFrame = function (a) {
    ww.mode.EightBitMode.superClass_.onFrame.call(this, a);
    this.drawPixels_(this.paperCanvas_)
};
ww.mode.HomeMode = function (a, b) {
    this.preloadSound("i.mp3");
    this.preloadSound("o.mp3");
    ww.mode.Core.call(this, a, b, "home", !0, !0, !1, !0);
    this.patternMatcher_ = new ww.PatternMatcher(ww.mode.modes);
    this.wentIdleTime_ = 0;
    this.isIdle_ = !0;
    this.maxIdleTime_ = 12E3
};
goog.inherits(ww.mode.HomeMode, ww.mode.Core);
ww.mode.HomeMode.prototype.resetIdle_ = function () {
    this.isIdle_ && this.leaveIdle_();
    this.wentIdleTime_ = this.timeElapsed_
};
ww.mode.HomeMode.prototype.enterIdle_ = function () {
    this.isIdle_ = !0;
    this.$date_.fadeIn(300);
    this.$pattern_.fadeOut(300)
};
ww.mode.HomeMode.prototype.leaveIdle_ = function () {
    this.isIdle_ = !1;
    this.$date_.fadeOut(300);
    this.$pattern_.fadeIn(300)
};
ww.mode.HomeMode.prototype.addPatternCharacter = function (a) {
    this.$pattern_.hasClass("success") && (this.$pattern_.removeClass("success"), this.patternMatcher_.reset());
    this.$pattern_.hasClass("failure") && (this.$pattern_.removeClass("failure"), this.patternMatcher_.reset());
    var b = this;
    this.patternMatcher_.addCharacter(a, function (a, d) {
        b.log("current pattern: " + a);
        var e = a.replace(/1/g, '<span class="i"></span>').replace(/0/g, '<span class="o"></span>');
        b.$pattern_.html(e);
        b.$pattern_.css("marginLeft", -((b.$pattern_.width() +
            15) / 2));
        d ? (b.log("matched", d), d.isPartial || (b.$pattern_.addClass("success"), b.goToMode_(d.key))) : (b.$pattern_.removeClass("success"), b.$pattern_.addClass("failure"))
    });
    this.resetIdle_()
};
ww.mode.HomeMode.prototype.activateI = function () {
    ww.mode.HomeMode.superClass_.activateI.call(this);
    this.pushPoints_(this.paperI_, this.lastClick_, 10);
    this.playSound("i.mp3");
    this.addPatternCharacter("1")
};
ww.mode.HomeMode.prototype.activateO = function () {
    ww.mode.HomeMode.superClass_.activateO.call(this);
    this.pushPoints_(this.paperO_, this.lastClick_, 10);
    this.playSound("o.mp3");
    this.addPatternCharacter("0")
};
ww.mode.HomeMode.prototype.goToMode_ = function (a) {
    this.trackEvent_("matched-pattern", a);
    this.sendMessage_("goToMode", a)
};
ww.mode.HomeMode.prototype.drawI_ = function () {
    this.paperI_ && this.paperI_.remove();
    var a = new paper.Point(this.iX, this.iY), b = new paper.Size(this.iWidth, this.iHeight), a = new paper.Rectangle(a, b);
    this.paperI_ = new paper.Path.Rectangle(a);
    this.paperI_.closed = !0;
    this.paperI_.vectors = [];
    for (a = 0; a < this.paperI_.segments.length; a++)b = this.paperI_.segments[a].point.clone(), b = b.subtract(this.iCenter), b.velocity = 0, b.acceleration = 5 * Math.random() + 10, b.bounce = 0.1 * Math.random() + 1.05, this.paperI_.vectors.push(b)
};
ww.mode.HomeMode.prototype.fillI_ = function () {
    var a = [
        ["#4487fc", 0],
        ["#826eb1", 1]
    ], a = new paper.Gradient(a), b = this.paperI_.position.clone();
    b.x -= this.iWidth / 2;
    var c = this.paperI_.position.clone();
    c.x += this.iWidth / 2;
    a = new paper.GradientColor(a, b, c);
    this.paperI_.fillColor = a
};
ww.mode.HomeMode.prototype.drawO_ = function () {
    this.paperO_ && this.paperO_.remove();
    this.paperO_ = new paper.Path.RegularPolygon(this.oCenter, 6, this.oRad);
    this.paperO_.smooth();
    this.paperO_.vectors = [];
    for (var a = 0; a < this.paperO_.segments.length; a++) {
        var b = this.paperO_.segments[a].point.clone(), b = b.subtract(this.oCenter);
        b.velocity = 0;
        b.acceleration = 5 * Math.random() + 10;
        b.bounce = 0.1 * Math.random() + 1.05;
        this.paperO_.vectors.push(b)
    }
};
ww.mode.HomeMode.prototype.fillO_ = function () {
    var a = [
        ["#93689c", 0],
        ["#df4a40", 1]
    ], a = new paper.Gradient(a), b = this.paperO_.position.clone();
    b.x -= this.oRad;
    var c = this.paperO_.position.clone();
    c.x += this.oRad;
    a = new paper.GradientColor(a, b, c);
    this.paperO_.fillColor = a
};
ww.mode.HomeMode.prototype.init = function () {
    ww.mode.HomeMode.superClass_.init.call(this);
    this.$date_ = this.find("#date");
    this.$pattern_ = this.find("#pattern");
    this.patternMatcher_.reset();
    this.getPaperCanvas_();
    this.lastClick_ = new paper.Point(this.oX, this.oY);
    0 < this.paperCanvas_.height && (this.drawI_(), this.drawO_())
};
ww.mode.HomeMode.prototype.didFocus = function () {
    ww.mode.HomeMode.superClass_.didFocus.call(this);
    var a = this;
    this.enterIdle_();
    this.bindEvent_(this.find("#menu"), "up", function () {
        $(a.containerElem_).addClass("modal-visible")
    });
    this.bindEvent_(this.find("#modal"), "up", function (b) {
        $(b.target).is("a") || $(a.containerElem_).removeClass("modal-visible")
    });
    Modernizr.touch && (this.bindEvent_(this.find(".has-dropdown label"), "up", function () {
        $(a.containerElem_).addClass("nav-visible");
        $(".dropdown-visible").removeClass("dropdown-visible");
        $(this).closest(".has-dropdown").addClass("dropdown-visible")
    }), this.bindEvent_(this.containerElem_, "up", function (b) {
        $(b.target).is("a, label, #menu") || ($(a.containerElem_).removeClass("nav-visible"), $(".dropdown-visible").removeClass("dropdown-visible"))
    }));
    this.bindEvent_(this.find("#dropdown"), "up", function (a) {
        $(a.target).is("a") || (a.preventDefault(), a.stopPropagation())
    });
    this.bindEvent_($(this.paperCanvas_), "down", function (b) {
        b.preventDefault();
        b.stopPropagation();
        a.lastClick_ = new paper.Point(a.getCoords(b).x,
            a.getCoords(b).y);
        a.paperO_.hitTest(a.lastClick_) && a.hasFocus && a.activateO();
        a.paperI_.hitTest(a.lastClick_) && a.hasFocus && a.activateI()
    });
    var b = new paper.Point(0, 0);
    this.bindEvent_($(this.paperCanvas_), "move", function (c) {
        c.preventDefault();
        c.stopPropagation();
        b = {x:a.getCoords(c).x, y:a.getCoords(c).y};
        a.paperO_.hitTest(b) || a.paperI_.hitTest(b) ? a.hasFocus && (document.body.style.cursor = "pointer") : document.body.style.cursor = "default"
    })
};
ww.mode.HomeMode.prototype.didUnfocus = function () {
    ww.mode.HomeMode.superClass_.didUnfocus.call(this);
    this.unbindEvent_(this.find("#menu"), "up");
    this.unbindEvent_(this.find("#modal"), "up");
    this.unbindEvent_(this.find("#dropdown"), "up");
    this.unbindEvent_(this.find(".has-dropdown label"), "up");
    this.unbindEvent_(this.containerElem_, "up");
    this.unbindEvent_($(this.paperCanvas_), "down");
    this.unbindEvent_($(this.paperCanvas_), "move")
};
ww.mode.HomeMode.prototype.onResize = function (a) {
    ww.mode.HomeMode.superClass_.onResize.call(this, !1);
    this.setPaperShapeData();
    this.drawI_();
    this.drawO_();
    a && this.redraw()
};
ww.mode.HomeMode.prototype.pushPoints_ = function (a, b, c) {
    for (var d = 0; d < a.vectors.length; d++) {
        var e = a.vectors[d], f;
        a === this.paperO_ ? (f = e.add(this.oCenter), f = f.subtract(b), f = Math.max(0, this.oRad - f.length)) : (f = e.add(this.iCenter), f = f.subtract(b), f = Math.max(0, this.iWidth - f.length));
        e.length += Math.max(f, 20);
        e.velocity += c
    }
};
ww.mode.HomeMode.prototype.updateVectors_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], d = new paper.Point(this.iX, this.iY);
        c.velocity = a === this.paperO_ ? ((this.oRad - c.length) / c.acceleration + c.velocity) / c.bounce : ((d.getDistance(this.iCenter) - c.length) / c.acceleration + c.velocity) / c.bounce;
        c.length = Math.max(0, c.length + c.velocity)
    }
};
ww.mode.HomeMode.prototype.updatePoints_ = function (a) {
    for (var b = 0; b < a.segments.length; b++) {
        var c = a.vectors[b], c = c.clone();
        a === this.paperO_ ? (this.paperO_.segments[b].point = c.add(this.oCenter), this.paperO_.smooth()) : this.paperI_.segments[b].point = c.add(this.iCenter)
    }
};
ww.mode.HomeMode.prototype.onFrame = function (a) {
    ww.mode.HomeMode.superClass_.onFrame.call(this, a);
    if (!this.isIdle_) {
        var b = this.timeElapsed_ - this.wentIdleTime_;
        b > this.maxIdleTime_ && this.enterIdle_()
    }
    this.paperI_ && this.paperO_ && (this.fillI_(), this.fillO_());
    0 < a && (this.paperI_ && this.paperO_) && (this.updateVectors_(this.paperI_), this.updatePoints_(this.paperI_), this.updateVectors_(this.paperO_), this.updatePoints_(this.paperO_))
};
ww.mode.MetaBallMode = function (a, b) {
    ww.mode.Core.call(this, a, b, "metaball", !0, !0, !0);
    this.notes_ = [
        {frequency:0, detune:0, type:0},
        {frequency:0, detune:0, type:0},
        {frequency:0, detune:0, type:0}
    ]
};
goog.inherits(ww.mode.MetaBallMode, ww.mode.Core);
ww.mode.MetaBallMode.prototype.drawI_ = function () {
    this.iWidth_ = 0.175 * this.ratioParent_;
    this.iHeight_ = 2.12698413 * this.iWidth_;
    this.iX_ = this.screenCenterX_ - this.iWidth_ - 0.15833333 * this.ratioParent_;
    this.iY_ = this.screenCenterY_ - this.iHeight_ / 2;
    this.ctx_.beginPath();
    this.ctx_.fillRect(this.iX_, this.iY_, this.iWidth_, this.iHeight_);
    this.ctx_.stroke()
};
ww.mode.MetaBallMode.prototype.drawGradients_ = function (a) {
    a.radius = a != this.world_.particles[0] ? this.oRad_ / 2 : this.oRad_;
    this.gctx_.save();
    this.gradSize_ = 4 * a.radius;
    this.gctx_.translate(a.pos.x - this.gradSize_, a.pos.y - this.gradSize_);
    var b = this.gctx_.createRadialGradient(this.gradSize_, this.gradSize_, 0, this.gradSize_, this.gradSize_, this.gradSize_);
    b.addColorStop(0, a.color + "1)");
    b.addColorStop(1, a.color + "0)");
    this.gctx_.fillStyle = b;
    this.gctx_.fillRect(0, 0, 4 * this.gradSize_, 4 * this.gradSize_);
    this.gctx_.restore()
};
ww.mode.MetaBallMode.prototype.getVector_ = function (a, b) {
    return new paper.Point({angle:180 * a / Math.PI, length:b})
};
ww.mode.MetaBallMode.prototype.metaball_ = function (a, b, c, d, e) {
    var f = a.position, g = b.position, h = a.bounds.width / 2;
    b = b.bounds.width / 2;
    var k = Math.PI / 2, n = f.getDistance(g), m, l;
    if (!(0 == h || 0 == b))if (!(n > e || n <= Math.abs(h - b))) {
        n < h + b ? (m = Math.acos((h * h + n * n - b * b) / (2 * h * n)), l = Math.acos((b * b + n * n - h * h) / (2 * b * n))) : l = m = 0;
        var p = g.subtract(f).getAngleInRadians(), q = Math.acos((h - b) / n);
        e = p + m + (q - m) * c;
        m = p - m - (q - m) * c;
        var s = p + Math.PI - l - (Math.PI - l - q) * c;
        l = p - Math.PI + l + (Math.PI - l - q) * c;
        var p = {x:f.x + this.getVector_(e, h).x, y:f.y + this.getVector_(e,
            h).y}, f = {x:f.x + this.getVector_(m, h).x, y:f.y + this.getVector_(m, h).y}, q = {x:g.x + this.getVector_(s, b).x, y:g.y + this.getVector_(s, b).y}, g = {x:g.x + this.getVector_(l, b).x, y:g.y + this.getVector_(l, b).y}, u = h + b, r = p.x - q.x, t = p.y - q.y, r = Math.sqrt(r * r + t * t);
        c = Math.min(c * d, r / u);
        c *= Math.min(1, 2 * n / (h + b));
        h *= c;
        b *= c;
        c = new paper.Path([p, q, g, f]);
        c.style = a.style;
        c.closed = !0;
        a = c.segments;
        a[0].handleOut = this.getVector_(e - k, h);
        a[1].handleIn = this.getVector_(s + k, b);
        a[2].handleOut = this.getVector_(l - k, b);
        a[3].handleIn = this.getVector_(m +
            k, h);
        return c
    }
};
ww.mode.MetaBallMode.prototype.drawConnections_ = function (a) {
    this.connections_ && this.connections_.remove();
    this.connections_ = new paper.Group;
    for (var b, c = Math.round(0.7 * Math.max(this.screenCenterX_, this.screenCenterY_)), d = 0; d < a.length; d++)for (var e = d + 1; e < a.length; e++)(b = this.metaball_(a[d], a[e], 0.45, 2.4, c)) && this.connections_.appendTop(b)
};
ww.mode.MetaBallMode.prototype.drawSlash_ = function () {
    this.slashStartX_ = this.screenCenterX_ + 0.02777778 * this.ratioParent_;
    this.slashStartY_ = this.screenCenterY_ - this.iHeight_ / 2 - 0.09722222 * this.iHeight_;
    this.slashEndX_ = this.iX_ + this.iWidth_;
    this.slashEndY_ = this.screenCenterY_ + this.iHeight_ / 2 + 0.09722222 * this.iHeight_;
    this.ctx_.lineWidth = 0.01388889 * this.ratioParent_;
    this.ctx_.beginPath();
    this.ctx_.moveTo(this.slashStartX_, this.slashStartY_);
    this.ctx_.lineTo(this.slashEndX_, this.slashEndY_);
    this.ctx_.stroke()
};
ww.mode.MetaBallMode.prototype.draw13_ = function (a) {
    a.css({width:0.33333333 * this.oRad_, height:0.25555556 * this.oRad_, left:this.oX_ + 0.38888889 * this.oRad_, top:this.oY_ - this.oRad_ - 0.37777778 * this.oRad_})
};
ww.mode.MetaBallMode.prototype.init = function () {
    ww.mode.MetaBallMode.superClass_.init.call(this);
    this.sources_ = [];
    this.gainNodes_ = [];
    this.getPaperCanvas_(!0);
    this.world_ = this.getPhysicsWorld_();
    this.world_.viscosity = 0;
    this.world_.particles.push(new Particle);
    this.ballCount_ = this.world_.particles.length;
    this.oRad_ = 0.1944444444 * this.ratioParent_;
    this.world_.particles[0].radius = this.oRad_;
    if (this.oPaths_)for (var a = 0; a < this.oPaths_.length; a++)this.oPaths_[a].remove();
    this.connections_ && this.connections_.remove();
    this.oPaths_ = [];
    this.oX_ = this.screenCenterX_ + this.oRad_;
    this.oY_ = this.screenCenterY_;
    this.oCenter_ = new paper.Point(this.oX_, this.oY_);
    this.oPaths_.push(new paper.Path.Circle(this.oCenter_, this.oRad_));
    this.colors_ = ["rgba(210, 59, 48,", "rgba(67, 134, 251,", "rgba(249, 188, 71,", "rgba(17, 168, 96,"];
    this.world_.particles[0].color = this.colors_[0];
    this.screenCenterX_ = this.width_ / 2;
    this.screenCenterY_ = this.height_ / 2;
    this.mouseX_ = [];
    this.mouseY_ = [];
    paper.view.setViewSize(this.width_, this.height_)
};
ww.mode.MetaBallMode.prototype.didFocus = function () {
    ww.mode.MetaBallMode.superClass_.didFocus.call(this);
    this.$canvas_ = $("#metaball-canvas");
    this.canvas_ = this.$canvas_[0];
    this.canvas_.width = this.width_;
    this.canvas_.height = this.height_;
    this.ctx_ = this.canvas_.getContext("2d");
    this.pctx_ = this.paperCanvas_.getContext("2d");
    this.gcanvas_ = document.createElement("canvas");
    this.gcanvas_.width = this.width_;
    this.gcanvas_.height = this.height_;
    this.gctx_ = this.gcanvas_.getContext("2d");
    this.ballCount_ = 1;
    var a = this,
        b = ww.util.getPointerEventNames("down", this.name_);
    this.$canvas_.bind(b, function (b) {
        a.mouseX_ = a.getCoords(b).x;
        a.mouseY_ = a.getCoords(b).y;
        for (var d, e = 0; e < a.ballCount_; e++)if (a.world_.particles[e].fixed && (a.world_.particles[e].fixed = !1), Math.abs(a.mouseX_ - a.world_.particles[e].pos.x) < a.world_.particles[e].radius && Math.abs(a.mouseY_ - a.world_.particles[e].pos.y) < a.world_.particles[e].radius)if (d = a.world_.particles[e], d === a.world_.particles[0] && 4 > a.ballCount_) {
            a.world_.particles.push(new Particle);
            a.oPaths_.push(new paper.Path.Circle(a.oCenter_,
                a.oRad_ / 2));
            var f = a.world_.particles[a.world_.particles.length - 1];
            d = f;
            f = new Attraction(a.world_.particles[0].pos);
            d.behaviours.push(f);
            d.pos.x = a.mouseX_;
            d.pos.y = a.mouseY_;
            d.mass = 254 * Math.random() + 1;
            d.color = a.colors_[a.ballCount_];
            d.fixed = !0;
            a.ballCount_ = a.world_.particles.length;
            a.wantsAudio_ && (f = a.getAudioContext_(), a.sources_.push(f.createOscillator()), a.gainNodes_.push(f.createGainNode()), a.sources_[a.sources_.length - 1].connect(a.gainNodes_[a.sources_.length - 1]), a.gainNodes_[a.sources_.length -
                1].connect(f.destination), a.sources_[a.sources_.length - 1].noteOn(0), a.gainNodes_[a.gainNodes_.length - 1].gain.value = 0.1)
        } else d != a.world_.particles[0] && (d.fixed = !0, d.vel.x = 0, d.vel.y = 0);
        var g = ww.util.getPointerEventNames("move", a.name_);
        a.$canvas_.bind(g, function (b) {
            a.mouseX_ = a.getCoords(b).x;
            a.mouseY_ = a.getCoords(b).y;
            d && !0 === d.fixed && (d.pos.x = a.mouseX_, d.pos.y = a.mouseY_)
        });
        var h = ww.util.getPointerEventNames("up", a.name_);
        a.$canvas_.bind(h, function () {
            d && (d.fixed = !1);
            a.$canvas_.unbind(h);
            a.$canvas_.unbind(g)
        });
        b.preventDefault();
        b.stopPropagation()
    })
};
ww.mode.MetaBallMode.prototype.didUnfocus = function () {
    ww.mode.MetaBallMode.superClass_.didUnfocus.call(this);
    var a = ww.util.getPointerEventNames("down", this.name_);
    this.$canvas_.unbind(a);
    if (this.wantsAudio_)for (a = 0; a < this.sources_.length; a++)this.sources_[a].disconnect(), this.gainNodes_[a].disconnect()
};
ww.mode.MetaBallMode.prototype.onResize = function () {
    ww.mode.MetaBallMode.superClass_.onResize.call(this, !1);
    this.canvas_ && (this.canvas_.width = this.width_, this.canvas_.height = this.height_);
    this.gcanvas_ && (this.gcanvas_.width = this.width_, this.gcanvas_.height = this.height_);
    this.ratioParent_ = Math.min(this.width_, this.height_);
    this.screenCenterX_ = this.width_ / 2;
    this.screenCenterY_ = this.height_ / 2;
    this.oRad_ = 0.1944444444 * this.ratioParent_;
    if (this.oPaths_[0]) {
        this.oPaths_[0].scale(2 * this.oRad_ / this.oPaths_[0].bounds.height);
        for (var a = 1; a < this.oPaths_.length; a++)this.oPaths_[a] && this.oPaths_[a].scale(2 * this.oRad_ / this.oPaths_[a].bounds.height / 2)
    }
    this.oX_ = this.screenCenterX_ + this.oRad_;
    this.oY_ = this.screenCenterY_;
    this.oCenter_ = new paper.Point(this.oX_, this.oY_);
    this.gradSize_ = 4 * this.oRad_;
    $(".year-mark") && this.draw13_($(".year-mark"));
    this.redraw()
};
ww.mode.MetaBallMode.prototype.stepPhysics = function (a) {
    ww.mode.MetaBallMode.superClass_.stepPhysics.call(this, a);
    this.world_.particles[0].pos.x = this.oX_;
    this.world_.particles[0].pos.y = this.oY_;
    for (a = 0; a < this.world_.particles.length; a++)!0 === this.world_.particles[a].fixed && (this.world_.particles[a].pos.x = this.mouseX_, this.world_.particles[a].pos.y = this.mouseY_, this.oPaths_[a].position.x = this.mouseX_, this.oPaths_[a].position.y = this.mouseY_), this.world_.particles[a].pos.x > this.width_ - this.world_.particles[a].radius ?
        (this.world_.particles[a].vel.x *= -1, this.world_.particles[a].pos.x = this.width_ - (this.world_.particles[a].radius + 1)) : this.world_.particles[a].pos.x < this.world_.particles[a].radius && (this.world_.particles[a].vel.x *= -1, this.world_.particles[a].pos.x = this.world_.particles[a].radius + 1), this.world_.particles[a].pos.y > this.height_ - this.world_.particles[a].radius ? (this.world_.particles[a].vel.y *= -1, this.world_.particles[a].pos.y = this.height_ - (this.world_.particles[a].radius + 1)) : this.world_.particles[a].pos.y <
        this.world_.particles[a].radius && (this.world_.particles[a].vel.y *= -1, this.world_.particles[a].pos.y = this.world_.particles[a].radius + 1), this.world_.particles[a] != this.world_.particles[0] && (this.notes_[a - 1].frequency = this.world_.particles[0].pos.x - this.world_.particles[a].pos.x, this.notes_[a - 1].detune = this.world_.particles[0].pos.y - this.world_.particles[a].pos.y);
    if (this.wantsAudio_)for (a = 0; a < this.sources_.length; a++)this.world_.particles[a + 1] && (this.sources_[a].type = this.notes_[a].type, this.sources_[a].frequency.value =
        this.notes_[a].frequency, this.sources_[a].detune.value = this.notes_[a].detune);
    for (a = 0; a < this.oPaths_.length; a++)this.oPaths_[a] && this.world_.particles[a] && (this.oPaths_[a].position.x = this.world_.particles[a].pos.x, this.oPaths_[a].position.y = this.world_.particles[a].pos.y, this.oPaths_[a].fillColor = "white");
    1 < this.oPaths_.length && this.drawConnections_(this.oPaths_)
};
ww.mode.MetaBallMode.prototype.onFrame = function (a) {
    ww.mode.MetaBallMode.superClass_.onFrame.call(this, a);
    if (this.canvas_) {
        this.ctx_.clearRect(0, 0, this.canvas_.width + 1, this.canvas_.height + 1);
        this.gctx_.clearRect(0, 0, this.gcanvas_.width + 1, this.gcanvas_.height + 1);
        this.ctx_.fillStyle = "#e5e5e5";
        this.ctx_.strokeStyle = "#e5e5e5";
        this.drawI_();
        for (a = 0; a < this.ballCount_; a++)this.drawGradients_(this.world_.particles[a]);
        this.drawSlash_();
        this.pctx_.save();
        this.pctx_.globalCompositeOperation = "source-atop";
        0 <
            this.gcanvas_.height && this.pctx_.drawImage(this.gcanvas_, 0, 0);
        0 < this.paperCanvas_.height && this.ctx_.drawImage(this.paperCanvas_, 0, 0);
        this.pctx_.restore()
    }
};
var TWOPI = TWOPI || 2 * Math.PI;
ww.mode.PinataMode = function (a, b) {
    this.preloadSound("whack.mp3");
    this.preloadSound("whoosh-1.mp3");
    this.preloadSound("whoosh-2.mp3");
    ww.mode.Core.call(this, a, b, "pinata", !0, !0, !0, !1);
    this.ballSpeed_ = 250;
    this.COLORS_ = ["#0da960", "#4387fd", "#e04a3f", "#ffd24d"];
    this.NUM_COLORS = this.COLORS_.length;
    this.canvas_ = document.getElementById("pinata-canvas")
};
goog.inherits(ww.mode.PinataMode, ww.mode.Core);
ww.mode.PinataMode.prototype.init = function () {
    ww.mode.PinataMode.superClass_.init.call(this);
    this.getPhysicsWorld_(new Verlet);
    this.collision_ = new Collision;
    this.force_ = new ConstantForce(new Vector(0, 1E3));
    this.$letterO_.attr("cx");
    this.$letterO_.attr("cy");
    this.$letterI_.attr("cx");
    this.$letterI_.attr("cy");
    this.robotParticle_ || (this.robotParticle_ = new Particle(5), this.robotParticle_.fixed = !0);
    this.robotParticle_.behaviours = [this.collision_];
    this.collision_.pool = [this.robotParticle_];
    this.physicsWorld_.particles =
        [this.robotParticle_];
    this.recenter_();
    this.maxWhacks_ = 5;
    this.crackedParts_ = this.crackedParts_ || $("[id*=pinata-part-]");
    this.maxParts_ = this.maxParts_ || this.crackedParts_.length;
    this.resetToStart_()
};
ww.mode.PinataMode.prototype.resetToStart_ = function () {
    this.$letterO_.css("opacity", 1);
    this.whackCount_ = 0;
    this.crackedParts_.removeAttr("style").css("opacity", 0)
};
ww.mode.PinataMode.prototype.onResize = function (a) {
    ww.mode.PinataMode.superClass_.onResize.call(this, a);
    this.recenter_();
    var b = 1;
    this.wantsRetina_ && (b = 2);
    this.canvas_.width = this.width_ * b;
    this.canvas_.height = this.height_ * b;
    $(this.canvas_).css({width:this.width_, height:this.height_});
    a && this.redraw()
};
ww.mode.PinataMode.prototype.recenter_ = function () {
    this.center_ = {x:this.boundsX_ + 0.7 * this.boundsWidth_, y:this.boundsY_ + this.boundsHeight_ / 2};
    this.robotParticle_.setRadius(0.41 * this.boundsWidth_);
    this.robotParticle_.moveTo(new Vector(this.center_.x, this.center_.y))
};
ww.mode.PinataMode.prototype.stepPhysics = function (a) {
    ww.mode.PinataMode.superClass_.stepPhysics.call(this, a);
    a = [];
    for (var b = 1, c = this.physicsWorld_.particles.length; b < c; b++) {
        var d = this.physicsWorld_.particles[b], e = d.radius, e = 6 * e;
        (d.pos && d.pos.x > this.width_ + e || d.pos.x < 0 - e || d.pos.y > this.height_ + e || d.pos.y < 0 - e) && a.push(d)
    }
    b = 0;
    for (c = a.length; b < c; b++)d = this.physicsWorld_.particles.indexOf(a[b]), this.physicsWorld_.particles.splice(d, 1), d = this.collision_.pool.indexOf(a[b]), this.collision_.pool.splice(d, 1)
};
ww.mode.PinataMode.prototype.onFrame = function (a) {
    ww.mode.PinataMode.superClass_.onFrame.call(this, a);
    var b = this.canvas_.getContext("2d");
    b.clearRect(0, 0, this.canvas_.width, this.canvas_.height);
    var c = 1;
    this.wantsRetina_ && (c = 2);
    b.save();
    b.scale(c, c);
    for (var c = 1, d = this.physicsWorld_.particles.length; c < d; c++) {
        var e = this.physicsWorld_.particles[c], f = e.radius, g = 2 * f;
        e.rotate += 10 * a;
        b.save();
        b.fillStyle = e.color;
        b.translate(e.pos.x, e.pos.y);
        b.rotate(e.rotate);
        b.beginPath();
        b.arc(-f, 0, f, 0, TWOPI);
        b.arc(f, 0, f,
            0, TWOPI);
        b.fillRect(-f, -f, g, g);
        b.fill();
        b.restore()
    }
    b.restore()
};
ww.mode.PinataMode.prototype.ejectParticle_ = function (a, b, c) {
    var d = new Particle(Random(2, 5));
    d.setRadius(3 * d.mass);
    d.rotate = ~~Random(-360, 360) * (Math.PI / 180);
    d.color = this.COLORS_[~~Random(0, this.NUM_COLORS)];
    d.moveTo(new Vector(a + d.radius / 2 * c, b + d.radius / 2));
    d.vel = new Vector(Random(3, 6) * this.ballSpeed_ * c, Random(-3, 1.5) * this.ballSpeed_);
    d.behaviours.push(this.force_);
    this.collision_.pool.push(d);
    d.behaviours.push(this.collision_);
    this.physicsWorld_.particles.push(d)
};
ww.mode.PinataMode.prototype.activateBalls_ = function () {
    for (var a = ~~Random(2, 4) + ~~(this.whackCount_ / 3), b = 0; b <= a; b++) {
        var c = 0 === b % 2 ? -1 : 1;
        this.ejectParticle_(this.center_.x, this.center_.y, c)
    }
};
ww.mode.PinataMode.prototype.activateI = function () {
    ww.mode.PinataMode.superClass_.activateI.call(this);
    this.isAnimating_ || (this.playSound("whack.mp3"), this.animateI_(), this.whackCount_ < this.maxWhacks_ ? (this.log("whack " + this.whackCount_ + " " + this.reset_), this.activateBalls_(), this.animateO_()) : this.whackCount_ === this.maxWhacks_ ? (this.log("reached max whacks. breaking pinata."), this.activateBalls_(), this.animatePartsOut_()) : this.animatePartsIn_(), this.whackCount_++)
};
ww.mode.PinataMode.prototype.activateO = function () {
    ww.mode.PinataMode.superClass_.activateO.call(this);
    this.wantsAudio_ && (0 === this.whackCount_ % 2 ? this.playSound("whoosh-1.mp3") : this.playSound("whoosh-2.mp3"));
    this.animateO_()
};
ww.mode.PinataMode.prototype.animatePartsOut_ = function () {
    this.log("animating final break.");
    var a = this;
    this.$letterO_.css("opacity", 0);
    this.isAnimating_ = !0;
    for (var b = 0; b < this.maxParts_; b++) {
        var c = $(a.crackedParts_[b]);
        (function (b, c) {
            var f = ~~Random(-45, 45), g = ~~Random(-45, 45), h = ~~Random(-90, 90) + 5;
            b.data("movedX", g);
            b.data("movedY", f);
            b.data("rotate", h);
            var k = new TWEEN.Tween({translateY:0, translateX:0, rotate:0});
            k.onStart(function () {
                b.css("opacity", 1)
            });
            k.to({translateY:f, translateX:g, rotate:h}, 1E3);
            k.easing(TWEEN.Easing.Exponential.Out);
            k.onUpdate(function () {
                a.transformElem_(b[0], "rotate(" + this.rotate + "deg) translate(" + this.translateX + "px, " + this.translateY + "px)")
            });
            if (!(c + 1 < a.maxParts_))k.onComplete(function () {
                a.isAnimating_ = !1
            });
            a.addTween(k)
        })(c, b)
    }
};
ww.mode.PinataMode.prototype.animatePartsIn_ = function () {
    this.log("animating back after break.");
    var a = this;
    this.isAnimating_ = !0;
    var b = new TWEEN.Tween({opacity:1});
    b.to({opacity:0}, 250);
    b.onUpdate(function () {
        a.crackedParts_.css("opacity", this.opacity)
    });
    var c = new TWEEN.Tween({opacity:0});
    c.to({opacity:1}, 250);
    c.delay(250);
    c.onUpdate(function () {
        a.$letterO_.css("opacity", this.opacity)
    });
    c.onComplete(function () {
        a.isAnimating_ = !1;
        a.resetToStart_()
    });
    this.addTween(b);
    this.addTween(c)
};
ww.mode.PinataMode.prototype.animateI_ = function () {
    var a = this, b = 190, c = new TWEEN.Tween({translateX:0, translateY:0, rotate:0});
    c.to({translateX:40, translateY:-40, rotate:30}, b);
    c.onUpdate(function () {
        a.transformElem_(a.$letterI_[0], "rotate(" + this.rotate + "deg) translate(" + this.translateX + "px, " + this.translateY + "px)")
    });
    var d = new TWEEN.Tween({rotate:30, translateX:40, translateY:-40});
    d.to({rotate:0, translateX:0, translateY:0}, b);
    d.delay(b);
    d.onUpdate(function () {
        a.transformElem_(a.$letterI_[0], "rotate(" + this.rotate +
            "deg) translate(" + this.translateX + "px, " + this.translateY + "px)")
    });
    a.addTween(c);
    a.addTween(d)
};
ww.mode.PinataMode.prototype.animateO_ = function () {
    var a = this, b = 200, c = ~~Random(10, 45), d = 0 === this.whackCount_ % 2 ? -1 : 1, e = new TWEEN.Tween({rotate:0});
    e.to({rotate:d * c}, b);
    e.onUpdate(function () {
        a.transformElem_(a.$letterO_[0], "rotate(" + this.rotate + "deg)")
    });
    var f = new TWEEN.Tween({rotate:d * c});
    f.to({rotate:-1 * d * c}, b);
    f.delay(b);
    f.onUpdate(function () {
        a.transformElem_(a.$letterO_[0], "rotate(" + this.rotate + "deg)")
    });
    c = new TWEEN.Tween({rotate:-1 * d * c});
    c.to({rotate:0}, b);
    c.delay(2 * b);
    c.onUpdate(function () {
        a.transformElem_(a.$letterO_[0],
            "rotate(" + this.rotate + "deg)")
    });
    a.addTween(e);
    a.addTween(f);
    a.addTween(c)
};
TWOPI = 2 * Math.PI;
ww.mode.PongMode = function (a, b) {
    this.preloadSound("1.mp3");
    this.preloadSound("2.mp3");
    ww.mode.Core.call(this, a, b, "pong", !0, !0, !0);
    this.startBallSpeed_ = this.ballSpeed_ = 250;
    this.maxBallSpeed_ = 800;
    this.startBallRadius_ = this.ballRadius_ = 30;
    this.minBallRadius_ = 10;
    this.paddleX_ = 40;
    this.paddleY_ = 80;
    this.paddleWidth_ = 40;
    this.paddleHeight_ = 160;
    this.paused_ = !0;
    this.bottomWallOpacity_ = this.rightWallOpacity_ = this.topWallOpacity_ = 0
};
goog.inherits(ww.mode.PongMode, ww.mode.Core);
ww.mode.PongMode.prototype.init = function () {
    ww.mode.PongMode.superClass_.init.call(this);
    var a = this.getPhysicsWorld_();
    a.viscosity = 0;
    this.ball_ = this.ball_ || new Particle;
    a.particles.push(this.ball_);
    this.screenCenterX = this.width_ / 2;
    this.screenCenterY = this.height_ / 2;
    this.mouseX_ = this.screenCenterX;
    this.mouseY_ = this.screenCenterY;
    this.paddleY_ = this.mouseY_ - this.paddleHeight_ / 2;
    this.resetGame_()
};
ww.mode.PongMode.prototype.startRound_ = function () {
    this.gamesPlayed_ = this.gamesPlayed_ || 0;
    this.gamesPlayed_++;
    this.setScore_(0);
    this.bonusEl_.style.opacity = 0;
    this.transformElem_(this.bonusEl_, "translateX(50px)");
    this.paused_ = !1
};
ww.mode.PongMode.prototype.resetGame_ = function () {
    this.bottomWallOpacity_ = this.rightWallOpacity_ = this.topWallOpacity_ = 0;
    this.ballRadius_ = this.startBallRadius_;
    this.ballSpeed_ = this.startBallSpeed_;
    this.startXBall_ = this.screenCenterX - this.width_ / 4;
    this.ball_.setRadius(this.ballRadius_);
    this.ball_.pos.x = this.startXBall_;
    this.ball_.pos.y = this.ballRadius_;
    this.ball_.vel.x = this.ballSpeed_;
    this.ball_.vel.y = this.ballSpeed_;
    this.setScore_(0)
};
ww.mode.PongMode.prototype.onResize = function (a) {
    ww.mode.PongMode.superClass_.onResize.call(this, !1);
    this.canvas_ && (this.canvas_.width = this.width_, this.canvas_.height = this.height_);
    a && this.redraw()
};
ww.mode.PongMode.prototype.didFocus = function () {
    ww.mode.PongMode.superClass_.didFocus.call(this);
    this.bonusEl_ = document.getElementById("bonus");
    this.$score_ = $("#score");
    this.$canvas_ = $("#pong-canvas");
    this.canvas_ = this.$canvas_[0];
    this.canvas_.width = this.width_;
    this.canvas_.height = this.height_;
    this.ctx_ = this.canvas_.getContext("2d");
    var a = this, b = ww.util.getPointerEventNames("move", this.name_);
    this.$canvas_.bind(b, function (b) {
        b.preventDefault();
        b.stopPropagation();
        a.mouseX_ = a.getCoords(b).x;
        a.mouseY_ =
            a.getCoords(b).y
    });
    this.startRound_()
};
ww.mode.PongMode.prototype.didUnfocus = function () {
    ww.mode.PongMode.superClass_.didUnfocus.call(this);
    var a = ww.util.getPointerEventNames("move", this.name_);
    this.$canvas_.unbind(a)
};
ww.mode.PongMode.prototype.hitWall_ = function (a) {
    this.playSound("1.mp3");
    var b = a + "Opacity_", c = {};
    c[b] = this[b];
    a = {};
    a[b] = 1;
    var d = this, c = new TWEEN.Tween(c);
    c.to(a, 200);
    c.onUpdate(function () {
        d[b] = this[b]
    });
    this.addTween(c)
};
ww.mode.PongMode.prototype.hitPaddle_ = function () {
    this.playSound("2.mp3");
    var a = this, b = this.score_ + 1;
    if (0 < this.topWallOpacity_ && 0 < this.rightWallOpacity_ && 0 < this.bottomWallOpacity_) {
        var b = b + 10, c = new TWEEN.Tween({opacity:0, translateX:50});
        c.to({opacity:1, translateX:0}, 200);
        c.onUpdate(function () {
            a.bonusEl_.style.opacity = this.opacity;
            a.transformElem_(a.bonusEl_, "translateX(" + this.translateX + "px)")
        });
        var d = new TWEEN.Tween({opacity:1, translateX:0});
        d.to({opacity:0, translateX:50}, 200);
        d.delay(700);
        d.onUpdate(function () {
            a.bonusEl_.style.opacity =
                this.opacity;
            a.transformElem_(a.bonusEl_, "translateX(" + this.translateX + "px)")
        });
        this.addTween(c);
        this.addTween(d)
    }
    this.setScore_(b);
    b = new TWEEN.Tween({topWallOpacity:this.topWallOpacity_, rightWallOpacity:this.rightWallOpacity_, bottomWallOpacity:this.bottomWallOpacity_});
    b.to({topWallOpacity:0, rightWallOpacity:0, bottomWallOpacity:0}, 200);
    b.onUpdate(function () {
        a.topWallOpacity_ = this.topWallOpacity;
        a.rightWallOpacity_ = this.rightWallOpacity;
        a.bottomWallOpacity_ = this.bottomWallOpacity
    });
    this.addTween(b)
};
ww.mode.PongMode.prototype.gameOver_ = function () {
    this.log("You Lose");
    this.trackEvent_("lost", this.score_);
    this.trackEvent_("game number", this.gamesPlayed_);
    this.paused_ = !0;
    var a = this;
    this.showReload(function () {
        a.resetGame_();
        a.paused_ = !1
    })
};
ww.mode.PongMode.prototype.setScore_ = function (a) {
    this.score_ = a;
    this.$score_ && this.$score_.length && this.$score_.text(this.score_)
};
ww.mode.PongMode.prototype.reflectBall_ = function () {
    if (this.ball_.pos.x <= this.ball_.radius)this.gameOver_(); else {
        0 < this.ball_.vel.x && this.ball_.pos.x >= this.width_ - this.ball_.radius && (this.ball_.vel.x *= -1, this.hitWall_("rightWall"));
        0 < this.ball_.vel.y && this.ball_.pos.y >= this.height_ - this.ball_.radius && (this.ball_.vel.y *= -1, this.hitWall_("bottomWall"));
        0 > this.ball_.vel.y && this.ball_.pos.y <= this.ball_.radius && (this.ball_.vel.y *= -1, this.hitWall_("topWall"));
        var a = this.paddleY_ - this.paddleHeight_ / 2, b = this.paddleY_ +
            this.paddleHeight_ / 2;
        0 > this.ball_.vel.x && (this.ball_.pos.x <= this.paddleX_ + this.paddleWidth_ / 2 + this.ball_.radius && this.ball_.pos.y >= a && this.ball_.pos.y <= b) && (this.ball_.vel.x *= -1, a = this.ball_.vel.mag(), this.norm_ ? this.norm_.copy(this.ball_.vel) : this.norm_ = this.ball_.vel.clone(), this.norm_.norm(), this.changeVec_ = this.changeVec_ || new Vector, b = (this.ball_.pos.y - this.paddleY_) / (this.paddleHeight_ / 2), this.changeVec_.set(0, b), this.norm_.add(this.changeVec_), this.norm_.norm(), this.norm_.scale(a), this.ball_.vel.copy(this.norm_),
            this.hitPaddle_())
    }
};
ww.mode.PongMode.prototype.stepPhysics = function (a) {
    if (!this.paused_) {
        ww.mode.PongMode.superClass_.stepPhysics.call(this, a);
        var b = this.paddleY_, c = this.mouseY_;
        c < this.paddleHeight_ / 2 ? c = this.paddleHeight_ / 2 : c > this.height_ - this.paddleHeight_ / 2 && (c = this.height_ - this.paddleHeight_ / 2);
        a = 0.7 * (c - b) * 10 * a;
        this.paddleY_ = b + a;
        0 < this.ball_.vel.x && (this.ballRadius_ >= this.minBallRadius_ && (this.ballRadius_ *= 0.9995, this.ball_.setRadius(this.ballRadius_)), this.ballSpeed_ <= this.maxBallSpeed_ && (this.ballSpeed_ *= 1.001,
            this.ball_.vel.x = this.ballSpeed_, this.ball_.vel.y = 0 > this.ball_.vel.y ? -this.ballSpeed_ : this.ballSpeed_));
        this.reflectBall_()
    }
};
ww.mode.PongMode.prototype.onFrame = function (a) {
    ww.mode.PongMode.superClass_.onFrame.call(this, a);
    this.canvas_ && (this.ctx_.clearRect(0, 0, this.canvas_.width + 1, this.canvas_.height + 1), this.ctx_.fillStyle = "#e0493e", this.ctx_.beginPath(), this.ctx_.arc(this.ball_.pos.x, this.ball_.pos.y, this.ball_.radius, 0, TWOPI), this.ctx_.fill(), this.ctx_.fillStyle = "#d0d0d0", this.ctx_.fillRect(this.paddleX_ - this.paddleWidth_ / 2, this.paddleY_ - this.paddleHeight_ / 2, this.paddleWidth_, this.paddleHeight_), this.ctx_.fillStyle = "#f3cdca",
        0 < this.topWallOpacity_ && (this.ctx_.save(), this.ctx_.globalAlpha = this.topWallOpacity_, this.ctx_.fillRect(0, 0, this.width_, 10), this.ctx_.restore()), 0 < this.bottomWallOpacity_ && (this.ctx_.save(), this.ctx_.globalAlpha = this.bottomWallOpacity_, this.ctx_.fillRect(0, this.height_ - 10, this.width_, 10), this.ctx_.restore()), 0 < this.rightWallOpacity_ && (this.ctx_.save(), this.ctx_.globalAlpha = this.rightWallOpacity_, this.ctx_.fillRect(this.width_ - 10, 0, 10, this.height_), this.ctx_.restore()))
};
ww.mode.RocketMode = function (a, b) {
    this.preloadSound("rocket-launch.mp3");
    this.preloadSound("rumble.mp3");
    this.preloadSound("sci-fi-door.mp3");
    ww.mode.Core.call(this, a, b, "rocket", !0, !0, !1);
    var c = this.find(".letter-i"), d = this.find(".letter-o");
    this.centerO_ = d.attr("cx") + ", " + d.attr("cy");
    this.centerI_ = c.attr("cx") + ", " + c.attr("cy");
    this.rocket_ = this.find(".letter-i-wrapper");
    this.moons_ = $("#moon-1");
    this.fires_ = $("[id*=fire-]").css("opacity", 0);
    this.maxFires_ = this.fires_.length;
    this.currentFire_ = 0;
    this.isAnimating_ =
        this.hasLanded_ = !1
};
goog.inherits(ww.mode.RocketMode, ww.mode.Core);
ww.mode.RocketMode.prototype.activateI = function () {
    ww.mode.RocketMode.superClass_.activateI.call(this);
    this.isAnimating_ || (this.currentFire_ < this.maxFires_ ? this.animateWiggle_() : this.hasLanded_ || this.animateLanding_())
};
ww.mode.RocketMode.prototype.animateWiggle_ = function () {
    if (!this.isAnimating_) {
        var a = this;
        this.playSound("rumble.mp3");
        this.fires_[this.currentFire_].style.opacity = 1;
        this.fires_[this.currentFire_ + 1].style.opacity = 1;
        this.fires_[this.currentFire_ + 2].style.opacity = 1;
        var b = ~~Random(2, 2 * this.currentFire_ + 2), c = new TWEEN.Tween({rotate:0});
        c.to({rotate:-b}, 100);
        c.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.centerI_ + ")")
        });
        var d = new TWEEN.Tween({rotate:-b});
        d.to({rotate:b},
            200);
        d.delay(100);
        d.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.centerI_ + ")")
        });
        b = new TWEEN.Tween({rotate:b});
        b.to({rotate:0}, 100);
        b.delay(300);
        b.onUpdate(function () {
            a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.centerI_ + ")")
        });
        b.onComplete(function () {
            a.currentFire_ += 3;
            a.isAnimating_ = !1
        });
        this.isAnimating_ = !0;
        this.addTween(c);
        this.addTween(d);
        this.addTween(b)
    }
};
ww.mode.RocketMode.prototype.animateLanding_ = function () {
    this.playSound("rocket-launch.mp3");
    var a = this, b = 100, c = 400, d = this.$letterO_[0].getBoundingClientRect(), e = this.$letterI_[0].getBoundingClientRect(), f = ~~(d.left + d.width / 2 - e.height);
    prevTransform = transform = "";
    d = new TWEEN.Tween({translateY:0});
    d.to({translateY:20}, c);
    d = new TWEEN.Tween({rotate:0});
    d.to({rotate:90}, b);
    d.onUpdate(function () {
        a.$letterI_.attr("transform", "rotate(" + this.rotate + ", " + a.centerI_ + ")")
    });
    e = new TWEEN.Tween({translateY:0, scale:1});
    e.to({translateY:f, scale:0.25}, c);
    e.delay(b);
    e.onUpdate(function () {
        transform = "scale(" + this.scale + ") translate(0, " + -1 * this.translateY + ")";
        a.rocket_.attr("transform", transform)
    });
    e.onComplete(function () {
        prevTransform = transform
    });
    b += c;
    f = new TWEEN.Tween({rotate:0});
    f.to({rotate:-90}, c);
    f.delay(b);
    f.onUpdate(function () {
        transform = prevTransform + " rotate(" + this.rotate + ", " + a.centerI_ + ")";
        a.rocket_.attr("transform", transform)
    });
    f.onComplete(function () {
        a.fires_.css("opacity", 0);
        a.activateO()
    });
    var b = b + c, g =
        new TWEEN.Tween({opacity:0});
    g.to({opacity:1}, 200);
    g.delay(b + c + 2E3);
    g.onStart(function () {
        a.rocket_.attr("transform", "");
        a.$letterI_.attr("transform", "")
    });
    g.onUpdate(function () {
        a.$letterI_.css("opacity", this.opacity)
    });
    g.onComplete(function () {
        a.currentFire_ = 0;
        a.hasLanded_ = !1
    });
    this.hasLanded_ = !0;
    this.addTween(d);
    this.addTween(e);
    this.addTween(f);
    this.addTween(g)
};
ww.mode.RocketMode.prototype.activateO = function () {
    ww.mode.RocketMode.superClass_.activateO.call(this);
    this.playSound("sci-fi-door.mp3");
    var a = this, b = 1E3, c = this.moons_[0].style[a.prefix_].split("rotate(")[1], c = parseInt(c) || 0, d = new TWEEN.Tween({rotate:c});
    d.to({rotate:c + 720}, b);
    d.onUpdate(function () {
        a.moons_.attr("transform", "rotate(" + this.rotate + ", " + a.centerO_ + ")")
    });
    d.onComplete(function () {
        a.moons_.attr("transform", "rotate(0, " + a.centerO_ + ")")
    });
    a.addTween(d)
};
ww.mode.SimoneMode = function (a, b) {
    ww.mode.Core.call(this, a, b, "simone", !0, !0)
};
goog.inherits(ww.mode.SimoneMode, ww.mode.Core);
ww.mode.SimoneMode.prototype.init = function () {
    ww.mode.SimoneMode.superClass_.init.call(this);
    var a = this;
    TWEEN.removeAll();
    this.evtStart = ww.util.getPointerEventNames("down", "simone");
    this.evtEnd = ww.util.getPointerEventNames("up", "simone");
    this.startAction = Modernizr.touch ? "Tap" : "Click";
    this.topLeft = $("#red");
    this.topRight = $("#green");
    this.bottomLeft = $("#blue");
    this.bottomRight = $("#yellow");
    this.segments = [this.topLeft, this.topRight, this.bottomLeft, this.bottomRight];
    this.segmentEls = $("#red, #green, #blue, #yellow").css("opacity",
        1);
    this.levels = $("#levels").removeClass().text("");
    this.playStatus = $("#status").removeClass();
    this.uiContainer = $("#levels").css("opacity", 0);
    this.container = $("#simone");
    this.message = $("#message").text(this.startAction + " to play.");
    this.container.bind(this.evtEnd, function () {
        a.message.hide();
        a.beginGame_();
        a.container.unbind(a.evtEnd)
    });
    this.plays = 0;
    this.isAnimating = this.isPlaying = !1;
    this.highestLevel = this.lastStep = this.stepIndex = 0;
    this.generateSequence_();
    this.total = this.sequence.length;
    if (this.wantsAudio_) {
        var b =
            this.getAudioContext_();
        this.source = b.createOscillator();
        this.analyser = b.createAnalyser();
        this.analyser.fftSize = 512;
        this.analyser.smoothingTimeConstant = 0.85;
        this.gainNode = b.createGainNode();
        this.gainNode.gain.value = 0.01;
        this.notes = [
            {frequency:1806, detune:-3663, type:1},
            {frequency:1806, detune:-4758, type:1},
            {frequency:229, detune:1053, type:1},
            {frequency:580, detune:-1137, type:2}
        ]
    }
};
ww.mode.SimoneMode.prototype.didFocus = function () {
    ww.mode.SimoneMode.superClass_.didFocus.call(this);
    var a = this;
    a.topLeft.bind(this.evtStart, function () {
        a.startCheck_(0)
    });
    a.topLeft.bind(this.evtEnd, function () {
        a.checkSequence_(0)
    });
    a.topRight.bind(this.evtStart, function () {
        a.startCheck_(1)
    });
    a.topRight.bind(this.evtEnd, function () {
        a.checkSequence_(1)
    });
    a.bottomLeft.bind(this.evtStart, function () {
        a.startCheck_(2)
    });
    a.bottomLeft.bind(this.evtEnd, function () {
        a.checkSequence_(2)
    });
    a.bottomRight.bind(this.evtStart,
        function () {
            a.startCheck_(3)
        });
    a.bottomRight.bind(this.evtEnd, function () {
        a.checkSequence_(3)
    })
};
ww.mode.SimoneMode.prototype.didUnfocus = function () {
    ww.mode.SimoneMode.superClass_.didUnfocus.call(this);
    this.topLeft.unbind(this.evtStart);
    this.topRight.unbind(this.evtStart);
    this.bottomLeft.unbind(this.evtStart);
    this.bottomRight.unbind(this.evtStart);
    this.topLeft.unbind(this.evtEnd);
    this.topRight.unbind(this.evtEnd);
    this.bottomLeft.unbind(this.evtEnd);
    this.bottomRight.unbind(this.evtEnd)
};
ww.mode.SimoneMode.prototype.generateSequence_ = function () {
    this.sequence = this.sequence || [];
    for (var a = 0; 4 > a; a++)this.sequence.push(~~(4 * Math.random()));
    this.log("generated sequence: " + this.sequence)
};
ww.mode.SimoneMode.prototype.shuffleSequence_ = function () {
    for (var a = this.sequence.length, b, c; --a;)b = Math.random() * (a + 1) | 0, c = this.sequence[a], this.sequence[a] = this.sequence[b], this.sequence[b] = c;
    this.log("shuffled sequence: " + this.sequence)
};
ww.mode.SimoneMode.prototype.startCheck_ = function (a) {
    if (this.isPlaying && !this.isAnimating) {
        0 === this.stepIndex && this.playStatus.removeClass("your-turn");
        var b = this.notes[a], c = this.segments[a], d = this;
        this.wantsAudio_ && (this.log("Playing note: ", b), this.source.type = b.type, this.source.frequency.value = b.frequency, this.source.detune.value = b.detune);
        a = new TWEEN.Tween({opacity:0.5});
        a.to({opacity:1}, 100);
        if (this.wantsAudio_)a.onStart(function () {
            d.source.connect(d.analyser);
            d.analyser.connect(d.gainNode);
            d.gainNode.connect(d.audioContext_.destination);
            d.source.noteOn(0)
        });
        a.onUpdate(function () {
            c.css("opacity", this.opacity)
        });
        this.addTween(a)
    }
};
ww.mode.SimoneMode.prototype.checkSequence_ = function (a) {
    this.log("Guess (" + a + "). Expecting (" + this.sequence[this.stepIndex] + ")");
    if (this.isPlaying && !this.isAnimating) {
        var b = this, c = b.segments[a], d = this.wantsAudio_ ? 200 : 400, e = new TWEEN.Tween({opacity:1});
        e.to({opacity:0.5}, d);
        e.onUpdate(function () {
            c.css("opacity", this.opacity)
        });
        if (this.wantsAudio_)e.onComplete(function () {
            b.source.disconnect()
        }); else e.delay(200);
        b.addTween(e);
        b.isAnimating = !1;
        if (b.sequence[b.stepIndex] === a)if (b.stepIndex !== b.lastStep)b.stepIndex++;
        else {
            b.lastStep++;
            b.playStatus.addClass("success");
            if (b.lastStep === b.total) {
                for (a = 0; 4 > a; a++)b.sequence.push(~~(4 * Math.random()));
                b.total += 4
            }
            b.lastStep < b.total && (b.stepIndex = 0);
            b.displayNext_()
        } else b.isPlaying = !1, b.playStatus.addClass("game-over"), b.trackEvent_("failed", b.sequence.length), a = new TWEEN.Tween({opacity:0.5}), a.to({opacity:1}, 200), a.delay(500), a.onUpdate(function () {
            b.segmentEls.css("opacity", this.opacity)
        }), a.onComplete(function () {
            b.playStatus.removeClass();
            b.showReload(function () {
                    b.beginGame_()
                },
                !0)
        }), b.addTween(a)
    }
};
ww.mode.SimoneMode.prototype.beginGame_ = function () {
    if (!this.isPlaying) {
        var a = this;
        a.plays++;
        a.isPlaying = !0;
        a.isAnimating = !1;
        a.stepIndex = 0;
        a.highestLevel = Math.max(a.highestLevel, a.lastStep);
        a.lastStep = 0;
        a.shuffleSequence_();
        a.levels.removeClass().text("");
        a.playStatus.removeClass();
        this.log("Playing sequence: " + this.sequence);
        a.uiContainer.animate({opacity:1}, 200);
        if ("0.5" !== a.segmentEls.css("opacity")) {
            var b = new TWEEN.Tween({opacity:1});
            b.to({opacity:0.5}, 200);
            b.delay(200);
            b.onUpdate(function () {
                a.segmentEls.css("opacity", this.opacity)
            });
            a.addTween(b)
        }
        a.displayNext_()
    }
};
ww.mode.SimoneMode.prototype.displayNext_ = function () {
    if (this.isPlaying) {
        this.isAnimating = !0;
        for (var a = this, b, c, d = 500, e = this.lastStep + 1, f = 0; f < e; f++)b = a.sequence[f], c = a.segments[b], d += 600, function (b, c, d, f) {
            if (a.wantsAudio_)var m = a.notes[d];
            d = new TWEEN.Tween({opacity:0.5});
            d.to({opacity:1}, 200);
            d.delay(c);
            d.onStart(function () {
                0 === f && a.playStatus.removeClass("success");
                a.wantsAudio_ && (a.log(f + " now playing: ", m), a.source.type = m.type, a.source.frequency.value = m.frequency, a.source.detune.value = m.detune,
                    a.source.connect(a.analyser), a.analyser.connect(a.gainNode), a.gainNode.connect(a.audioContext_.destination), a.source.noteOn(0))
            });
            d.onUpdate(function () {
                b[0].style.opacity = this.opacity
            });
            var l = new TWEEN.Tween({opacity:1});
            l.to({opacity:0.5}, 200);
            l.delay(c + 300);
            l.onUpdate(function () {
                b[0].style.opacity = this.opacity
            });
            l.onComplete(function () {
                f === e - 1 && (a.isAnimating = !1, a.levels.text(e), a.playStatus.addClass("your-turn"));
                a.wantsAudio_ && a.source.disconnect();
                (1 === a.plays || 1 < a.plays && 0 === a.stepIndex) && a.levels.addClass("started")
            });
            a.addTween(d);
            a.addTween(l)
        }(c, d, b, f)
    }
};
ww.mode.SongMode = function (a, b) {
    this.preloadSound("brass-note-1.mp3");
    this.preloadSound("brass-note-2.mp3");
    this.preloadSound("brass-note-3.mp3");
    this.preloadSound("brass-note-4.mp3");
    this.preloadSound("lute-note-1.mp3");
    this.preloadSound("lute-note-2.mp3");
    this.preloadSound("lute-note-3.mp3");
    this.preloadSound("lute-note-4.mp3");
    this.preloadSound("funky-note-1.mp3");
    this.preloadSound("funky-note-2.mp3");
    this.preloadSound("funky-note-3.mp3");
    this.preloadSound("funky-note-4.mp3");
    this.preloadSound("beats-piano.mp3");
    this.preloadSound("beats-club.mp3");
    this.preloadSound("beats-effected-kit.mp3");
    this.preloadSound("beats-electric-1.mp3");
    this.preloadSound("beats-electric-2.mp3");
    this.preloadSound("beats-hip-hop.mp3");
    this.preloadSound("beats-jazzy-rock.mp3");
    this.preloadSound("beats-jazzy.mp3");
    this.preloadSound("beats-lounge.mp3");
    this.preloadSound("beats-motown.mp3");
    ww.mode.Core.call(this, a, b, "song", !0, !0)
};
goog.inherits(ww.mode.SongMode, ww.mode.Core);
ww.mode.SongMode.prototype.init = function () {
    ww.mode.SongMode.superClass_.init.call(this);
    this.evtStart = ww.util.getPointerEventNames("down", "song");
    this.evtEnd = ww.util.getPointerEventNames("up", "song");
    this.instruments = $(".instrument");
    this.ripples = {};
    this.ripples["note-1"] = [document.getElementById("rectangle1"), document.getElementById("rectangle2"), document.getElementById("rectangle3")];
    this.ripples["note-2"] = [document.getElementById("circle-yellow1"), document.getElementById("circle-yellow2"), document.getElementById("circle-yellow3")];
    this.ripples["note-3"] = [document.getElementById("circle-blue1"), document.getElementById("circle-blue2"), document.getElementById("circle-blue3")];
    this.ripples["note-4"] = [document.getElementById("polygon1"), document.getElementById("polygon2"), document.getElementById("polygon3")];
    this.songs = $(".song-style");
    $(this.songs.get(0)).addClass("active");
    this.active = this.songs.get(0).id;
    this.drums = "beats-piano.mp3 beats-club.mp3 beats-effected-kit.mp3 beats-electric-1.mp3 beats-electric-2.mp3 beats-hip-hop.mp3 beats-jazzy-rock.mp3 beats-jazzy.mp3 beats-lounge.mp3 beats-motown.mp3".split(" ");
    this.numDrums = this.drums.length;
    this.drumBadge = $("#drum-number");
    this.drumIndex = -1;
    this.drumEl = $("#drumkit");
    this.activeDrum = null
};
ww.mode.SongMode.prototype.didFocus = function () {
    ww.mode.SongMode.superClass_.didFocus.call(this);
    var a = this;
    a.instruments.bind(a.evtStart, function () {
        a.beginSound_(this.id, !1)
    });
    a.songs.bind(a.evtEnd, function () {
        a.swapSongMode_(this.id)
    });
    a.drumEl.bind(a.evtStart, function () {
        a.startDrumChange_()
    });
    a.drumEl.bind(a.evtEnd, function () {
        a.changeDrums_()
    })
};
ww.mode.SongMode.prototype.didUnfocus = function () {
    ww.mode.SongMode.superClass_.didUnfocus.call(this);
    this.instruments.unbind(this.evtStart);
    this.songs.unbind(this.evtEnd);
    this.drumEl.unbind(this.evtStart);
    this.drumEl.unbind(this.evtEnd);
    this.songs.removeClass("active");
    this.activeDrum && this.activeDrum.disconnect(0);
    this.source && this.source.disconnect(0);
    this.activeDrum = null;
    this.drumBadge.text("");
    this.drumIndex = -1;
    this.drumEl.removeClass("active");
    TWEEN.removeAll();
    for (var a = $(".shape"), b = 0, c = a.length; b <
        c; b++) {
        var d = a[b];
        this.transformElem_(d, "scale(1)");
        d.style.opacity = 1
    }
};
ww.mode.SongMode.prototype.startDrumChange_ = function () {
    this.drumIndex++;
    0 === this.drumIndex && this.drumEl.addClass("active");
    this.drumIndex < this.numDrums ? (this.drumEl.addClass("tabbing"), this.drumBadge.text(this.drumIndex + 1)) : (this.drumEl.removeClass("active"), this.drumBadge.text(""), this.drumIndex = -1, this.activeDrum.disconnect(0), this.activeDrum = null)
};
ww.mode.SongMode.prototype.changeDrums_ = function () {
    if (0 <= this.drumIndex) {
        var a = this;
        a.activeDrum && a.activeDrum.disconnect(0);
        a.playSound(a.drums[a.drumIndex], function (b) {
            a.activeDrum = b
        }, !0);
        a.drumEl.removeClass("tabbing")
    }
};
ww.mode.SongMode.prototype.swapSongMode_ = function (a) {
    this.log("swapping instrument to: " + a);
    this.trackEvent_("changed-instrument", a);
    this.songs.removeClass("active");
    $("#" + a).addClass("active");
    this.active = a
};
ww.mode.SongMode.prototype.beginSound_ = function (a) {
    this.log("now playing sound for note id: " + this.active + "-" + a);
    this.trackEvent_("play-sound", this.active + "-" + a);
    var b = this;
    b.playSound(b.active + "-" + a + ".mp3", function (a) {
        b.source = a
    });
    a = this.ripples[a];
    for (var c, d = 0, e = ~~b.source.buffer.duration, f = 0, g = a.length; f < g; f++)c = a[f], function (a, c) {
        var d = 400 * e, f = 300 * e, g = new TWEEN.Tween({scale:1, opacity:1});
        g.to({scale:1.75, opacity:0.05}, d);
        g.delay(c);
        g.onUpdate(function () {
            b.transformElem_(a, "scale(" + this.scale +
                ")");
            a.style.opacity = this.opacity
        });
        var p = new TWEEN.Tween({scale:1.75, opacity:0.05});
        p.to({scale:1, opacity:1}, f);
        p.delay(c + d);
        p.onUpdate(function () {
            b.transformElem_(a, "scale(" + this.scale + ")");
            a.style.opacity = this.opacity
        });
        b.addTween(g);
        b.addTween(p)
    }(c, d), d += 200 * e
};
ww.mode.SpaceMode = function (a, b) {
    this.preloadSound("i.mp3");
    this.preloadSound("o.mp3");
    this.world_ = this.getPhysicsWorld_();
    this.world_.viscosity = 0;
    ww.mode.Core.call(this, a, b, "space", !0, !0, !0);
    this.getPaperCanvas_();
    if (this.wantsAudio_) {
        var c = this.getAudioContext_();
        this.tuna_ = new Tuna(c);
        this.chorus_ = new this.tuna_.Chorus({rate:1, feedback:0, delay:2, bypass:0})
    }
};
goog.inherits(ww.mode.SpaceMode, ww.mode.Core);
ww.mode.SpaceMode.prototype.playSound = function (a, b, c) {
    if (this.wantsAudio_) {
        var d = this.assetPrefix_ + "sounds/" + this.name_ + "/" + a;
        this.log('Playing sound "' + a + '"');
        a = this.getAudioContext_();
        var d = this.getLoadedSoundBufferFromURL_(d), e = a.createBufferSource(), f = a.createGainNode();
        f.gain.value = 0.1;
        e.buffer = d;
        e.loop = c || !1;
        e.connect(f);
        f.connect(this.chorus_.input);
        this.chorus_.connect(a.destination);
        e.noteOn(0);
        "function" === typeof b && b(e)
    }
};
ww.mode.SpaceMode.prototype.activateI = function () {
    this.iClicked_ = !0;
    10 > this.iMultiplier_ && (this.iMultiplier_ += 2);
    this.playSound("i.mp3")
};
ww.mode.SpaceMode.prototype.activateO = function () {
    this.oClicked_ = !0;
    10 > this.oMultiplier_ && (this.oMultiplier_ += 2);
    this.playSound("o.mp3")
};
ww.mode.SpaceMode.prototype.drawI_ = function () {
    if (this.paperI_)this.copyXY_(this.iPaths_, this.iPathsX_, this.iPathsY_, !1), this.iGroup_.position = {x:this.iX + this.iWidth / 2, y:this.iY + this.iHeight / 2}, this.paperI_.position = {x:this.iX + this.iWidth / 2, y:this.iY + this.iHeight / 2}, this.iGroup_.scale(this.iWidth / this.paperI_.bounds.width), this.paperI_.scale(this.iWidth / this.paperI_.bounds.width); else {
        var a, b, c, d;
        this.iPaths_ = [];
        var e = new paper.Point(this.iX, this.iY);
        c = new paper.Size(this.iWidth, this.iHeight);
        c = new paper.Rectangle(e,
            c);
        this.paperI_ = new paper.Path.Rectangle(c);
        this.paperI_.fillColor = new paper.RgbColor(0, 0, 0, 0);
        this.iGroup_ = new paper.Group;
        for (var f = 0; f < this.iWidth / 6; f++)this.iPaths_.push(new paper.Path), a = e.x + 6 * f, b = e.y, c = new paper.Point(a, b), b = e.y + this.iHeight, d = new paper.Point(a, b), b = new paper.Point(a, this.screenCenterY_ - this.iHeight / 4), a = new paper.Point(a, this.screenCenterY_ + this.iHeight / 4), this.iPaths_[f].add(c, b, a, d), this.iGroup_.addChild(this.iPaths_[f]);
        this.iGroup_.strokeColor = "#11a860";
        this.iGroup_.strokeWidth =
            1;
        this.iPathsX_ = [];
        this.iPathsY_ = []
    }
    this.copyXY_(this.iPaths_, this.iPathsX_, this.iPathsY_, !0)
};
ww.mode.SpaceMode.prototype.drawO_ = function () {
    if (this.paperO_)this.copyXY_(this.oPaths_, this.oPathsX_, this.oPathsY_, !1), this.oGroup_.position = {x:this.oX, y:this.oY}, this.paperO_.position = {x:this.oX, y:this.oY}, this.oGroup_.scale(2 * this.oRad / this.paperO_.bounds.height), this.paperO_.scale(2 * this.oRad / this.paperO_.bounds.height); else {
        var a, b, c, d, e;
        this.oPaths_ = [];
        this.paperO_ = new paper.Path.Circle(this.oCenter, this.oRad);
        this.paperO_.fillColor = new paper.RgbColor(0, 0, 0, 0);
        this.oGroup_ = new paper.Group;
        var f =
            90, g = 2;
        640 > this.width_ && (f = 45, g = 4);
        for (var h = 0; h < f; h++)this.oPaths_.push(new paper.Path), a = this.oCenter.x + this.oRad * Math.cos(h * g * (Math.PI / 180)), b = this.oCenter.y + this.oRad * Math.sin(h * g * (Math.PI / 180)), c = new paper.Point(a, b), a = this.oCenter.x + this.oRad * Math.cos(-h * g * (Math.PI / 180)), b = this.oCenter.y + this.oRad * Math.sin(-h * g * (Math.PI / 180)), d = new paper.Point(a, b), e = d.getDistance(c), b = new paper.Point(a, this.oY + e / 4), a = new paper.Point(a, this.oY - e / 4), this.oPaths_[h].add(c, b, a, d), this.oGroup_.addChild(this.oPaths_[h]);
        this.oGroup_.strokeColor = "#3777e2";
        this.oGroup_.strokeWidth = 1;
        this.oGroup_.rotate(90);
        this.oPathsX_ = [];
        this.oPathsY_ = []
    }
    this.copyXY_(this.oPaths_, this.oPathsX_, this.oPathsY_, !0)
};
ww.mode.SpaceMode.prototype.init = function () {
    ww.mode.SpaceMode.superClass_.init.call(this);
    var a = 2 * this.width_;
    640 > this.width_ && (a = this.width_ / 2);
    this.world_ = this.getPhysicsWorld_();
    this.world_.viscosity = 0;
    this.world_.particles = this.world_.particles || [];
    for (var b = 0; b < a; b++)this.tempFloat_ = ww.util.floatComplexGaussianRandom(), this.world_.particles.push(new Particle), this.world_.particles[b].setRadius(1.4 * Math.random() + 0.1), this.world_.particles[b].pos.x = this.tempFloat_[0] * this.width_, this.world_.particles[b].pos.y =
        this.tempFloat_[1] * this.height_, this.world_.particles[b].vel.x = 0, this.world_.particles[b].vel.y = 0;
    this.deltaModifier_ = 0;
    this.tempFloat_ = [];
    this.screenCenterX_ = this.width_ / 2;
    this.screenCenterY_ = this.height_ / 2;
    this.mouseX_ = this.screenCenterX_;
    this.mouseY_ = this.screenCenterY_;
    this.iClicked_ = !1;
    this.iIncrement_ = !0;
    this.iModifier_ = 0;
    this.iMultiplier_ = 1;
    this.oClicked_ = !1;
    this.oIncrement_ = !0;
    this.oModifier_ = 0;
    this.oMultiplier_ = 1;
    0 < this.paperCanvas_.height && (this.drawI_(), this.drawO_())
};
ww.mode.SpaceMode.prototype.setupStarCanvas_ = function () {
    if (!this.$canvas_ || !this.$canvas_.length)this.$canvas_ = $("#space-canvas");
    this.canvas_ = this.canvas_ || this.$canvas_[0];
    this.canvas_.width = this.width_;
    this.canvas_.height = this.height_
};
ww.mode.SpaceMode.prototype.willFocus = function () {
    ww.mode.SpaceMode.superClass_.willFocus.call(this);
    this.setupStarCanvas_();
    var a = this, b = new paper.Point(0, 0), c = ww.util.getPointerEventNames("move", this.name_);
    $(this.containerElem_).bind(c, function (c) {
        c.preventDefault();
        c.stopPropagation();
        a.mouseX_ = a.getCoords(c).x;
        a.mouseY_ = a.getCoords(c).y;
        b = {x:a.mouseX_, y:a.mouseY_};
        a.paperO_.hitTest(b) || a.paperI_.hitTest(b) ? a.hasFocus && (document.body.style.cursor = "pointer") : document.body.style.cursor = "default"
    });
    c = ww.util.getPointerEventNames("down", this.name_);
    $(this.containerElem_).bind(c, function (b) {
        b.preventDefault();
        b.stopPropagation();
        b = a.getCoords(b);
        b = new paper.Point(b.x, b.y);
        a.lastClick = b;
        a.paperO_.hitTest(b) && a.hasFocus && a.activateO();
        a.paperI_.hitTest(b) && a.hasFocus && a.activateI()
    })
};
ww.mode.SpaceMode.prototype.didUnfocus = function () {
    ww.mode.SpaceMode.superClass_.didUnfocus.call(this);
    var a = ww.util.getPointerEventNames("move", this.name_);
    $(this.containerElem_).unbind(a + ".space");
    a = ww.util.getPointerEventNames("down", this.name_);
    $(this.containerElem_).unbind(a + ".space")
};
ww.mode.SpaceMode.prototype.onResize = function () {
    var a = this.width_, b = this.height_;
    ww.mode.SpaceMode.superClass_.onResize.call(this, !1);
    a = Math.abs(a - this.width_);
    b = Math.abs(b - this.height_);
    this.setupStarCanvas_();
    this.screenCenterX_ = this.width_ / 2;
    this.screenCenterY_ = this.height_ / 2;
    this.setPaperShapeData();
    if ((50 < a || 50 < b) && this.world_)for (b = 0; b < this.world_.particles.length; b++)this.tempFloat_ = ww.util.floatComplexGaussianRandom(), this.world_.particles[b].pos.x = this.tempFloat_[0] * this.width_, this.world_.particles[b].pos.y =
        this.tempFloat_[1] * this.height_;
    this.drawI_();
    this.drawO_();
    this.redraw()
};
ww.mode.SpaceMode.prototype.copyXY_ = function (a, b, c, d) {
    for (var e = 0; e < a.length; e++) {
        b[e] || (b[e] = []);
        c[e] || (c[e] = []);
        for (var f = 0; f < a[e].segments.length; f++)d ? (b[e][f] = a[e].segments[f].point.x, c[e][f] = a[e].segments[f].point.y) : (a[e].segments[f].point.x = b[e][f], a[e].segments[f].point.y = c[e][f])
    }
};
ww.mode.SpaceMode.prototype.adjustModifiers_ = function (a, b, c, d, e) {
    var f = 100 * this.deltaModifier_, g = 1E3 * this.deltaModifier_, h = 1E4 * this.deltaModifier_;
    a < h && !0 === b ? a += g : (1 < c ? a < h && (a += f) : (b = !1, a -= g), c = 1 < c ? c - 0.1 : 1);
    a < f && (d = !1, b = !0, c = 1);
    !0 === e ? (this.iModifier_ = a, this.iIncrement_ = b, this.iMultiplier_ = c, this.iClicked_ = d) : (this.oModifier_ = a, this.oIncrement_ = b, this.oMultiplier_ = c, this.oClicked_ = d)
};
ww.mode.SpaceMode.prototype.modCoords_ = function (a, b, c, d, e, f) {
    var g = Math.max(this.width_, this.height_) / (Math.min(this.width_, this.height_) / 2);
    return a = b ? a + Math.cos(this.framesRendered_ / 10 + (c - d)) * e * f / g : a + Math.sin(this.framesRendered_ / 10 + (c - d)) * e * f / g
};
ww.mode.SpaceMode.prototype.stepPhysics = function (a) {
    ww.mode.SpaceMode.superClass_.stepPhysics.call(this, a);
    for (a = 0; a < this.world_.particles.length; a++)this.world_.particles[a].pos.x += (this.screenCenterX_ - this.mouseX_) / (5E3 / this.world_.particles[a].radius) + 0.1, this.world_.particles[a].pos.x > 2 * this.width_ ? this.world_.particles[a].pos.x = 10 * -this.world_.particles[a].radius : this.world_.particles[a].pos.x < 2 * -this.width_ && (this.world_.particles[a].pos.x = this.width_ + 10 * this.world_.particles[a].radius), this.world_.particles[a].pos.y +=
        (this.screenCenterY_ - this.mouseY_) / (5E3 / this.world_.particles[a].radius), this.world_.particles[a].pos.y > 2 * this.height_ ? this.world_.particles[a].pos.y = 10 * -this.world_.particles[a].radius : this.world_.particles[a].pos.y < 2 * -this.height_ && (this.world_.particles[a].pos.y = this.width_ + 10 * this.world_.particles[a].radius)
};
ww.mode.SpaceMode.prototype.onFrame = function (a) {
    ww.mode.SpaceMode.superClass_.onFrame.call(this, a);
    var b;
    if (this.canvas_) {
        var c = this.canvas_.getContext("2d");
        c.fillStyle = "#e4e4e4";
        c.clearRect(0, 0, this.canvas_.width + 1, this.canvas_.height + 1);
        for (b = 0; b < this.world_.particles.length; b++)c.beginPath(), c.arc(this.world_.particles[b].pos.x + 0.5, this.world_.particles[b].pos.y + 0.5, this.world_.particles[b].radius, 0, 2 * Math.PI), c.closePath(), c.fill();
        this.deltaModifier_ = a / 100;
        if (!0 === this.iClicked_) {
            this.adjustModifiers_(this.iModifier_,
                this.iIncrement_, this.iMultiplier_, this.iClicked_, !0);
            this.wantsAudio_ && (this.chorus_.feedback = Math.min(this.iMultiplier_ / 10, 1));
            for (b = 0; b < this.iPaths_.length; b++)this.tempFloat_ = ww.util.floatComplexGaussianRandom(), this.iPaths_[b].segments[0].point.x = this.modCoords_(this.iPathsX_[b][0], !0, this.iGroup_.position.x, this.iPathsX_[b][0], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[0].point.y = this.modCoords_(this.iPathsY_[b][0], !1, this.iGroup_.position.y, this.iPathsY_[b][0], this.iModifier_,
                this.iMultiplier_), this.iPaths_[b].segments[1].point.x = this.modCoords_(this.iPathsX_[b][1], !1, this.iGroup_.position.x, this.iPathsX_[b][1], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[1].point.y = this.modCoords_(this.iPathsY_[b][1], !0, this.iGroup_.position.y, this.iPathsY_[b][1], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[2].point.x = this.modCoords_(this.iPathsX_[b][2], !0, this.iGroup_.position.x, this.iPathsX_[b][2], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[2].point.y =
                this.modCoords_(this.iPathsY_[b][2], !1, this.iGroup_.position.y, this.iPathsY_[b][2], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[3].point.x = this.modCoords_(this.iPathsX_[b][3], !1, this.iGroup_.position.x, this.iPathsX_[b][3], this.iModifier_, this.iMultiplier_), this.iPaths_[b].segments[3].point.y = this.modCoords_(this.iPathsY_[b][3], !0, this.iGroup_.position.y, this.iPathsY_[b][3], this.iModifier_, this.iMultiplier_), this.iPaths_[b].smooth()
        } else this.copyXY_(this.iPaths_, this.iPathsX_, this.iPathsY_,
            !1);
        if (!0 === this.oClicked_) {
            this.adjustModifiers_(this.oModifier_, this.oIncrement_, this.oMultiplier_, this.oClicked_, !1);
            this.wantsAudio_ && (this.chorus_.feedback = Math.min(this.oMultiplier_ / 10, 1));
            for (b = 0; b < this.oPaths_.length; b++)this.tempFloat_ = ww.util.floatComplexGaussianRandom(), this.oPaths_[b].segments[0].point.x = this.modCoords_(this.oPathsX_[b][0], !0, 0, 0, this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[0].point.y = this.modCoords_(this.oPathsY_[b][0], !1, 0, 0, this.oModifier_, this.oMultiplier_),
                this.oPaths_[b].segments[1].point.x = this.modCoords_(this.oPathsX_[b][1], !1, 0, 0, this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[1].point.y = this.modCoords_(this.oPathsY_[b][1], !0, this.oPathsY_[b][1], 0.95 * this.oPathsY_[b][1], this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[2].point.x = this.modCoords_(this.oPathsX_[b][2], !0, 0, 0, this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[2].point.y = this.modCoords_(this.oPathsY_[b][2], !1, this.oPathsY_[b][2], 0.95 * this.oPathsY_[b][2],
                this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[3].point.x = this.modCoords_(this.oPathsX_[b][3], !1, 0, 0, this.oModifier_, this.oMultiplier_), this.oPaths_[b].segments[3].point.y = this.modCoords_(this.oPathsY_[b][3], !0, 0, 0, this.oModifier_, this.oMultiplier_), this.oPaths_[b].smooth()
        } else this.copyXY_(this.oPaths_, this.oPathsX_, this.oPathsY_, !1)
    }
};
ww.mode.SynthMode = function (a, b) {
    ww.mode.Core.call(this, a, b, "synth", !0, !0, !1)
};
goog.inherits(ww.mode.SynthMode, ww.mode.Core);
ww.mode.SynthMode.prototype.init = function () {
    ww.mode.SynthMode.superClass_.init.call(this);
    this.evtStart = ww.util.getPointerEventNames("down", "synth");
    this.evtEnd = ww.util.getPointerEventNames("up", "synth");
    var a = this.getAudioContext_();
    this.source = a.createOscillator();
    this.gain = a.createGainNode();
    this.gain.gain.value = 0.01;
    this.tuna_ = new Tuna(a);
    this.analyser = a.createAnalyser();
    this.analyser.fftSize = 512;
    this.analyser.smoothingTimeConstant = 0.85;
    this.waveforms = $("#waveforms");
    this.detune = document.getElementById("oscillator-detune");
    this.isPlaying = !1;
    this.buildEffects_();
    this.count = 360 * (this.width_ % 360);
    this.letterI = $("#synth-letter-i");
    this.letterO = $("#synth-letter-o");
    this.waveType = 1;
    this.lastFreq = 80;
    this.lastDetune = 650;
    this.createSound_();
    this.waveMap = ["sine", "square", "saw", "triangle"];
    var b = this;
    setTimeout(function () {
        b.onResize(!0)
    }, 800)
};
ww.mode.SynthMode.prototype.onFrame = function (a) {
    ww.mode.SynthMode.superClass_.onFrame.call(this, a);
    if (this.isPlaying) {
        this.count -= 300 * a;
        this.duration += a;
        a = new Uint8Array(this.analyser.frequencyBinCount);
        this.analyser.getByteFrequencyData(a);
        for (var b, c, d = 0, e = this.paths.length; d < e; d++) {
            for (var f = 0, g = a.length / 2; f < g; f++)b = this.centerY - 0.75 * a[f], c = b === this.centerY ? 0 : 5 * d, this.paths[d].segments[f].point.y = b + c;
            this.paths[d].smooth()
        }
    }
};
ww.mode.SynthMode.prototype.onResize = function (a) {
    ww.mode.SynthMode.superClass_.onResize.call(this, !1);
    this.centerY = 500 > this.height_ ? this.height_ / 2 + (this.height_ - 256) / 2 : this.height_ / 2 + 128;
    this.scale = ~~(0.5 * this.height_);
    this.canvas_ && (this.canvas_.width = this.width_, this.canvas_.height = this.height_);
    this.oOffset = this.letterO.offset();
    this.oSize = this.letterO[0].getBoundingClientRect().width;
    this.oRad = this.oSize / 2;
    this.oLeft = this.oOffset.left + this.oRad;
    this.oTop = this.oOffset.top + this.oRad;
    this.circle &&
        this.tracker && (this.currentRad = this.circle.bounds.width / 2, this.circle.position.x = this.oLeft, this.circle.position.y = this.oTop, this.circle.scale(this.oRad / this.currentRad), this.circleClone.position.x = this.oLeft, this.circleClone.position.y = this.oTop, this.circleClone.scale(this.oRad / this.currentRad), this.currentRad = this.tracker.bounds.width / 2, this.tracker.position.x = this.oLeft, this.tracker.position.y = this.oTop, this.tracker.scale(0.08 * this.oRad / this.currentRad));
    if (this.paths) {
        Math.max(2 * this.oRad, 128);
        for (var b = 2 * this.oRad / 128, c = 0, d = this.paths.length; c < d; c++)for (var e = 0, f = this.paths[c].segments.length; e < f; e++)this.paths[c].segments[e].point.x = b * e + this.oLeft - this.oRad, this.paths[c].segments[e].point.y = this.centerY
    }
    a && this.redraw();
    a = this.letterI[0].getBoundingClientRect();
    var b = this.letterI.position(), g = ~~a.height;
    this.waveforms.css({top:~~b.top + "px", left:~~b.left + "px", height:g + "px", width:~~a.width + "px"});
    var h = this;
    setTimeout(function () {
        var a = h.waveforms.find("li"), b = a.height(), b = g - 4 * b, b = b / 4.5;
        a.css("margin-top", ~~b)
    }, 100)
};
ww.mode.SynthMode.prototype.didFocus = function () {
    ww.mode.SynthMode.superClass_.didFocus.call(this);
    var a = this;
    a.centerY = 500 > a.height_ ? a.height_ / 2 + (a.height_ - 256) / 2 : a.height_ / 2 + 128;
    a.scale = ~~(0.5 * a.height_);
    a.waveHeight = ~~(a.height_ / 2);
    if (!a.path && !a.points) {
        a.getPaperCanvas_();
        Math.max(2 * a.oRad, 128);
        var b = 2 * a.oRad / 128;
        a.circle = new paper.Path.Circle(new paper.Point(a.oLeft, a.oTop), a.oRad);
        a.circleClone = a.circle.clone();
        a.circleClone.fillColor = "#3777e3";
        a.circleClone.opacity = 0.9;
        a.tracker = new paper.Path.Circle(new paper.Point(a.oLeft,
            a.oTop), 0.08 * a.oRad);
        a.tracker.fillColor = "#ffffff";
        a.tracker.strokeColor = "#ffffff";
        a.tracker.strokeColor.alpha = 0.3;
        a.tracker.strokeWidth = 0.05 * a.oRad;
        a.tracker.opacity = 0.7;
        a.path = new paper.Path;
        a.path.strokeColor = new paper.RgbColor(255, 255, 255, 0.2);
        a.path.strokeWidth = 5;
        for (var c = 0; 128 >= c; c++) {
            var d = new paper.Point(b * c + a.oLeft - a.oRad, a.centerY);
            a.path.add(d)
        }
        a.paths = [];
        a.paths.push(a.path);
        for (b = 0; 3 > b; b++)c = a.path.clone(), a.paths.push(c);
        a.oscilloGroup = new paper.Group(a.circle, a.paths[0], a.paths[1],
            a.paths[2], a.paths[3], a.tracker);
        a.oscilloGroup.clipped = !0;
        a.duration = 0
    }
    a.isPlaying = !1;
    a.connectPower_();
    a.letterI.bind(this.evtEnd, function () {
        a.changeWaveType()
    });
    a.letterO.bind(this.evtStart, function () {
        a.padTouchOn = !0;
        a.lastFreq = a.calculateFrequency(event.pageX, event.pageY)
    });
    a.letterO.bind(this.evtEnd, function () {
        a.changeFrequency(event);
        a.moveTracker(event);
        a.padTouchOn = !1
    });
    b = ww.util.getPointerEventNames("move", this.name_);
    a.letterO.bind(b, function () {
        a.padTouchOn && (a.changeFrequency(event), a.moveTracker(event))
    });
    a.oOffset = a.letterO.offset();
    a.oSize = a.letterO[0].getBoundingClientRect().width
};
ww.mode.SynthMode.prototype.didUnfocus = function () {
    ww.mode.SynthMode.superClass_.didUnfocus.call(this);
    this.letterI.unbind(this.evtEnd);
    this.letterO.unbind(this.evtStart);
    this.letterO.unbind(this.evtEnd);
    var a = ww.util.getPointerEventNames("move", this.name_);
    this.letterO.unbind(a);
    this.isPlaying = !0;
    this.connectPower_()
};
ww.mode.SynthMode.prototype.buildEffects_ = function () {
    this.effects = {};
    this.effects.delay = new this.tuna_.Delay
};
ww.mode.SynthMode.prototype.createSound_ = function () {
    this.source.type = this.waveType;
    this.source.frequency.value = this.lastFreq;
    this.source.detune.value = this.lastDetune
};
ww.mode.SynthMode.prototype.connectPower_ = function () {
    this.isPlaying ? (this.pauseSound_(), this.isPlaying = !1) : (this.playSound_(), this.isPlaying = !0)
};
ww.mode.SynthMode.prototype.playSound_ = function () {
    var a = this.getAudioContext_();
    this.source.connect(this.effects.delay.input);
    this.effects.delay.connect(this.analyser);
    this.analyser.connect(this.gain);
    this.gain.connect(a.destination);
    this.source.noteOn(0)
};
ww.mode.SynthMode.prototype.pauseSound_ = function () {
    this.source.disconnect()
};
ww.mode.SynthMode.prototype.changeWaveType = function () {
    this.waveType++;
    this.waveType = 3 < this.waveType ? 0 : this.waveType;
    this.createSound_();
    $(".on", this.waveforms).removeClass("on");
    $("." + this.waveMap[this.waveType], this.waveforms).addClass("on")
};
ww.mode.SynthMode.prototype.changeFrequency = function (a) {
    this.calculateFrequency(a.pageX, a.pageY);
    this.createSound_()
};
ww.mode.SynthMode.prototype.moveTracker = function (a) {
    this.tracker.position.x = a.pageX;
    this.tracker.position.y = a.pageY
};
ww.mode.SynthMode.prototype.calculateFrequency = function (a, b) {
    var c = a - this.oOffset.left, d = b - this.oOffset.top, c = c / this.oSize, d = d / this.oSize;
    this.lastFreq = 1E3 - 1E3 * d;
    this.lastDetune = -4800 + 9600 * c
};
ww.mode.modes = {};
ww.mode.register = function (a, b, c, d) {
    ww.mode.modes[a] = {klass:b, pattern:c, len:d}
};
ww.mode.findModeByName = function (a) {
    return ww.mode.modes[a]
};
ww.mode.register("home", ww.mode.HomeMode, null);
ww.mode.register("cat", ww.mode.CatMode, 231, 8);
var isAndroid = navigator.userAgent.match(/Android/);
isAndroid || ww.mode.register("space", ww.mode.SpaceMode, 42, 8);
ww.mode.register("pong", ww.mode.PongMode, 129, 8);
ww.mode.register("bacon", ww.mode.BaconMode, 144, 8);
ww.mode.register("simone", ww.mode.SimoneMode, 211, 8);
ww.mode.register("eightbit", ww.mode.EightBitMode, 83, 8);
ww.util.getAudioContextConstructor() && (ww.mode.register("song", ww.mode.SongMode, 219, 8), ww.mode.register("synth", ww.mode.SynthMode, 136, 8));
ww.mode.register("ascii", ww.mode.AsciiMode, 127, 8);
ww.mode.register("bowling", ww.mode.BowlingMode, 117, 8);
ww.mode.register("rocket", ww.mode.RocketMode, 69, 8);
ww.mode.register("burger", ww.mode.BurgerMode, 57, 8);
ww.testMode && $(function () {
    var a = window.location.href.split("/"), a = a[a.length - 1], b = a.replace("_test.html", ".html").replace(/\.html(.*)/, "");
    if ((a = ww.mode.findModeByName(b)) && a.klass) {
        var c = $(window).width(), d = $(window).height();
        1 > d && (d = c);
        b = $("<div></div>").addClass("mode").addClass(b + "-mode");
        b.css({width:c, height:d});
        $("body > *").wrapAll(b);
        window.currentMode = new a.klass($(".mode")[0], ww.testMode ? "../../" : "../");
        $(window).resize(ww.util.throttle(function () {
            $(".mode").css({width:$(window).width(),
                height:$(window).height()});
            window.currentMode.onResize(!0)
        }, 50))
    }
});
ww.app = {};
ww.app.Core = function () {
    this.isSupported_ = Modernizr.svg && Modernizr.csstransforms && Modernizr.canvas;
    var a = ww.util.getPointerEventNames("up", "app");
    if (!this.isSupported_) {
        $(document.body).addClass("unsupported");
        var b = $("#menu-fallback"), c = $("#modal-fallback"), d = $("#dropdown-fallback");
        b.bind(a, function (a) {
            $(a.target).is("a, label") || $("#unsupported").addClass("modal-visible")
        });
        c.bind(a, function (a) {
            $(a.target).is("a, label") || $("#unsupported").removeClass("modal-visible")
        });
        d.bind(a, function (a) {
            $(a.target).is("a, label") || (a.preventDefault(),
                a.stopPropagation())
        });
        Modernizr.touch && ($(".has-dropdown label").bind(a, function () {
            $(e.containerElem_).addClass("nav-visible");
            $(".dropdown-visible").removeClass("dropdown-visible");
            $(this).closest(".has-dropdown").addClass("dropdown-visible")
        }), $(window).bind(a, function (a) {
            $(a.target).is("a, label, #menu") || ($(e.containerElem_).removeClass("nav-visible"), $(".dropdown-visible").removeClass("dropdown-visible"))
        }))
    }
    this.transformKey_ = Modernizr.prefixed("transform");
    this.$window_ = $(window);
    this.height_ =
        this.width_ = 0;
    var e = this;
    this.$window_.resize(ww.util.throttle(function () {
        e.onResize_()
    }, 50));
    this.onResize_();
    this.isSupported_ && (this.history_ = window.History, this.history_.Adapter.bind(window, "statechange", function () {
        var a = e.history_.getState(), a = a.url.split("/"), a = a[a.length - 1].replace("experiment-", "");
        ww.mode.modes[a] ? e.loadModeByName_(a, !0) : e.loadModeByName_("home", !0, !0)
    }), Modernizr.touch && (document.body.style[Modernizr.prefixed("userSelect")] = "none", document.body.style[Modernizr.prefixed("userDrag")] =
        "none", document.body.style[Modernizr.prefixed("tapHighlightColor")] = "rgba(0,0,0,0)", b = ww.util.getPointerEventNames("move", "app"), this.$window_.bind(b, function (a) {
        a.preventDefault();
        a.stopPropagation()
    }), this.$window_.bind(a, function (a) {
        $(a.target).is("a, label") || (a.preventDefault(), a.stopPropagation())
    }), a = ww.util.getPointerEventNames("down", "app"), this.$window_.bind(a, function (a) {
        $(a.target).is("a, label") || (a.preventDefault(), a.stopPropagation())
    }), this.$window_.bind("dblclick.app", function (a) {
        a.preventDefault();
        a.stopPropagation()
    })), e.start_())
};
ww.app.Core.prototype.onResize_ = function () {
    this.width_ = this.$window_.width();
    this.height_ = this.$window_.height();
    $("#wrapper").css({width:this.width_, height:this.height_});
    this.fallbackCenterX_ = Math.floor(this.width_ / 2);
    this.fallbackCenterY_ = Math.floor(this.height_ / 2);
    this.fallbackWidth_ = 425;
    this.fallbackHeight_ = 318;
    $(".logo-io-fallback").hasClass("mobile-logo") && $(".logo-io-fallback").removeClass("mobile-logo");
    var a = window.devicePixelRatio;
    if (525 > this.width_ / a || 418 > this.height_ / a)this.fallbackWidth_ =
        318, this.fallbackHeight_ = 238, $(".logo-io-fallback").addClass("mobile-logo");
    this.fallbackX_ = this.fallbackCenterX_ - this.fallbackWidth_ / 2;
    this.fallbackY_ = this.fallbackCenterY_ - this.fallbackHeight_ / 2;
    $(".bounds-fallback").css({left:this.fallbackX_, top:this.fallbackY_, width:this.fallbackWidth_ + "px", height:this.fallbackHeight_ + "px"});
    $(".logo-io-fallback").css({width:this.fallbackWidth_ + "px", height:this.fallbackHeight_ + "px"});
    if (this.isSupported_ && this.loadedModes_)for (var b in this.loadedModes_)if (this.loadedModes_.hasOwnProperty(b) &&
        (a = this.loadedModes_[b], a.containerElem && (a.containerElem.style.width = this.width_ + "px", a.containerElem.style.height = this.height_ + "px"), a.instance))a.instance.onResize(!0)
};
ww.app.Core.prototype.start_ = function () {
    this.onReady_ = function () {
    };
    this.loadModeByName_("home", !1)
};
ww.app.Core.prototype.postMessage = function (a) {
    this.log_("Got message: " + a.name, a);
    if (a.name.match(/.ready/))this.onReady_(a); else"goToMode" === a.name ? this.history_.pushState(null, "Google I/O 2013", "experiment-" + a.data) : "goToHome" === a.name && this.history_.back()
};
ww.app.Core.prototype.loadModeByName_ = function (a, b, c) {
    this.loadedModes_ = this.loadedModes_ || {};
    this.loadedModes_[a] = this.loadedModes_[a] || {name:a};
    this.loadMode_(this.loadedModes_[a], b, c)
};
ww.app.Core.prototype.log_ = function () {
};
ww.app.Core.prototype.trackEvent_ = function (a, b) {
    ww.util.trackEvent("app", a, b)
};
ww.app.Core.prototype.translateXString_ = function (a) {
    return Modernizr.csstransforms3d ? "translate3d(" + a + "px, 0, 0)" : "translate(" + a + "px, 0)"
};
ww.app.Core.prototype.loadMode_ = function (a, b, c) {
    var d, e = this.currentMode, f = this;
    if (!(e && e.name == a.name))if (e && (e.instance.postMessage({name:"unfocus", data:null}), e.containerElem.style.pointerEvents = "none"), d = b ? function () {
        a.instance.postMessage({name:"focus", data:null});
        var b = c ? -f.width_ : f.width_;
        a.containerElem.style[f.transformKey_] = f.translateXString_(b);
        a.containerElem.style.visibility = "visible";
        setTimeout(function () {
                var c = new TWEEN.Tween({translateX:b});
                c.to({translateX:0}, 800);
                c.easing(TWEEN.Easing.Exponential.InOut);
                c.onUpdate(function () {
                    a.containerElem.style[f.transformKey_] = f.translateXString_(this.translateX)
                });
                c.onComplete(function () {
                    a.containerElem.style.pointerEvents = "auto"
                });
                c.start();
                if (e) {
                    var c = -b, d = new TWEEN.Tween({translateX:0});
                    d.easing(TWEEN.Easing.Exponential.InOut);
                    d.to({translateX:c}, 800);
                    d.onUpdate(function () {
                        e.containerElem.style[f.transformKey_] = f.translateXString_(this.translateX)
                    });
                    d.onComplete(function () {
                        e.containerElem.style.visibility = "hidden"
                    });
                    d.start()
                }
                ww.raf.subscribe("app", f, f.renderFrame_)
            },
            10)
    } : function () {
        a.instance.postMessage({name:"focus", data:null});
        a.containerElem.style.visibility = "visible";
        a.containerElem.style.pointerEvents = "auto"
    }, a.instance)this.currentMode = a, "function" === typeof d && d(); else {
        this.onReady_ = function (b) {
            b.name === a.name + ".ready" && "function" === typeof d && d();
            this.onReady_ = function () {
            }
        };
        var g = document.createElement("div");
        g.className = "mode " + a.name + "-mode";
        g.style.visibility = "hidden";
        g.style.pointerEvents = "none";
        g.style.width = this.width_ + "px";
        g.style.height = this.height_ +
            "px";
        this.fetchModeContent_(a.name, function (b) {
            $(g).html(b).appendTo($("#wrapper"));
            if ((b = ww.mode.findModeByName(a.name)) && b.klass)a.instance = new b.klass(g, ww.testMode ? "../../" : "");
            f.currentMode = a;
            a.containerElem = g
        })
    }
};
ww.app.Core.prototype.fetchModeContent_ = function (a, b) {
    var c = "modes/" + a + ".html?" + +new Date;
    ww.testMode && (c = "../../" + c);
    $.ajax({url:c, type:"GET", dataType:"html", complete:function (a, c, f) {
        f = a.responseText;
        a.isResolved() && (a.done(function (a) {
            f = a
        }), a = f.split("<body>")[1], a = a.split("</body>")[0], b(a))
    }})
};
ww.app.Core.prototype.renderFrame_ = function () {
    TWEEN.update() || ww.raf.unsubscribe("app")
};
window.ww = window.ww || {};
window.ww.app = window.ww.app || {};
window.ww.app.Core = ww.app.Core;
goog.exportSymbol("ww.app.Core", ww.app.Core);