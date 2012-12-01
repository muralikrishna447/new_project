describe 'ChefSteps.Views.Question', ->
  beforeEach ->
    @view = new ChefSteps.Views.Question()

  describe '#show', ->
    it 'creates the checkbox views', ->
      spyOn(@view, 'createCheckboxes')
      @view.show()
      expect(@view.createCheckboxes).toHaveBeenCalled()

    it 'sets the visible class', ->
      @view.show()
      expect(@view.$el).toHaveClass('visible')
