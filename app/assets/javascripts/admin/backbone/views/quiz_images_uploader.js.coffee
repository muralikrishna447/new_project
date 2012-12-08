class ChefStepsAdmin.Views.QuizImagesUploader extends Backbone.View

  el: '#image-uploader'

  render: =>
    if @collection.length == 0
      @openFilePicker()
    @

  filePickerType: 'multiple'

  events:
    'click [data-behavior~=filepicker]': 'openFilePicker'

  filePickerOnSuccess: (fpFiles) =>
    _.each fpFiles, (fpFile) =>
      @collection.create(fpFile)

_.defaults(ChefStepsAdmin.Views.QuizImagesUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)


