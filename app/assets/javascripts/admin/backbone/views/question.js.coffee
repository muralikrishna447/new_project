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
    'click #question-image': 'openFilePicker'
    'click .edit-image': 'openFilePicker'
    'click .delete-image': 'deleteImage'


  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editQuestion", @editQuestionEventHandler)
    ChefStepsAdmin.ViewEvents.on("questionOrderingMode", @renderOrderingView)
    ChefStepsAdmin.ViewEvents.on("questionNormalMode", @render)
    @model.on("change:id", @updateAttributes)
    @optionViews = []

  initializeOptionViews: =>
    @optionViews = []
    @loadOptionViews()

  addOptionView: (option) =>
    new ChefStepsAdmin.Views.Option(option: option, collection: @)

  imageOptions:
    w: 300
    h: 150
    fit: 'crop'

  extendTemplateJSON: (templateJSON) =>
    if templateJSON['image']?
      templateJSON['image'].url = @convertImage(templateJSON['image'].url)
    templateJSON

  renderOptionViews: =>
    @initializeOptionViews()
    _.each(@optionViews, (optionView) =>
      @renderOptionView(optionView)
    )

  loadOptionViews: =>
    _.each @model.get('options'), (option) => @optionViews.push(@addOptionView(option))

  renderOrderingView: => @render(@orderingTemplate)

  renderOptionView: (optionView) => @$('.options').append(optionView.render().$el)

  addOption: =>
    optionView = @addOptionView(@defaultOption)
    @renderOptionView(optionView)

  deleteQuestion: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroy()
      @remove()

  removeOptionView: (optionView) => @optionViews.remove(_.indexOf(@optionViews, optionView))

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

  updateAttributes: => @$el.attr('id', "question-#{@model.get('id')}")

  isEditState: => @templateName == @formTemplate

  saveForm: =>
    data = @$('form').serializeObject()
    data = _.omit(data, ['answer', 'correct'])
    data['options'] = _.map(@optionViews, (optionView) -> optionView.getFormData())
    @model.save(data)
    @render()

  triggerEditQuestion: =>
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', @model.cid)

  filePickerOnSuccess: (fpFile) =>
    @model.destroyImage() if @model.get('image')
    @model.save(image: fpFile)
    @render(@formTemplate)

  cancelEdit: => @render()

  deleteImage: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroyImage()
      @model.set('image', {})
      @render(@formTemplate)

_.defaults(ChefStepsAdmin.Views.Question.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload, ChefStepsAdmin.Views.Modules.FilePickerDisplay)

