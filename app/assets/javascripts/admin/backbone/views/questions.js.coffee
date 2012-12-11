class ChefStepsAdmin.Views.Questions extends Backbone.View
  initialize: ->
    @collection.on('add', @addNewQuestionToList, @)
    @collection.on('add remove', @updateQuestionCount, @)
    $('#question-filters .ordering').on('click', @toggleOrdering)

  el: '#question-list'

  render: =>
    @collection.each (question) =>
      @addQuestionToList(question, false)
    @makeSortable()
    @updateQuestionCount()
    @

  updateQuestionCount: =>
    $('#question-count .count').text(@collection.length)

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

  getQuestionView: (question) =>
    if question instanceof ChefStepsAdmin.Models.MultipleChoiceQuestion
      new ChefStepsAdmin.Views.MultipleChoiceQuestion(model: question)
    else
      new ChefStepsAdmin.Views.Question(model: question)

  addQuestionToList: (question, scrollIntoView=true) =>
    view = @getQuestionView(question)
    @$el.append(view.render().$el)
    if scrollIntoView
      @scrollElementIntoView(view.$el)

  scrollElementIntoView: ($el) ->
    offset = $el.offset()
    $('html body').animate(
      scrollTop: offset.top,
      scrollLeft: offset.left
    )

  addNewQuestionToList: (question) =>
    console.log 'adding question', question
    @addQuestionToList(question)
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', question.cid)

  toggleOrdering: (event) =>
    event.preventDefault()
    $target = $(event.currentTarget)
    targetToggleClass =$target.data('toggle')
    toggleText = $target.data('toggle-text')

    oldText = $target.text()
    $target.text(toggleText)
    $target.data('toggle-text', oldText)
    $target.toggleClass(targetToggleClass)

    if $target.hasClass(targetToggleClass)
      ChefStepsAdmin.ViewEvents.trigger('questionOrderingMode')
    else
      ChefStepsAdmin.ViewEvents.trigger('questionNormalMode')

