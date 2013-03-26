class ChefStepsAdmin.Router extends ChefSteps.BaseRouter

  routes:
    '/admin/quizzes/new' : 'editQuiz'
    '/admin/quizzes/{id}/edit' : 'editQuiz'
    '/admin/quizzes/{id}/manage_questions' : 'editQuizQuestions'
    '/admin/questions/{id}/edit' : 'editQuestion'
    '/admin/order_sort_questions/{id}/edit' : 'editOrderSortQuestion'

  editQuiz: (id) ->
    model = new ChefStepsAdmin.Models.QuizImage(ChefStepsAdmin.quizImageData)
    view = new ChefStepsAdmin.Views.QuizImageUploader(el: "form", model: model)
    view.render()

  editQuizQuestions: (id) ->
    questions = new ChefStepsAdmin.Collections.Questions([], quizId: id)
    questions.reset(ChefStepsAdmin.questionsData)

    new ChefStepsAdmin.Views.QuizControls(collection: questions)
    view = new ChefStepsAdmin.Views.Questions(collection: questions)

    view.render()

  editQuestion: (questionId) ->
    boxSortImages = new ChefStepsAdmin.Collections.BoxSortImages([])
    boxSortImages.reset(ChefStepsAdmin.questionImageData)

    new ChefStepsAdmin.Views.BoxSortImageUploader(collection: boxSortImages)
    boxSortImagesView = new ChefStepsAdmin.Views.BoxSortImages(collection: boxSortImages)

    boxSortImagesView.render()

  editOrderSortQuestion: (questionId) ->
    orderSortImages = new ChefStepsAdmin.Collections.OrderSortImages([])
    orderSortImages.reset(ChefStepsAdmin.questionImageData)

    new ChefStepsAdmin.Views.OrderSortImageUploader(collection: orderSortImages)

    orderSortImagesView = new ChefStepsAdmin.Views.OrderSortImages(collection: orderSortImages)
    orderSortImagesView.render()

    orderSortSolutionsView = new ChefStepsAdmin.Views.OrderSortSolutions(
      solutions: ChefStepsAdmin.solutionData,
      imageCollection: orderSortImages
    )
    orderSortSolutionsView.render()
