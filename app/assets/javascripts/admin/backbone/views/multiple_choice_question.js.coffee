class ChefStepsAdmin.Views.MultipleChoiceQuestion extends ChefStepsAdmin.Views.Question

  showTemplate: 'admin/multiple_choice_question'
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
    'click #question-image': 'openFilePicker'
    'click .edit-image': 'openFilePicker'
    'click .delete-image': 'deleteImage'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editQuestion", @editQuestionEventHandler)
    @optionViews = {}
    super(options)

  renderOptionViews: =>
    @initializeOptionViews()
    _.each(@optionViews, (optionView) =>
      @renderOptionView(optionView)
    )

  render: (templateName = @showTemplate) =>
    super(templateName)
    if @isEditState()
      @renderOptionViews()
      @makeOptionsSortable()
    @

  filePickerOnSuccess: (fpFile) =>
    @model.destroyImage() if @model.get('image')
    @model.save(image: fpFile)
    @model.snapshot()
    @model.set(@formData())
    @render(@formTemplate)

  makeOptionsSortable: =>
    @$('.options').sortable(
      cursor: 'move',
      containment: 'parent'
    ).disableSelection()

  initializeOptionViews: =>
    @optionViews = {}
    @loadOptionViews()

  renderOptionView: (optionView) => @$('.options').append(optionView.render().$el)

  addOption: =>
    optionView = @addOptionView(@defaultOption)
    @optionViews[optionView.uid] = optionView
    @renderOptionView(optionView)

  addOptionView: (option) => new ChefStepsAdmin.Views.Option(option: option, questionView: @)

  removeOptionView: (optionView) =>
    delete @optionViews[optionView.uid]

  imageOptions:
    w: 580
    h: 330
    fit: 'crop'

  extendTemplateJSON: (templateJSON) =>
    if templateJSON['image']?
      templateJSON['image'].url = @convertImage(templateJSON['image'].url)
    templateJSON

  loadOptionViews: =>
    _.each @model.get('options'), (option) =>
      optionView = @addOptionView(option)
      @optionViews[optionView.uid] = optionView

  editQuestionEventHandler: (cid) =>
    if @model.cid == cid
      @render(@formTemplate)
    else if @isEditState()
      @saveForm()
    else
      @render()

  triggerEditQuestion: =>
    ChefStepsAdmin.ViewEvents.trigger('editQuestion', @model.cid)

  formData: =>
    data = @$('form').serializeObject()
    data = _.omit(data, ['answer', 'correct'])
    data['options'] = _.map @$('.options .option'), (optionEl) =>
      @optionViews[$(optionEl).data('uid')].getFormData()
    data

  saveForm: =>
    @model.save(@formData())
    @render()

  cancelEdit: =>
    @model.revert()
    @render()

  isEditState: => @templateName == @formTemplate

  deleteImage: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroyImage()
      @model.set('image', {})
      @render(@formTemplate)


_.defaults(ChefStepsAdmin.Views.Question.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload, ChefStepsAdmin.Views.Modules.FilePickerDisplay)
