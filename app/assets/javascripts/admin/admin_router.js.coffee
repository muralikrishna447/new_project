class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/{id}/manage_questions' : 'editQuizQuestions'
    '/admin/quizzes/{id}/upload_images' : 'uploadQuizImages'


  editQuizQuestions: (id)->
    questions = new ChefStepsAdmin.Collections.Questions([], quizId: id)
    questions.reset(ChefStepsAdmin.questionsData)

    new ChefStepsAdmin.Views.QuizControls(collection: questions)
    view = new ChefStepsAdmin.Views.Questions(collection: questions)

    view.render()

  uploadQuizImages: (id) ->
    quizImages = new ChefStepsAdmin.Collections.QuizImages([], quizId: id)
    quizImages.reset(ChefStepsAdmin.quizImageData)
    new ChefStepsAdmin.Views.QuizImageUploader(collection: quizImages)
    view = new ChefStepsAdmin.Views.QuizImages(collection: quizImages)
    view.render()

