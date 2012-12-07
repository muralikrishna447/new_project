class ChefStepsAdmin.Views.Option extends Backbone.View
  className: 'edit-option'

  tagName: "li"

  events:
    'click .delete-option': 'deleteOption'
    'change input[type=radio]': 'highlightCorrect'
    'click .delete-option-image': 'deleteImage'

  initialize: (options) =>
    @option = options.option

  deleteImage: =>
    console.log 'TODO: delete image'

  deleteOption: =>
    @remove()

  highlightCorrect: (event) =>
    $('.edit-option').removeClass('correct')
    @$el.addClass('correct')

  render: =>
    template = Handlebars.templates['templates/admin/question_option_form']
    @$el.html(template(@option))
    @$el.addClass('correct') if @option.correct
    @delegateEvents()
    @

