class ChefStepsAdmin.Views.Question extends ChefSteps.Views.TemplatedView
  className: 'question'

  tagName: "li"

  showTemplate: 'admin/multiple_choice_question'
  orderingTemplate: 'admin/question_ordering'

  events:
    'click .delete': 'deleteQuestion'

  initialize: (options) =>
    ChefStepsAdmin.ViewEvents.on("questionOrderingMode", @renderOrderingView)
    ChefStepsAdmin.ViewEvents.on("questionNormalMode", @render)
    @model.on("change:id", @updateAttributes)

  renderOrderingView: => @render(@orderingTemplate)

  deleteQuestion: (event) =>
    confirmMessage = $(event.currentTarget).data('confirm')
    if not confirmMessage || confirm(confirmMessage)
      @model.destroy()
      @remove()

  render: (templateName = @showTemplate) =>
    @templateName = templateName
    @$el.html(@renderTemplate())
    @delegateEvents()
    @updateAttributes()
    @

  updateAttributes: => @$el.attr('id', "question-#{@model.get('id')}")

