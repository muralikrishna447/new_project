

//=require navigation_bootstrap
//=require jquery
//=require active_admin
//=require jquery.min
//=require angular.min
//=require angular-resource.min
//=require angular-route.min
//=require angular-sanitize.min
//=require angular-animate.min
//=require angular-ui
//=require application_head
//=require application
//=require angular-mocks
//=require_tree .
//= require bloom/bloom

window.logPerf = function() {};

// Working around https://github.com/pivotal/jasmine/issues/334 - fun!
angular.mock.clearDataCache = function() {
    var key,
        cache = angular.element.cache;

    for(key in cache) {
        if (cache.hasOwnProperty(key)) {
            var handle = cache[key].handle;

            //handle && angular.element(handle.elem).unbind();
            delete cache[key];
        }
    }
};

