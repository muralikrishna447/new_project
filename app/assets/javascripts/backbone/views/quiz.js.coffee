class ChefSteps.Views.Quiz extends Backbone.View
  events:
    'click #start-quiz': 'startQuiz'

  initialize: (options)->
    @navHider = options.navHider
    @questionIndex = 0

  startQuiz: ->
    @navHider.hide()
    @loadNextQuestion()

  loadNextQuestion: ->
    model = @collection.at(@questionIndex)
    question = new ChefSteps.Views.Question(model: model)
    @$el.html(question.render())
    @questionIndex += 1

