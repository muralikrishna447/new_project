class ChefSteps.Router extends Backbone.Router
  initialize: (options) =>
    @currentUserId = options.currentUserId

  routes:
    "profiles/:id": "showProfile"

  showProfile: (id) =>
    if id == @currentUserId
      new ChefSteps.Views.Profile(model: ChefSteps.profile, el: '.user-profile')

