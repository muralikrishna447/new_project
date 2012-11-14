window.ChefSteps ||= {}
window.ChefSteps.Models ||= {}
window.ChefSteps.Views ||= {}

ChefSteps.init = (options)->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

  if options.profile
    ChefSteps.profile = new ChefSteps.Models.Profile(options.profile)

    new ChefSteps.Views.ProfileHeader(model: ChefSteps.profile, el: '.profile-info')

  ChefSteps.router = new ChefSteps.Router(currentUserId: options.currentUserId)
  Backbone.history.start(pushState: true)


