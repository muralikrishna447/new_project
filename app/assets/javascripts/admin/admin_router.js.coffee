class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/{id}/questions' : 'editQuizQuestions'

  editQuizQuestions: ->
    questions = new ChefStepsAdmin.Collections.Questions([])
    questions.reset(ChefStepsAdmin.questionsData)

    new ChefStepsAdmin.Views.QuizControls(collection: questions)
    view = new ChefStepsAdmin.Views.Questions(collection: questions)

    view.render()
