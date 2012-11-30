describe 'ChefStepsAdmin.Router', ->
  beforeEach ->
    @router = new ChefStepsAdmin.Router()

  describe "#editQuizQuestions", ->
    beforeEach ->
      ChefStepsAdmin.questionsData = ['a', 'b']

      @fakeCollection = jasmine.createSpyObj('collection', ['reset'])
      @fakeView = jasmine.createSpyObj('view', ['render'])
      spyOn(ChefStepsAdmin.Collections, 'Questions').andReturn(@fakeCollection)
      spyOn(ChefStepsAdmin.Views, 'Questions').andReturn(@fakeView)
      spyOn(ChefStepsAdmin.Views, 'QuizControls')

      @router.editQuizQuestions()

    it "instantiates a questions collection", ->
      expect(ChefStepsAdmin.Collections.Questions).toHaveBeenCalled()

    it "resets the collection from the global ChefStepsAdmin.questionsData", ->
      expect(@fakeCollection.reset).toHaveBeenCalledWith(['a', 'b'])

    it "instantiates a questions view", ->
      expect(ChefStepsAdmin.Views.Questions).toHaveBeenCalledWith(collection: @fakeCollection)

    it 'renders the view', ->
      expect(@fakeView.render).toHaveBeenCalled()

    it "instantiates a quiz controls view", ->
      expect(ChefStepsAdmin.Views.QuizControls).toHaveBeenCalledWith(collection: @fakeCollection)

