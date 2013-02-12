class ChefSteps.Router extends ChefSteps.BaseRouter
  initialize: (options) =>
    @currentUser = options.currentUser
    @registrationCompletionPath = options.registrationCompletionPath

  loadHeader: =>
    headerView = ChefSteps.new(ChefSteps.Views.ProfileHeader, model: @currentUser)
    headerView.render()

  routes:
    "/profiles/{id}:?query:": "showProfile"
    "/quizzes/{id}:?query:": "startQuizApp"
    "/styleguide": "showStyleguide"
    "/quizzes/{id}/results:?query:": "showQuizResults"

  showProfile: (id, query) =>
    return unless @currentUser
    if id == @currentUser.id.toString()
      profileView = new ChefSteps.Views.Profile
        model: @currentUser,
        el: '.user-profile',
        registrationCompletionPath: @registrationCompletionPath,
        newUser: query && query.new_user

  startQuizApp: (id, query) =>
    navHider = new ChefSteps.Views.NavHider
      el: $('[data-behavior~=nav-hideable]')
      showElement: '.quiz-title'

    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input)

    questions = new ChefSteps.Collections.Questions([], quizId: id)
    questions.reset(ChefSteps.questionsData)

    path = "/quizzes/#{id}/results"
    path += "?token=#{query.token}" if query && query.token

    new ChefSteps.Views.Quiz
      el: '#quiz-container'
      collection: questions
      navHider: navHider
      quizCompletionPath: path
      quizId: id

  showQuizResults: (id, query) ->
    # Use the shapeshift library to make the results look the same as the UI.
    $('.grid-container').shapeshift({
      centerGrid: false,
      enableAnimationOnInit: false,
      columns: 4,
      dragWhitelist: '.draggable'
    })

  showStyleguide: =>
    _.each $('[data-behavior~=progress-dial]'), (input)->
      new ChefSteps.Views.ProgressDial(el: input, noAdjustSize: true)

