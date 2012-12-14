class ChefSteps.Views.Quiz extends Backbone.View
  events:
    'click #start-quiz': 'startQuiz'

  initialize: (options)->
    @navHider = options.navHider
    @quizCompletionPath = options.quizCompletionPath
    @collection.on('next', @loadNextQuestion, @)

  startQuiz: ->
    @navHider.hide()
    @loadNextQuestion(@collection.first())

  loadNextQuestion: (model)->
    @$('>').fadeOut 'slow', =>
      return @quizComplete() unless model
      question = @newQuestionView(model)
      @$el.html(question.render().$el)
      question.$el.animate({marginLeft: 0, opacity: 1}, 1000)

  quizComplete: ->
    window.location = @quizCompletionPath

  newQuestionView: (model) ->
    if model.get('question_type') == 'box_sort'
      new ChefSteps.Views.BoxSortQuestion(model: model)
    else
      new ChefSteps.Views.MultipleChoiceQuestion(model: model)
