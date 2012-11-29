class ChefStepsAdmin.Collections.Questions extends Backbone.Collection
  initialize: (models, options) ->
    @quizId = options.quizId

  model: ChefStepsAdmin.Models.Question

  url: ->
    "/admin/quizzes/#{@quizId}/questions"

  comparator: (question) =>
    question.get('question_order')

