class ChefSteps.Views.Quiz extends Backbone.View
  events:
    'click #start-quiz': 'startQuiz'

  initialize: (options)->
    @navHider = options.navHider
    @collection.on('next', @loadNextQuestion, @)

  startQuiz: ->
    @navHider.hide()
    @loadNextQuestion(@collection.first())

  loadNextQuestion: (model)->
    question = new ChefSteps.Views.Question(model: model)
    @$('>').fadeOut 'slow', =>
      @$el.html(question.render().$el)
      setTimeout(question.show, 1)
