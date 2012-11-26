class ChefSteps.BaseRouter
  constructor: (options) ->
    @crossroads = crossroads.create()
    @initialize(options)

  initialize: (options) =>
    @

  initializeRoutes: =>
    _.each(@routes, (callback, route) =>
      @crossroads.addRoute(route, @[callback])
    )

  parse: (hash) =>
    @crossroads.parse(hash)

  routes: {}

