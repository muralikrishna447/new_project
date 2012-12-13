class ChefStepsAdmin.Views.QuizImage extends ChefSteps.Views.TemplatedView
  className: 'image quiz-image'

  templateName: 'admin/quiz_image'

  events:
    'click .delete-image': 'deleteImage'

  render: =>
    @$el.html(@renderTemplate())
    @delegateEvents()
    @

  extendTemplateJSON: (templateJSON) =>
    templateJSON['url'] = @convertImage(@model.get('url'))
    templateJSON

  imageOptions:
    w: 300
    h: 150
    fit: 'crop'

  deleteImage: (event) =>
    event.preventDefault()
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroyImage()
      @remove()

_.defaults(ChefStepsAdmin.Views.QuizImage.prototype, ChefStepsAdmin.Views.Modules.FilePickerDisplay)

