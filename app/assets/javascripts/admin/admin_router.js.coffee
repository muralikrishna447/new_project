class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/new' : 'createQuiz'

  createQuiz: ->
    quiz = ChefSteps.new(ChefStepsAdmin.Models.Quiz)
    quizView = ChefSteps.new(ChefStepsAdmin.Views.Quiz, quiz)
    quizView.render()

