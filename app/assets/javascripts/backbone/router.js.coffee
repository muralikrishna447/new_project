class ChefSteps.Router extends Backbone.Router
  initialize: (options) =>
    @currentUser = options.currentUser
    if @currentUser
      new ChefSteps.Views.ProfileHeader(model: @currentUser, el: '.profile-info').render()

  routes:
    "profiles/:id": "showProfile"

  showProfile: (id) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')

