class ChefStepsAdmin.Views.Option extends Backbone.View
  className: 'edit-option'

  tagName: "li"

  events:
    'click .delete-option': 'deleteOption'
    'change input[type=radio]': 'highlightCorrect'
    'click .delete-option-image': 'deleteImage'
    'click .edit-option-image': 'openFilePicker'
    'click .option-image-controls img': 'openFilePicker'
    'click .option-image-controls .upload-image': 'openFilePicker'

  filePickerType: 'single'

  initialize: (options) =>
    @option = options.option
    @uid = @option.uid || @cid
    @questionView = options.questionView

  destroySuccess: =>
    @option['image'] = {}
    @render()

  getImage: =>
    @option['image']

  filePickerOnSuccess: (fpFile) =>
    @destroyImage(true)
    @option['image'] = fpFile
    @option = @getFormData()
    @render()

  deleteImage: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @destroyImage()

  deleteOption: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @destroyImage(true)
      @questionView.removeOptionView(@)
      @remove()

  getFormData: =>
    _.defaults(@$('input').serializeObject(), @option)

  highlightCorrect: (event) =>
    $('.edit-option').removeClass('correct')
    @$el.addClass('correct')

  render: =>
    template = Handlebars.templates['templates/admin/question_option_form']
    @$el.html(template(_.defaults(_.clone(@option), uid: @uid)))
    @$el.addClass('correct') if @option.correct
    @delegateEvents()
    @

_.defaults(ChefStepsAdmin.Views.Option.prototype, ChefStepsAdmin.Views.Modules.FilePickerUpload, ChefStepsAdmin.Models.Modules.FilePicker)

