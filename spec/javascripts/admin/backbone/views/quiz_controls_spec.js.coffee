describe 'ChefStepsAdmin.Views.QuizControls', ->
  beforeEach ->
    @collection = new ChefStepsAdmin.Collections.Questions([])
    @view = new ChefStepsAdmin.Views.QuizControls(collection: @collection)

  describe 'addMultipleChoiceQuestion', ->
    it 'adds empty Question to collection', ->
      @view.addMultipleChoiceQuestion()
      expect(@collection.length).toBe(1)
