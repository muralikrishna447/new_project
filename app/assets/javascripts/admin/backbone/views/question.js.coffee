class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  templateName: 'admin/question'

  events:
    'click .add-option': 'addOption'
    'submit .add-option': 'addOption'

  addOption: (event)=>
    @$el.append(@make("b", {}, "Stuff"))

  render: =>
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

