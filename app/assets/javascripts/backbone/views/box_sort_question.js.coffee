class ChefSteps.Views.BoxSortQuestion extends ChefSteps.Views.Question
  templateName: 'box_sort_question'

  initialize: (options)->
    @collection = new ChefSteps.Collections.BoxSortAnswers()

  render: ->
    super
    new ChefSteps.Views.BoxSortImageSet
      el: @$el
      collection: @collection
      onComplete: =>
        @showNext()
    @

  answerData: ->
    {
      type: 'box_sort',
    }
