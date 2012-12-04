class ChefSteps.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  events:
    'change input': 'answerChanged'

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

  answerSelected: ->
    @$('input:checked').length > 0

  _nextButton: ->
    @$('.btn-next')
