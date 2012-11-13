window.ChefSteps ||= {}
window.ChefSteps.Models ||= {}
window.ChefSteps.Views ||= {}

ChefSteps.init = (options)->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

  ChefSteps.profile = new ChefSteps.Models.Profile(options.profile)

  ChefSteps.router = new ChefSteps.Router()
  Backbone.history.start(pushState: true)


