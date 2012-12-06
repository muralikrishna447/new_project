class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View

  el: '#image-uploader'

  render: =>
    if @collection.length == 0
      @openMultipleFilePicker()
    @

  events:
    'click [data-behavior~=filepicker]': 'openMultipleFilePicker'

  multipleFilePickerOnSuccess: (fpFiles) =>
    _.each fpFiles, (fpFile) =>
      @collection.create(fpFile)

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

