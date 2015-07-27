# Angular.js stuff. This can't wait til after page load, it needs to happen in the <head>

@app = angular.module 'ChefStepsApp', ["ngResource", "ui", "ui.bootstrap", "ui.select2", "LocalStorageModule", "templates", "ngGrid", "infinite-scroll", "angularPayments", "googlechart", "contenteditable", "ngSanitize", "ngRoute", "ngAnimate", "once", "cs.api", "csConfig", "cs.components", "cs.helpers"], ["$locationProvider", "$routeProvider", ($locationProvider, $routeProvider) ->

  #window.logPerf("ANGULAR INIT")
  #angular.element(document).ready ->
    #window.logPerf("DOCUMENT READY")

  # Don't make this true!! It will break every link on the page that isn't to
  # an angular known url. The addr bar changes but content doesn't load.
  # See https://groups.google.com/forum/#!topic/angular/cUjy9PEDeWE .
  # NOTE: WORTH TRYING AGAIN now that we are on a much more recent angular
  $locationProvider.html5Mode(false)
  $locationProvider.hashPrefix()

  # These dummy actions are needed to get routeChangeSuccess to be called
  $routeProvider
    .when("/", { action: "dummyAction2" })
    .when("/:slug", { action: "dummyAction" })
    .when("/:includable_type/:includable_slug", { action: "dummyAction3" })

]

# Thank god for Stack Overflow!
# http://stackoverflow.com/questions/14210218/http-get-to-a-rails-applicationcontroller-gives-http-error-406-not-acceptable
@app.config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"

  # http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on
  # This seems weird since we already have this in application_controller.rb, but this fixes the issue where people couldn't enroll into a class on Firefox
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content')
]

angular.module('ChefStepsApp').run ["$rootScope", ($rootScope) ->
  # Split test params, b/c they often go across controllers
  $rootScope.splits = {}
  # $rootScope.splits = { meatLandingFancy : Math.random() > 0.5}

  # Set configuration options from the environment
  $rootScope.environmentConfiguration =
    google_app_id: null # This is for google connect it's the application id
    environment: null # This is the rails environment that is currently running
]


# For google plus
angular.module('ChefStepsApp').run ["$window", "$rootScope", "csFacebook", ($window, $rootScope, csFacebook) ->
  $window.signInCallback =  (authResult) ->
    if(authResult && authResult.access_token)
      # http://stackoverflow.com/questions/20837839/blocked-frame-error-when-signing-in-with-gplus-implemented-with-angularjs
      authResult['g-oauth-window'] = ""
      $rootScope.$broadcast('event:google-plus-signin-success',authResult)
    else
      $rootScope.$broadcast('event:google-plus-signin-failure',authResult)

  $window.render = ->
    $rootScope.$broadcast('event:google-plus-loaded')

  $window.facebookLoginStatus =  (loggedIn) ->
    csFacebook.setLoggedIn(loggedIn)
]

# For permissions
angular.module('ChefStepsApp').run ["$rootScope", "csPermissions", ($rootScope, csPermissions) ->
  $rootScope.hasPermission = (action) ->
    csPermissions.check(action)
]

@$$parse = (url) ->
  matchUrl url, this
  withoutBaseUrl = beginsWith(appBase, url) or beginsWith(appBaseNoFile, url)
  throw new Error("Invalid url \"" + url + "\", does not start with \"" + appBase + "\".")  unless isString(withoutBaseUrl)
  withoutHashUrl = (if withoutBaseUrl.charAt(0) is "#" then beginsWith(hashPrefix, withoutBaseUrl) else withoutBaseUrl)
  throw new Error("Invalid url \"" + url + "\", missing hash prefix \"" + hashPrefix + "\".")  unless isString(withoutHashUrl)
  matchAppUrl withoutHashUrl, this
  @$$compose()
