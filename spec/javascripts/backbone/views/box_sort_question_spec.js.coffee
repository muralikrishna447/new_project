describe 'ChefSteps.Views.BoxSortQuestion', ->
  describe '#render', ->
    it 'instantiates a BoxSortImageSet', ->
      spyOn(ChefSteps.Views, 'BoxSortImageSet')
      @view = new ChefSteps.Views.BoxSortQuestion()
      @view.render()
      expect(ChefSteps.Views.BoxSortImageSet).toHaveBeenCalled()
