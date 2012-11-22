class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader,
      model: @currentUser,
      registrationCompletionPath: @registrationCompletionPath
    )
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')
      return unless query
      profileView.showEditProfile() if query.edit
