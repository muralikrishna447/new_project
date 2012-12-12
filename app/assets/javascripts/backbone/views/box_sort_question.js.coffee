class ChefSteps.Views.BoxSortQuestion extends ChefSteps.Views.Question
  templateName: 'box_sort_question'

  render: ->
    super
    new ChefSteps.Views.BoxSortImageSet(el: @$el)
    @

  answerData: ->
