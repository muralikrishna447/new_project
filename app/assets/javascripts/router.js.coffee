class ChefSteps.Router
  constructor: (options) ->
    @currentUser = options.currentUser
    @crossroads = crossroads.create()

  initializeRoutes: =>
    _.each(@routes, (callback, route) =>
      @crossroads.addRoute(route, @[callback])
    )

  parse: (hash) =>
    @crossroads.parse(hash)

  routes:
      "/profiles/{id}{?query}": "showProfile"
      "/profiles/{id}": "showProfile"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      prof = new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')
      if (query["new_user"]?)
        prof.setCompletionURL("/thank-you")
      if (query["edit"]? && query["edit"] == "1")
        prof.showEditProfile()
      new ChefSteps.Views.ProfileHeader(model: @currentUser, el: '.profile-info')