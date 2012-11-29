class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  formTemplate: 'admin/question_form'

  defaultOption:
    answer: ''
    correct: false

  events:
    'click .edit': 'triggerEditQuestion'
    'click .delete': 'deleteQuestion'
    'click .add-option': 'addOption'
    'click .done': 'saveForm'
    'click .cancel': 'cancelEdit'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editQuestion", @editQuestionEventHandler)

  addOptionView: (option) =>
    new ChefStepsAdmin.Views.Option(option: option)

  renderOptionViews: =>
    _.each(@model.get('options'), (option) =>
      @renderOptionView(@addOptionView(option))
    )

  renderOptionView: (optionView) =>
    @$('.options').append(optionView.render().$el)

  addOption: (event) =>
    event.preventDefault()
    optionView = @addOptionView(@defaultOption)
    @renderOptionView(optionView)

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
    if @isEditState()
      @renderOptionViews()
    @

  isEditState: =>
    @templateName == @formTemplate

  saveForm: (event) =>
    event.preventDefault() if event
    data = @$('form').serializeObject()
    data = _.omit(data, ['answer', 'correct'])
    data['options'] = _.map(@$('.edit-option'), (option) -> $('input', option).serializeObject())
    @model.save(data)
    @render()

  cancelEdit: (event) =>
    event.preventDefault()
    @render()

  triggerEditQuestion: =>
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', @model.cid)

