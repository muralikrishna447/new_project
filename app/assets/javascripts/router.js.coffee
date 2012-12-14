class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"
    "/quizzes/{id}/:token:": "startQuizApp"
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
    navHider = new ChefSteps.Views.NavHider
      el: $('[data-behavior~=nav-hideable]')
      showElement: '.quiz-title'

    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input)

    questions = new ChefSteps.Collections.Questions([], quizId: id)
    questions.reset(ChefSteps.questionsData)

    new ChefSteps.Views.Quiz
      el: '#quiz-container'
      collection: questions
      navHider: navHider
      quizCompletionPath: "/quizzes/#{id}/results"
      quizId: id

  showStyleguide: =>
    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input, noAdjustSize: true)

