describe 'ChefSteps.Views.Quiz', ->
  beforeEach ->
    $.fx.off = true
    loadFixtures('quiz_container')
    @navHiderSpy = jasmine.createSpyObj('navHider', ['hide'])

    @questions = jasmine.createSpyObj('collection', ['first', 'on'])

    @questionView =
      $el: $('.contents')
      render: ->

    spyOn(@questionView, 'render').andReturn(@questionView)
    spyOn(ChefSteps.Views, 'Question').andReturn(@questionView)

    @view = new ChefSteps.Views.Quiz
      el: '#quiz-container'
      collection: @questions
      navHider: @navHiderSpy
      quizCompletionPath: 'path'

  describe '#initialize', ->
    it 'keeps reference to quizCompletionPath', ->
      expect(@view.quizCompletionPath).toEqual('path')

    it 'adds listener to collections next event', ->
      expect(@questions.on).toHaveBeenCalledWith('next', @view.loadNextQuestion, @view)

  describe '#startQuiz', ->
    beforeEach ->
      @questions.first = -> 'q1'
      spyOn(@view, 'loadNextQuestion')
      @view.startQuiz()

    it 'hides navigation', ->
      expect(@navHiderSpy.hide).toHaveBeenCalled()

    it 'loads first question', ->
      expect(@view.loadNextQuestion).toHaveBeenCalledWith('q1')

  describe '#loadNextQuestion', ->
    it 'hides contents', ->
      @view.loadNextQuestion('model')
      expect($('.contents')).not.toBeVisible()

    it 'creates a question view for current question', ->
      @view.loadNextQuestion('model')
      expect(ChefSteps.Views.Question).toHaveBeenCalledWith(model: 'model')

    it 'renders question view', ->
      @view.loadNextQuestion('model')
      expect(@questionView.render).toHaveBeenCalled()

    it 'calls quizComplete if model is undefined', ->
      spyOn(@view, 'quizComplete')
      @view.loadNextQuestion(undefined)
      expect(@view.quizComplete).toHaveBeenCalled()
