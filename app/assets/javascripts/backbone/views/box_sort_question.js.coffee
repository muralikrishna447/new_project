class ChefSteps.Views.BoxSortQuestion extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  events:
    'click .btn-next': 'submitAnswer'

  render: ->
    @$el.html(@renderTemplate())
    @

  showNext: ->
    @_nextButton().fadeIn()

  hideNext: ->
    @_nextButton().fadeOut()

  answerData: ->

  submitAnswer: ->
    answer = new ChefSteps.Models.Answer(question_id: @model.id)
    answer.save(@answerData(), success: @submitSuccess, error: @submitError)

  submitSuccess: =>
    @model.collection.next()

  submitError: ->
    # TODO: what to do here?

  _nextButton: ->
    @$('.btn-next')

