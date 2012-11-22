describe 'ChefStepsAdmin.Router', ->
  beforeEach ->
    @router = new ChefStepsAdmin.Router()

  describe "#createQuiz", ->
    beforeEach ->
      @fake_quiz_view = fake_quiz_view = jasmine.createSpyObj('fake quiz view', ['render'])
      @fake_quiz_model = fake_quiz_model = jasmine.createSpy('fake quiz model')
      spyOn(ChefSteps, 'new').andCallFake (klass) ->
        switch klass
          when ChefStepsAdmin.Models.Quiz
            fake_quiz_model
          when ChefStepsAdmin.Views.Quiz
            fake_quiz_view

      @quiz = fake_quiz_model
      @router.createQuiz()

    it "instantiates a quiz model", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefStepsAdmin.Models.Quiz)

    it "instantiates a quiz view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefStepsAdmin.Views.Quiz, @fake_quiz_model)

    it 'renders the quiz view', ->
      expect(@fake_quiz_view.render).toHaveBeenCalled()

