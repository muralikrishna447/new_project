describe 'ChefSteps.Views.Quiz', ->
  beforeEach ->
    @navHiderSpy = jasmine.createSpyObj('navHider', ['hide'])

    @questions = ['q1', 'q2']
    @questions.at = (index)->
      this[index]

    spyOn(ChefSteps.Views, 'Question').andReturn(jasmine.createSpyObj('questionView', ['render']))

    @view = new ChefSteps.Views.Quiz
      collection: @questions
      navHider: @navHiderSpy

  describe '#initialize', ->
    it 'sets question index to 0', ->
      expect(@view.questionIndex).toEqual(0)

  describe '#startQuiz', ->
    it 'hides navigation', ->
      @view.startQuiz()
      expect(@navHiderSpy.hide).toHaveBeenCalled()

    it 'loads first question', ->
      spyOn(@view, 'loadNextQuestion')
      @view.startQuiz()
      expect(@view.loadNextQuestion).toHaveBeenCalled()

  describe '#loadNextQuestion', ->
    beforeEach ->
      @view.loadNextQuestion()

    it 'creates a question view for current question', ->
      expect(ChefSteps.Views.Question).toHaveBeenCalledWith(model: 'q1')

    it 'creates a question view for next question on subsequent call', ->
      @view.loadNextQuestion()
      expect(ChefSteps.Views.Question.mostRecentCall.args[0]).toEqual(model: 'q2')

