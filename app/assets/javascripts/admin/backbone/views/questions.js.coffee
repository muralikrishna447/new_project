class ChefStepsAdmin.Views.Questions extends Backbone.View
  initialize: ->
    @collection.on('add', @addNewQuestionToList, @)
    @collection.on('reset', @render, @)

  el: '#question-list'

  render: =>
    @collection.each (question) =>
      @addQuestionToList(question)
    @makeSortable()
    @

  makeSortable: =>
    @$el.sortable(
      cursor: 'move',
      containment: 'parent',
      update: @updateOrder
    ).disableSelection()

  updateOrder: =>
    @collection.updateOrder(@getQuestionOrder())

  getQuestionOrder: =>
    _.map(@$('.question'), (questionItem) ->
      $(questionItem).attr('id').split('-')[1]
    )

  addQuestionToList: (question) =>
    view = new ChefStepsAdmin.Views.Question(model: question)
    @$el.append(view.render().$el)

  addNewQuestionToList: (question) =>
    @addQuestionToList(question)
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', question.cid)


