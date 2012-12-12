class ChefSteps.Views.MultipleChoiceQuestion extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  events:
    'change input': 'answerChanged'
    'click .btn-next': 'submitAnswer'

  render: ->
    @$el.html(@renderTemplate())
    @

  answerChanged: ->
    if @answerSelected()
      @showNext()
    else
      @hideNext()

  showNext: ->
    @_nextButton().fadeIn()

  hideNext: ->
    @_nextButton().fadeOut()

  selectedOption: ->
    @$('input:checked')

  answerSelected: ->
    @selectedOption().length > 0

  answerData: ->
    option = @selectedOption()
    {
      type: 'multiple_choice',
      uid: option[0].id,
      answer: option.val()
    }

  submitAnswer: ->
    answer = new ChefSteps.Models.Answer(question_id: @model.id)
    answer.save(@answerData(), success: @submitSuccess, error: @submitError)

  submitSuccess: =>
    @model.collection.next()

  submitError: ->
    # TODO: what to do here?

  _nextButton: ->
    @$('.btn-next')
