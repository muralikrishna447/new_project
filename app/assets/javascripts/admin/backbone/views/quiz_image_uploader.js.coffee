class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View

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

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

