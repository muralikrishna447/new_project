class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/{id}/edit' : 'editQuiz'
    '/admin/quizzes/{id}/manage_questions' : 'editQuizQuestions'
    '/admin/quizzes/{id}/upload_images' : 'uploadQuizImages'

  editQuiz: (id)->
    model = new ChefStepsAdmin.Models.QuizImage(ChefStepsAdmin.quizImageData)
    model.urlRoot = "/admin/quizzes/#{id}/image"
    view = new ChefStepsAdmin.Views.QuizImageUploader(el: "#quiz-image", model: model)
    view.render()

  editQuizQuestions: (id)->
    questions = new ChefStepsAdmin.Collections.Questions([], quizId: id)
    questions.reset(ChefStepsAdmin.questionsData)

    new ChefStepsAdmin.Views.QuizControls(collection: questions)
    view = new ChefStepsAdmin.Views.Questions(collection: questions)

    view.render()

  uploadQuizImages: (id) ->
    quizImages = new ChefStepsAdmin.Collections.QuizImages([], quizId: id)
    quizImages.reset(ChefStepsAdmin.quizImageData)
    imageUploaderView = new ChefStepsAdmin.Views.QuizImagesUploader(collection: quizImages)
    imageUploaderView.render()

    quizImagesView = new ChefStepsAdmin.Views.QuizImages(collection: quizImages)
    quizImagesView.render()

