class ChefSteps.Router extends Backbone.Router
  initialize: (options) =>
    @currentUser = options.currentUser

  routes:
    "profiles/:id": "showEditProfile"
    "profiles:/id/?edit": "showEditProfile"

  showProfile: (id) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile')
      new ChefSteps.Views.ProfileHeader(model: @currentUser, el: '.profile-info')

  showEditProfile: (id) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      new ChefSteps.Views.Profile(model: @currentUser, el: '.user-profile').showEditProfile()
      new ChefSteps.Views.ProfileHeader(model: @currentUser, el: '.profile-info')

