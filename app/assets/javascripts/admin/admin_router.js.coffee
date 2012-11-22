class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/new' : 'createQuiz'

  createQuiz: ->
    quiz = new ChefStepsAdmin.Models.Quiz()
    quizView = new ChefStepsAdmin.Views.Quiz(quiz)
    quizView.render()

