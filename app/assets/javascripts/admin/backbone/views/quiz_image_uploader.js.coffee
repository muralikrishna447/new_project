class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View
  filePickerType: 'single'

  events:
    'click button': 'openFilePicker'

  render: ()->
    unless @model.isNew()
      view = new ChefStepsAdmin.Views.QuizImage(model: @model)
      @$el.html(view.render().$el)

  filePickerOnSuccess: (fpFile) =>
    @model.set(fpFile)
    @model.save {}, success: =>
      @render()

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

