ChefStepsAdmin.Views.Modules.FilePickerUpload =
  filepickerOptions:
    mimetype: 'image/*'
    service: 'COMPUTER'

  openMultipleFilePicker: ->
    filepicker.pickMultiple(@filepickerOptions, @multipleFilePickerOnSuccess)

  openFilePicker: ->
    filepicker.pick(@filepickerOptions, @singleFilePickerOnSuccess)

  multipleFilePickerOnSuccess: ->
    throw new Error("NotImplementedError")

  singleFilePickerOnSuccess: ->
    throw new Error("NotImplementedError")

