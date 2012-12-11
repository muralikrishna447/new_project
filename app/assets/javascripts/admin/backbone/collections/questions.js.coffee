class ChefStepsAdmin.Collections.Questions extends Backbone.Collection
  initialize: (models, options) ->
    @quizId = options.quizId

  model: (attrs, options) ->
    switch attrs['question_type']
      when 'multiple_choice'
        new ChefStepsAdmin.Models.MultipleChoiceQuestion(attrs, options)
      else
        new ChefStepsAdmin.Models.Question(attrs, options)

  url: ->
    "/admin/quizzes/#{@quizId}/questions"

  updateOrder: (order) =>
    $.ajax "#{@url()}/update_order",
      type: 'POST',
      dataType: 'json'
      data: { question_order: order }

