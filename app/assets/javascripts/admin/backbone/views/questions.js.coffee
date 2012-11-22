class ChefStepsAdmin.Views.Questions extends Backbone.View
  el: '#question-list'

  render: ->
    @collection.each (question)=>
      view = new ChefStepsAdmin.Views.Question(model: question)
      @$el.append(view.renderTemplate())
    @
