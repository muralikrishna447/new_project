class ChefStepsAdmin.Views.Option extends Backbone.View
  className: 'option'

  tagName: "li"

  events:
    'click .delete-option': 'deleteOption'

  initialize: (options) =>
    @option = options.option

  deleteOption: (event) =>
    event.preventDefault()
    @remove()

  render: =>
    template = Handlebars.templates['templates/admin/question_option_form']
    @$el.html(template(@option))
    @delegateEvents()
    @

