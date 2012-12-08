class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View
  filePickerType: 'single'

  events:
    'click button': 'openFilePicker'

  render: ()->
    if @model.get('filename')
      @$("[name='quiz[image_attributes][filename]']").val(@model.get('filename'))
      @$("[name='quiz[image_attributes][url]']").val(@model.get('url'))
      view = new ChefStepsAdmin.Views.QuizImage(model: @model, noCaption: true)
      @$('.image').html(view.render().$el)

  filePickerOnSuccess: (fpFile) =>
    @model.set(fpFile)
    @render()

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

