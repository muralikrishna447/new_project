window.ChefSteps ||= {}
window.ChefSteps.Models ||= {}
window.ChefSteps.Views ||= {}

ChefSteps.init = (options)->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

  if options.profile
    ChefSteps.profile = new ChefSteps.Models.Profile(options.profile)

  ChefSteps.router = new ChefSteps.Router(currentUser: ChefSteps.profile)
  ChefSteps.router.initializeRoutes()

  ChefSteps.router.parse(window.location.pathname)

