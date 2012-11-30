describe 'ChefStepsAdmin.Views.QuizControls', ->
  beforeEach ->
    @collection = new ChefStepsAdmin.Collections.Questions([], quizId: 'test')
    @view = new ChefStepsAdmin.Views.QuizControls(collection: @collection)

  describe 'addMultipleChoiceQuestion', ->
    beforeEach ->
      spyOn(Backbone, 'sync')

    it 'adds empty Question to collection', ->
      @view.addMultipleChoiceQuestion()
      expect(@collection.length).toBe(1)

    it 'syncs model to server', ->
      @view.addMultipleChoiceQuestion()
      expect(Backbone.sync).toHaveBeenCalled()

