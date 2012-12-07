ChefStepsAdmin.Views.Modules.FilePickerUpload =
  singlePickerType: 'pick'
  multiplePickerType: 'pickMultiple'

  filepickerOptions:
    mimetype: 'image/*'
    service: 'COMPUTER'

  filePickerType: 'single'

  getFilePickerType: ->
    switch @filePickerType
      when 'single'
        @singlePickerType
      when 'multiple'
        @multiplePickerType
      else
        @singlePickerType

  openFilePicker: ->
    filepicker[@getFilePickerType()](@filepickerOptions, @filePickerOnSuccess)

  filePickerOnSuccess: ->
    throw new Error("NotImplementedError")

