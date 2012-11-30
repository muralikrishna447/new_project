describe "ChefStepsAdmin.Views.Option", ->
  beforeEach ->
    @view = new ChefStepsAdmin.Views.Option(option: 'some options' )

  describe "#deleteOption", ->
    beforeEach ->
      @fake_event = jasmine.createSpyObj('fake click event', ['preventDefault'])
      spyOn(@view, 'remove')
      @view.deleteOption(@fake_event)

    it "prevents event defaults", ->
      expect(@fake_event.preventDefault).toHaveBeenCalled()

    it "removes itself from the DOM", ->
      expect(@view.remove).toHaveBeenCalled()

