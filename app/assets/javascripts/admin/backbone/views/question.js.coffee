class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  events:
    'click .edit': 'triggerEditQuestion'
    'click .delete': 'deleteQuestion'


  editEvents:
    'click .add-option': 'addOption'
    'click .done': 'saveForm'
    'click .cancel': 'cancelEdit'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editQuestion", @editQuestionEventHandler)

  addOption: (event) =>
    event.preventDefault()
    @$el.append(@make('b', {}, 'option stuff'))

  deleteQuestion: (event) =>
    event.preventDefault()
    @model.destroy()
    @remove()

  editQuestionEventHandler: (cid) =>
    if @model.cid == cid
      @renderForm()
    else if @isEditState()
      @saveForm()
    else
      @render()

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

  isEditState: =>
    @templateName == 'admin/question_form'

  saveForm: (event) =>
    event.preventDefault() if event
    @model.save(@$('form').serializeObject())
    @render()

  cancelEdit: (event) =>
    event.preventDefault()
    @render()

  triggerEditQuestion: =>
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', @model.cid)

