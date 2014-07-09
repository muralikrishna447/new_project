//=require navigation_bootstrap
//=require jquery.min
//=require active_admin
//=require angular.min
//=require angular-resource.min
//=require angular-route.min
//=require angular-sanitize.min
//=require angular-animate.min
//=require angular-ui
//=require application
//=require angular-mocks
//=require_tree .

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

// Mock bloom to get tests to pass
window.Bloom = jasmine.createSpyObj('Bloom', ['configure', 'installComments']);