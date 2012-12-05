class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View

  el: '#image-uploader'

  render: =>
    if @collection.length == 0
      @openFilePicker()
    @

  events:
    'click [data-behavior~=filepicker]': 'openFilePicker'

  filepickerOptions:
    mimetype: 'image/*'
    service: 'COMPUTER'

  openFilePicker: ->
    filepicker.pickMultiple(@filepickerOptions, @filePickerOnSuccess)

  filePickerOnSuccess: (fpFiles) =>
    _.each fpFiles, (fpFile) =>
      @collection.create(fpFile)

