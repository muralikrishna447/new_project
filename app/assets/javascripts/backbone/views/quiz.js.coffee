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
    @$('>').fadeOut =>
      @$el.html(question.render().$el)
      setTimeout(question.show, 1)

    @questionIndex += 1
