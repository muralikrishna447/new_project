# Angular.js stuff. This can't wait til after page load, it needs to happen in the <head>

angular.module 'ChefStepsApp', ["ngResource", "ui", "ui.bootstrap"], ["$locationProvider", ($locationProvider) ->
  # Don't make this true!! It will break every link on the page that isn't to
  # an angular known url. The addr bar changes but content doesn't load.
  # See https://groups.google.com/forum/#!topic/angular/cUjy9PEDeWE .
  # True was nice b/c it makes $location.search() provide what we want for activity.get(),
  # but it was easier to workaround as seen in ActivityController
  $locationProvider.html5Mode(false)
  $locationProvider.hashPrefix()
]

# Thank god for Stack Overflow!
# http://stackoverflow.com/questions/14210218/http-get-to-a-rails-applicationcontroller-gives-http-error-406-not-acceptable
angular.module('ChefStepsApp').config ["$httpProvider", ($httpProvider) ->
  $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"
]
