class ChefStepsAdmin.Views.QuizImageUploader extends Backbone.View
  filePickerType: 'single'

  events:
    'click button': 'openFilePicker'

  initialize: (options)->
    @model.destroySuccess = =>
      @updateImageAttributes(true)

  render: ()->
    if @model.get('filename')
      @updateImageAttributes()
      view = new ChefStepsAdmin.Views.QuizImage(model: @model, noCaption: true)
      @$('.image').html(view.render().$el)

  filePickerOnSuccess: (fpFile) =>
    @model.set(fpFile)
    @render()

  updateImageAttributes: (destroy=false)=>
    @$("[name='quiz[image_attributes][filename]']").val(@model.id)
    @$("[name='quiz[image_attributes][filename]']").val(@model.get('filename'))
    @$("[name='quiz[image_attributes][url]']").val(@model.get('url'))
    @$("[name='quiz[image_attributes][_destroy]']").val(destroy)

_.defaults(ChefStepsAdmin.Views.QuizImageUploader.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload)

