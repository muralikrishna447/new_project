class ChefStepsAdmin.Views.Questions extends Backbone.View
  initialize: ->
    @collection.on('add', @addNewQuestionToList, @)
    @collection.on('add remove', @updateQuestionCount, @)
    $('#question-filters .ordering').on('click', @toggleOrdering)

  el: '#question-list'

  render: =>
    @collection.each (question) =>
      @addQuestionToList(question)
    @makeSortable()
    @updateQuestionCount()
    @

  updateQuestionCount: =>
    $('#question-count span').text(@collection.length)

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

  toggleOrdering: (event) =>
    event.preventDefault()
    $target = $(event.currentTarget)
    $target.toggleClass($target.data('toggle'))

    if $target.hasClass($target.data('toggle'))
      ChefStepsAdmin.ViewEvents.trigger('questionOrderingMode')
    else
      ChefStepsAdmin.ViewEvents.trigger('questionNormalMode')

