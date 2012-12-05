class ChefStepsAdmin.Views.QuizImage extends ChefSteps.Views.TemplatedView
  className: 'quiz-image'

  formTemplate: 'admin/quiz_image_form'

  events:
    'click .edit': 'triggerEditImageCaption'
    'click .cancel': 'cancelEdit'
    'click .done': 'saveForm'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editImageCaption", @editImageCaptionEventHandler)

  render: (templateName = 'admin/quiz_image') =>
    @templateName = templateName
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

  extendTemplateJSON: (templateJSON) =>
    templateJSON['url'] = @convertImage(@model.get('url'))
    templateJSON

  convertImage: (url) =>
    optionsQueryString = $.param(@imageOptions)
    "#{url}/convert?#{optionsQueryString}"

  imageOptions:
    w: 250,
    h: 250,
    fit: 'crop'

  triggerEditImageCaption: =>
    ChefStepsAdmin.ViewEvents.trigger('editImageCaption', @model.cid)

  editImageCaptionEventHandler: (cid) =>
    if @model.cid == cid
      @render(@formTemplate)
    else if @isEditState()
      @saveForm()
    else
      @render()

  isEditState: =>
    @templateName == @formTemplate

  saveForm: (event) =>
    event.preventDefault() if event
    data = @$('form').serializeObject()
    @model.save(data)
    @render()

  cancelEdit: (event) =>
    event.preventDefault()
    @render()

