class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"
    "/quizzes/{id}": "startQuizApp"
    "/styleguide": "showStyleguide"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile
        model: @currentUser,
        el: '.user-profile',
        registrationCompletionPath: @registrationCompletionPath,
        newUser: query && query.new_user

  startQuizApp: (id) =>
    new ChefSteps.Views.NavHider
      el: $('[data-behavior~=nav-hideable]')
      showElement: '.quiz-title'

    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input)

  showStyleguide: =>
    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input, noAdjustSize: true)
