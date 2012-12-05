class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View

  initialize: (options) =>

  el: '#image-uploader'

  events:
    'click [data-behavior~=filepicker]': 'openFilePicker'

  filepickerOptions:
    mimetype: 'image/*'
    service: 'COMPUTER'

  openFilePicker: ->
    filepicker.pickMultiple(@filepickerOptions, @filePickerOnSuccess)

  filePickerOnSuccess: (fpFiles) =>
    _.each fpFiles, (fpFile) =>
      @collection.create(fp)

