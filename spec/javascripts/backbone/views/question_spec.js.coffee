describe 'ChefSteps.Views.Question', ->
  beforeEach ->
    @view = new ChefSteps.Views.Question()

  describe '#show', ->
    it 'sets the visible class', ->
      @view.show()
      expect(@view.$el).toHaveClass('visible')
