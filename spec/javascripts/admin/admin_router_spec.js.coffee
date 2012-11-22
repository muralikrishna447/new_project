describe 'ChefStepsAdmin.Router', ->
  beforeEach ->
    @router = new ChefStepsAdmin.Router()

  describe "#createQuiz", ->
    beforeEach ->
      @fake_quiz_view = jasmine.createSpyObj('fake quiz view', ['render'])
      @fake_quiz_model = jasmine.createSpy('fake quiz model')
      spyOn(ChefStepsAdmin.Models, 'Quiz').andReturn(@fake_quiz_model)
      spyOn(ChefStepsAdmin.Views, 'Quiz').andReturn(@fake_quiz_view)

      @router.createQuiz()

    it "instantiates a quiz model", ->
      expect(ChefStepsAdmin.Models.Quiz).toHaveBeenCalled()

    it "instantiates a quiz view", ->
      expect(ChefStepsAdmin.Views.Quiz).toHaveBeenCalledWith(@fake_quiz_model)

    it 'renders the quiz view', ->
      expect(@fake_quiz_view.render).toHaveBeenCalled()

