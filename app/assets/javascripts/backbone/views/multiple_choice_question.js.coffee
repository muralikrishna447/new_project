class ChefSteps.Views.MultipleChoiceQuestion extends ChefSteps.Views.Question
  templateName: 'question'

  viewEvents:
    'change input': 'answerChanged'

  answerChanged: ->
    if @answerSelected()
      @showNext()
    else
      @hideNext()

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
