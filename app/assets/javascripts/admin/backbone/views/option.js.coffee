class ChefStepsAdmin.Views.Option extends Backbone.View
  className: 'edit-option'

  tagName: "li"

  events:
    'click .delete-option': 'deleteOption'
    'change input[type=radio]': 'highlightCorrect'

  initialize: (options) =>
    @option = options.option

  deleteOption: (event) =>
    event.preventDefault()
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

