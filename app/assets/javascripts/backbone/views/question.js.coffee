class ChefSteps.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  render: ->
    @$el.html(@renderTemplate())
    @

  show: =>
    @createCheckboxes()
    @$el.addClass('visible')

  createCheckboxes: ->
    _.each @$('[data-behavior~=checkbox], [data-behavior~=radio]'), (input)->
      new ChefSteps.Views.Checkbox(el: input)
