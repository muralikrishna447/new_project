class ChefStepsAdmin.Views.QuizControls extends Backbone.View
  el: '#quiz-controls'

  events:
    'click #add-multiple-choice-question': 'addMultipleChoiceQuestion'

  addMultipleChoiceQuestion: ->
    @collection.add(new ChefStepsAdmin.Models.Question())

