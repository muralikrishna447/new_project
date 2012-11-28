class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  formTemplate: 'admin/question_form'

  events:
    'click .edit': 'triggerEditQuestion'
    'click .delete': 'deleteQuestion'
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
      @render(@formTemplate)
    else if @isEditState()
      @saveForm()
    else
      @render()

  render: (templateName = 'admin/question') =>
    @templateName = templateName
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

  isEditState: =>
    @templateName == @formTemplate

  saveForm: (event) =>
    event.preventDefault() if event
    @model.save(@$('form').serializeObject())
    @render()

  cancelEdit: (event) =>
    event.preventDefault()
    @render()

  triggerEditQuestion: =>
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', @model.cid)

