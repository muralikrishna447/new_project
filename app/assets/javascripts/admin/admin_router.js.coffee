class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/{id}/manage_questions' : 'editQuizQuestions'

  editQuizQuestions: (id)->
    questions = new ChefStepsAdmin.Collections.Questions([], quizId: id)
    questions.reset(ChefStepsAdmin.questionsData)

    new ChefStepsAdmin.Views.QuizControls(collection: questions)
    view = new ChefStepsAdmin.Views.Questions(collection: questions)

    view.render()
