class ChefSteps.Views.Quiz extends Backbone.View
  events:
    'click #start-quiz': 'startQuiz'

  initialize: (options)->
    @navHider = options.navHider
    @quizId = options.quizId
    @quizCompletionPath = options.quizCompletionPath
    @collection.on('next', @loadNextQuestion, @)

  startQuiz: ->
    @navHider.hide()
    @postStart()
    @loadNextQuestion(@collection.first())

  loadNextQuestion: (model)->
    @$('>').fadeOut 'slow', =>
      return @quizComplete() unless model
      question = @newQuestionView(model)
      @$el.html(question.render().$el)
      question.$el.animate({marginLeft: 0, opacity: 1}, 1000)

  quizComplete: =>
    $.ajax "#{@quizId}/finish",
      type: 'POST',
      dataType: 'json'
      data: { user_id: ChefSteps.router.currentUser.get('id') },
      success: => window.location = @quizCompletionPath

  newQuestionView: (model) ->
    question_type = model.get('question_type')

    if question_type == 'box_sort'
      new ChefSteps.Views.BoxSortQuestion(model: model)
    else if question_type == 'order_sort'
      new ChefSteps.Views.OrderSortQuestion(model: model)
    else
      new ChefSteps.Views.MultipleChoiceQuestion(model: model)

  postStart: =>
    $.ajax "#{@quizId}/start",
      type: 'POST',
      dataType: 'json'
      data: { user_id: ChefSteps.router.currentUser.get('id') }

