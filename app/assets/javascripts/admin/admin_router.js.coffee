class ChefStepsAdmin.Router
  constructor: (options) ->
    @crossroads = crossroads.create()

  initializeRoutes: =>
    _.each(@routes, (callback, route) =>
      @crossroads.addRoute(route, @[callback])
    )

  parse: (hash) =>
    @crossroads.parse(hash)

  routes:

