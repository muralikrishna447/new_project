describe 'ChefSteps.Views.Quiz', ->
  beforeEach ->
    @navHiderSpy = jasmine.createSpyObj('navHider', ['hide'])

    @questions = jasmine.createSpyObj('collection', ['first', 'on'])
    spyOn(ChefSteps.Views, 'Question').andReturn(jasmine.createSpyObj('questionView', ['render']))

    @view = new ChefSteps.Views.Quiz
      collection: @questions
      navHider: @navHiderSpy

  describe '#initialize', ->
    it 'adds listener to collections next event', ->
      expect(@questions.on).toHaveBeenCalledWith('next', @view.loadNextQuestion, @view)

  describe '#startQuiz', ->
    it 'hides navigation', ->
      @view.startQuiz()
      expect(@navHiderSpy.hide).toHaveBeenCalled()

    it 'loads first question', ->
      @questions.first = -> 'q1'
      spyOn(@view, 'loadNextQuestion')
      @view.startQuiz()
      expect(@view.loadNextQuestion).toHaveBeenCalledWith('q1')

  describe '#loadNextQuestion', ->
    beforeEach ->
      @view.loadNextQuestion('model')

    it 'creates a question view for current question', ->
      expect(ChefSteps.Views.Question).toHaveBeenCalledWith(model: 'model')
