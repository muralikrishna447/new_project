class ChefStepsAdmin.Views.BoxSortImage extends ChefSteps.Views.TemplatedView
  className: 'image'

  formTemplate: 'admin/box_sort_image_form'
  showTemplate: 'admin/box_sort_image'

  events:
    'click .edit': 'triggerEditImageCaption'
    'submit form': 'saveForm'
    'click .save': 'saveForm'
    'keyup input': 'keyPressEventHandler'
    'keydown textarea': 'keyPressEventHandler'
    'blur input, textarea': 'saveForm'
    'click .delete-image': 'deleteImage'
    'click [data-behavior~=toggle-key-image]': 'toggleKeyImage'
    'click [data-behavior~=edit-explanation]': 'editKeyImageExplanation'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("editImageCaption", @editImageCaptionEventHandler)
    @model.on("change:id", @updateAttributes)

  render: (templateName = @showTemplate) =>
    @templateName = templateName
    @$el.html(@renderTemplate())
    @delegateEvents()
    @updateAttributes()
    @

  extendTemplateJSON: (templateJSON) =>
    templateJSON['url'] = @convertImage(@model.get('url'))
    templateJSON

  imageOptions:
    w: 300
    h: 150
    fit: 'crop'

  toggleKeyImage: =>
    currentValue = @model.get('key_image')
    @model.save('key_image', not currentValue)
    @render()

  triggerEditImageCaption: => ChefStepsAdmin.ViewEvents.trigger('editImageCaption', @model.cid)

  editImageCaptionEventHandler: (cid) =>
    if @model.cid == cid
      @render(@formTemplate)
      @$('input').focus()
    else if @isEditState()
      @saveForm()
    else
      @render()

  editKeyImageExplanation: =>
    $target = @$('[data-behavior~=edit-explanation]')
    $target.popover(
      title: 'Key Image Explanation'
      html: true
      content: Handlebars.templates['templates/admin/box_sort_image_explanation_form'](@model.toJSON())
      placement: 'top'
    )
    @delegateEvents()
    $target.popover('show')
    @$('textarea').focus()

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
      when 13 #enter key
        @saveForm()

  deleteImage: (event) =>
    event.preventDefault()
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroyImage()
      @remove()

  updateAttributes: => @$el.attr('id', "box-sort-image-#{@model.get('id')}")

_.defaults(ChefStepsAdmin.Views.BoxSortImage.prototype, ChefStepsAdmin.Views.Modules.FilePickerDisplay)

