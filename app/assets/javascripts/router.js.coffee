class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile
        model: @currentUser,
        el: '.user-profile',
        registrationCompletionPath: @registrationCompletionPath,
        newUser: query && query.new_user
