window.ChefSteps ||= {}

ChefSteps.Collections ||= {}
ChefSteps.Models ||= {}
ChefSteps.Views ||= {}

Handlebars.templates ||= {}

ChefSteps.init = (options)->
  _.each $('.user-form'), (form)->
    new ChefSteps.Views.AuthForm(el: form)

  if options.profile
    ChefSteps.profile = new ChefSteps.Models.Profile(options.profile)

  ChefSteps.router = new ChefSteps.Router
    currentUser: ChefSteps.profile
    registrationCompletionPath: options.registrationCompletionPath
    quizCompletionPath: options.quizCompletionPath

  ChefSteps.router.loadHeader()
  ChefSteps.router.initializeRoutes()

  ChefSteps.router.parse(window.location.pathname + window.location.search)
