class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  formTemplate: 'admin/question_form'
  orderingTemplate: 'admin/question_ordering'

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
    ChefStepsAdmin.ViewEvents.on("questionOrderingMode", @renderOrderingView)
    ChefStepsAdmin.ViewEvents.on("questionNormalMode", @render)
    @model.on("change:id", @updateAttributes)

  addOptionView: (option) =>
    new ChefStepsAdmin.Views.Option(option: option)

  renderOptionViews: =>
    _.each(@model.get('options'), (option) =>
      @renderOptionView(@addOptionView(option))
    )

  renderOrderingView: =>
    @render(@orderingTemplate)

  renderOptionView: (optionView) =>
    @$('.options').append(optionView.render().$el)

  addOption: (event) =>
    event.preventDefault()
    optionView = @addOptionView(@defaultOption)
    @renderOptionView(optionView)

  deleteQuestion: (event) =>
    event.preventDefault()
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
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
      @makeOptionsSortable()
    @updateAttributes()
    @

  makeOptionsSortable: =>
    @$('.options').sortable(
      cursor: 'move',
      containment: 'parent'
    ).disableSelection()

  updateAttributes: =>
    @$el.attr('id', "question-#{@model.get('id')}")

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

