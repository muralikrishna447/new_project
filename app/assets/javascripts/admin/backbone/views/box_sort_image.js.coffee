class ChefStepsAdmin.Views.BoxSortImage extends ChefSteps.Views.TemplatedView
  className: 'image'

  formTemplate: 'admin/box_sort_image_form'
  showTemplate: 'admin/box_sort_image'

  events:
    'click .edit': 'triggerEditImageCaption'
    'submit form': 'saveForm'
    'click .save': 'saveForm'
    'keyup input': 'keyPressEventHandler'
    'blur input': 'cancelEdit'
    'click .delete-image': 'deleteImage'

  initialize: (options) =>
    @noCaption = options.noCaption
    ChefStepsAdmin.ViewEvents.on("editImageCaption", @editImageCaptionEventHandler)

  render: (templateName = @showTemplate) =>
    @templateName = templateName
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

  extendTemplateJSON: (templateJSON) =>
    templateJSON['url'] = @convertImage(@model.get('url'))
    templateJSON['noCaption'] = @noCaption
    templateJSON

  imageOptions:
    w: 300
    h: 150
    fit: 'crop'

  triggerEditImageCaption: =>
    ChefStepsAdmin.ViewEvents.trigger('editImageCaption', @model.cid)

  editImageCaptionEventHandler: (cid) =>
    if @model.cid == cid
      @render(@formTemplate)
      @$('input').focus()
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

  cancelEdit: =>
    @render()

  keyPressEventHandler: (event) =>
    switch event.keyCode
      when 27 # esc key
        @cancelEdit()

  deleteImage: (event) =>
    event.preventDefault()
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroyImage()
      @remove()

_.defaults(ChefStepsAdmin.Views.BoxSortImage.prototype, ChefStepsAdmin.Views.Modules.FilePickerDisplay)

