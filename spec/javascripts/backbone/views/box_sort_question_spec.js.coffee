describe 'ChefSteps.Views.BoxSortQuestion', ->
  beforeEach ->
    @view = new ChefSteps.Views.BoxSortQuestion()

  describe '#render', ->
    it 'instantiates a BoxSortImageSet', ->
      spyOn(ChefSteps.Views, 'BoxSortImageSet')
      @view.render()
      expect(ChefSteps.Views.BoxSortImageSet).toHaveBeenCalled()

  describe '#answerData', ->
    it "includes 'box_sort' question type", ->
      expect(@view.answerData().type).toEqual('box_sort')
