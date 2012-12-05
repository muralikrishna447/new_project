class ChefSteps.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  events:
    'change input': 'answerChanged'
    'click .btn-next': 'submitAnswer'

  render: ->
    @$el.html(@renderTemplate())
    @

  show: =>
    @delegateEvents()
    @createCheckboxes()
    @$el.addClass('visible')

  createCheckboxes: ->
    _.each @$('[data-behavior~=checkbox], [data-behavior~=radio]'), (input)->
      new ChefSteps.Views.Checkbox(el: input)

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
      id: option[0].id,
      answer: option.val()
    }

  submitAnswer: ->
    answer = new ChefSteps.Models.Answer(question_id: @model.id)
    answer.save(@answerData(), success: @submitSuccess, error: @submitError)

  submitSuccess: ->
    console.log("ANSWER SUBMITTED")
    # TODO: load next question

  submitError: ->
    # TODO: what to do here?

  _nextButton: ->
    @$('.btn-next')
