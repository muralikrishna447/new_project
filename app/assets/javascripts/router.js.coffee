class ChefSteps.Router
  constructor: (options) ->
    @currentUser = options.currentUser
    @crossroads = crossroads.create()
    @registrationCompletionPath = options.registrationCompletionPath

  initializeRoutes: =>
    _.each(@routes, (callback, route) =>
      @crossroads.addRoute(route, @[callback])
    )

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  parse: (hash) =>
    @crossroads.parse(hash)

  routes:
    "/profiles/{id}": "showProfile"
    "/profiles/{id}:?query:": "showProfile"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')
      profileView.setCompletionURL(@registrationCompletionPath) if query.new_user
      profileView.showEditProfile() if query.edit
