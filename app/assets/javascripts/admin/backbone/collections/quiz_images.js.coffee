class ChefStepsAdmin.Collections.QuizImages extends Backbone.Collection
  initialize: (models, options) ->
    @quizId = options.quizId

  model: ChefStepsAdmin.Models.QuizImage

  url: ->
    "/admin/quizzes/#{@quizId}/images"
