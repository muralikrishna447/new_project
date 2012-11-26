class ChefStepsAdmin.Views.Questions extends Backbone.View
  initialize: ->
    @collection.on('add', @addQuestionToList, @)

  el: '#question-list'

  render: ->
    @collection.each (question) =>
      @addQuestionToList(question)
    @

  addQuestionToList: (question) ->
    view = new ChefStepsAdmin.Views.Question(model: question, id: "question-#{question.id}")
    @$el.append(view.render().$el)

