class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"
    "/quizzes/{id}": "showQuizOverview"
    "/styleguide": "showStyleguide"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile
        model: @currentUser,
        el: '.user-profile',
        registrationCompletionPath: @registrationCompletionPath,
        newUser: query && query.new_user

  showQuizOverview: (id) =>
    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input)

  showStyleguide: =>
    new ChefSteps.Views.ProgressDial(el: '[data-behavior~=progress-dial]')
