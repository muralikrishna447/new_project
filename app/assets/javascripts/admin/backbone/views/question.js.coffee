class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  events:
    'click .edit': 'renderForm'
    'click .delete': 'deleteQuestion'

  editEvents:
    'click .add-option': 'addOption'
    'click .done': 'saveForm'
    'click .cancel': 'cancelEdit'

  addOption: (event) =>
    event.preventDefault()
    @$el.append(@make('b', {}, 'option stuff'))

  deleteQuestion: (event) =>
    event.preventDefault()
    @model.destroy()
    @remove()

  render: =>
    @templateName = 'admin/question'
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

  renderForm: =>
    @templateName = 'admin/question_form'
    @$el.html(@renderTemplate())
    @delegateEvents(@editEvents)
    @

  saveForm: (event) =>
    event.preventDefault()
    @model.save(@$('form').serializeObject())
    @render()

  cancelEdit: (event) =>
    event.preventDefault()
    @render()

