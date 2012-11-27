describe 'ChefStepsAdmin.Views.QuizControls', ->
  beforeEach ->
    @collection = new ChefStepsAdmin.Collections.Questions([], quizId: 'test')
    @view = new ChefStepsAdmin.Views.QuizControls(collection: @collection)

  describe 'addMultipleChoiceQuestion', ->
    it 'adds empty Question to collection', ->
      @view.addMultipleChoiceQuestion()
      expect(@collection.length).toBe(1)

    it 'syncs model to server', ->
      spyOn(Backbone, 'sync')
      @view.addMultipleChoiceQuestion()
      expect(Backbone.sync).toHaveBeenCalled()

