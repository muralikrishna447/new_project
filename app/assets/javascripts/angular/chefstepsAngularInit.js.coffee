# Angular.js stuff. This can't wait til after page load, it needs to happen in the <head>

angular.module 'ChefStepsApp', ["ngResource", "ui", "ui.bootstrap"], ["$locationProvider", ($locationProvider) ->
  # Don't make this true!! It will break every link on the page that isn't to
  # an angular known url. The addr bar changes but content doesn't load.
  # See https://groups.google.com/forum/#!topic/angular/cUjy9PEDeWE .
  # True was nice b/c it makes $location.search() provide what we want for activity.get(),
  # but it was easier to workaround as below
  $locationProvider.html5Mode(false)
]
