describe "ChefStepsAdmin.Views.Option", ->
  beforeEach ->
    @view = new ChefStepsAdmin.Views.Option(option: 'some options' )

  describe "#deleteOption", ->
    beforeEach ->
      spyOn(@view, 'remove')
      @view.deleteOption()

    it "removes itself from the DOM", ->
      expect(@view.remove).toHaveBeenCalled()

