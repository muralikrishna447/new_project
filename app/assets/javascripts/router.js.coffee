class ChefSteps.Router
  constructor: (options) ->
    @currentUser = options.currentUser
    @crossroads = crossroads.create()

  initializeRoutes: =>
    _.each(@routes, (callback, route) =>
      @crossroads.addRoute(route, @[callback])
    )

  loadHeader: =>
    if @currentUser
      headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser, el: '.profile-info')
      headerView.render()

  parse: (hash) =>
    @crossroads.parse(hash)

  routes:
    "/profiles/{id}": "showProfile"

  showProfile: (id) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')

