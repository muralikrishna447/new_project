describe 'ChefSteps.Views.Quiz', ->
  beforeEach ->
    @navHiderSpy = jasmine.createSpyObj('navHider', ['hide'])
    @view = new ChefSteps.Views.Quiz(navHider: @navHiderSpy)

  describe '#startQuiz', ->
    it 'hides navigation', ->
      @view.startQuiz()
      expect(@navHiderSpy.hide).toHaveBeenCalled()
