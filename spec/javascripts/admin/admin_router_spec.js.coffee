describe 'ChefStepsAdmin.Router', ->
  beforeEach ->
    @router = new ChefStepsAdmin.Router()

  describe "#editQuiz", ->
    beforeEach ->
      @fakeView = jasmine.createSpyObj('view', ['render'])
      spyOn(ChefStepsAdmin.Views, 'QuizImageUploader').andReturn(@fakeView)

      @router.editQuiz()

    it "instantiates a quiz image uploader view", ->
      expect(ChefStepsAdmin.Views.QuizImageUploader).toHaveBeenCalled()

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

  describe "#editQuestion", ->
    beforeEach ->
      ChefStepsAdmin.questionImageData = ['a', 'b']

      @fakeCollection = jasmine.createSpyObj('collection', ['reset'])
      @fakeView = jasmine.createSpyObj('view', ['render'])
      @fakeUploaderView = jasmine.createSpyObj('uploader view', ['render'])
      @fakeImagesView = jasmine.createSpyObj('images view', ['render'])

      spyOn(ChefStepsAdmin.Collections, 'BoxSortImages').andReturn(@fakeCollection)
      spyOn(ChefStepsAdmin.Views, 'BoxSortImageUploader').andReturn(@fakeUploaderView)
      spyOn(ChefStepsAdmin.Views, 'BoxSortImages').andReturn(@fakeImagesView)

      @router.editQuestion()

    it "instantiates a question image collection", ->
      expect(ChefStepsAdmin.Collections.BoxSortImages).toHaveBeenCalled()

    it "resets the collection from the global ChefStepsAdmin.questionImageData", ->
      expect(@fakeCollection.reset).toHaveBeenCalledWith(['a', 'b'])

    it "instantiates a BoxSortImageUploader", ->
      expect(ChefStepsAdmin.Views.BoxSortImageUploader).toHaveBeenCalledWith(collection: @fakeCollection)

    it "instantiates the BoxSortImages collection view", ->
      expect(ChefStepsAdmin.Views.BoxSortImages).toHaveBeenCalledWith(collection: @fakeCollection)

    it "renders the collection view", ->
      expect(@fakeImagesView.render).toHaveBeenCalled()

