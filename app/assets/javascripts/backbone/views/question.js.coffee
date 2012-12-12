class ChefSteps.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  events:
    'click .btn-next': 'submitAnswer'

  viewEvents: {}

  render: ->
    @$el.html(@renderTemplate())
    @delegateEvents(_.extend(@viewEvents, @events))
    @

  showNext: ->
    @_nextButton().fadeIn()

  hideNext: ->
    @_nextButton().fadeOut()

  answerData: ->
    throw new Error('NotImplementedError')

  submitAnswer: ->
    answer = new ChefSteps.Models.Answer(question_id: @model.id)
    answer.save(@answerData(), success: @submitSuccess, error: @submitError)

  submitSuccess: =>
    @model.collection.next()

  submitError: ->
    # TODO: what to do here?

  _nextButton: ->
    @$('.btn-next')


