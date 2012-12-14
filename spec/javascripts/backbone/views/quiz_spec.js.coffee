describe 'ChefSteps.Views.Quiz', ->
  beforeEach ->
    $.fx.off = true
    loadFixtures('quiz_container')
    @navHiderSpy = jasmine.createSpyObj('navHider', ['hide'])

    @questions = jasmine.createSpyObj('collection', ['first', 'on'])

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
    beforeEach ->
      @questionView =
        $el: $('.contents')
        render: ->
      spyOn(@questionView, 'render').andReturn(@questionView)
      spyOn(@view, 'newQuestionView').andReturn(@questionView)

    it 'hides contents', ->
      @view.loadNextQuestion('model')
      expect($('.contents')).not.toBeVisible()

    it 'creates a question view for current question', ->
      @view.loadNextQuestion('model')
      expect(@view.newQuestionView).toHaveBeenCalledWith('model')

    it 'renders question view', ->
      @view.loadNextQuestion('model')
      expect(@questionView.render).toHaveBeenCalled()

    it 'calls quizComplete if model is undefined', ->
      spyOn(@view, 'quizComplete')
      @view.loadNextQuestion(undefined)
      expect(@view.quizComplete).toHaveBeenCalled()

  describe '#newQuestionView', ->
    beforeEach ->
      @fakeModel = {
        get: ->
          @questionType
      }
      spyOn(ChefSteps.Views, 'MultipleChoiceQuestion')
      spyOn(ChefSteps.Views, 'BoxSortQuestion')

    it "returns new MultipleChoiceQuestion if type is 'multiple_choice'", ->
      @fakeModel.questionType = 'multiple_choice'
      @view.newQuestionView(@fakeModel)
      expect(ChefSteps.Views.MultipleChoiceQuestion).toHaveBeenCalled()

    it "returns BoxSortQuestion if type is 'box_sort'", ->
      @fakeModel.questionType = 'box_sort'
      @view.newQuestionView(@fakeModel)
      expect(ChefSteps.Views.BoxSortQuestion).toHaveBeenCalled()
