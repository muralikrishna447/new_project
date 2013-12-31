# Angular.js stuff. This can't wait til after page load, it needs to happen in the <head>


@app = angular.module 'ChefStepsApp', ["ngResource", "ui", "ui.bootstrap", "LocalStorageModule", "templates", "ngGrid", "infinite-scroll", "angularPayments", "googlechart", "contenteditable", "ngSanitize"], ["$locationProvider", "$routeProvider", ($locationProvider, $routeProvider) ->

  # Don't make this true!! It will break every link on the page that isn't to
  # an angular known url. The addr bar changes but content doesn't load.
  # See https://groups.google.com/forum/#!topic/angular/cUjy9PEDeWE .
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
]

@$$parse = (url) ->
  matchUrl url, this
  withoutBaseUrl = beginsWith(appBase, url) or beginsWith(appBaseNoFile, url)
  throw new Error("Invalid url \"" + url + "\", does not start with \"" + appBase + "\".")  unless isString(withoutBaseUrl)
  withoutHashUrl = (if withoutBaseUrl.charAt(0) is "#" then beginsWith(hashPrefix, withoutBaseUrl) else withoutBaseUrl)
  throw new Error("Invalid url \"" + url + "\", missing hash prefix \"" + hashPrefix + "\".")  unless isString(withoutHashUrl)
  matchAppUrl withoutHashUrl, this
  @$$compose()

