class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View
  filePickerType: 'single'

  events:
    'click': 'openFilePicker'

  filePickerOnSuccess: (fpFiles) =>
    console.log(fpFiles)

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

