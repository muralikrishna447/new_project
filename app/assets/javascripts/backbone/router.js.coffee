class ChefSteps.Router extends Backbone.Router
  routes:
    "profiles/:id": "showProfile"

  showProfile: (id) ->
    ChefSteps.foo = new ChefSteps.Views.Profile(model: ChefSteps.profile, el: '.user-profile')

