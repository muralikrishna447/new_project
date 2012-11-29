class ChefSteps.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  templateName: 'question'

  render: ->
    @$el.html(@renderTemplate())
    @

  show: =>
    @$el.addClass('visible')

