class ChefStepsAdmin.Views.OrderSortImageUploader extends Backbone.View

  el: '#image-uploader'

  filePickerType: 'multiple'

  events:
    'click [data-behavior~=filepicker]': 'openFilePicker'

  filePickerOnSuccess: (fpFiles) =>
    _.each fpFiles, (fpFile) =>
      @collection.create(fpFile)

_.defaults(ChefStepsAdmin.Views.OrderSortImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)
