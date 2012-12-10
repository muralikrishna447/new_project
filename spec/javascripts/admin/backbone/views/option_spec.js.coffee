describe "ChefStepsAdmin.Views.Option", ->
  beforeEach ->
    @fake_question_view = jasmine.createSpyObj('question view', ['removeOptionView'])
    @view = new ChefStepsAdmin.Views.Option(option: {title: 'some option'}, optionView: @fake_question_view )

  describe "#deleteOption", ->
    beforeEach ->
      spyOn(@view, 'remove')
      spyOn(@view, 'destroyImage')
      @fake_event = jasmine.createSpy('fake click event')
      @view.deleteOption(@fake_event)

    it "destroys the image without callback", ->
      expect(@view.destroyImage).toHaveBeenCalledWith(true)

    it "removes itself from the DOM", ->
      expect(@view.remove).toHaveBeenCalled()

    it "has the question view remove itself", ->
      expect(@fake_question_view.removeOptionView).toHaveBeenCalledWith(@view)

  describe "#filePickerOnSuccess", ->
    beforeEach ->
      spyOn(@view, 'render')
      spyOn(@view, 'destroyImage')
      @view.filePickerOnSuccess('fp file')

    it "sets the image", ->
      expect(@view.option['image']).toEqual('fp file')

    it "renders the view", ->
      expect(@view.render).toHaveBeenCalled()

    it "destroys any pre-existing images", ->
      expect(@view.destroyImage).toHaveBeenCalledWith(true)

  describe "#destroySuccess", ->
    beforeEach ->
      spyOn(@view, 'render')
      @view.destroySuccess()

    it "sets the image to an empty hash", ->
      expect(@view.option['image']).toEqual({})

    it "renders the view", ->
      expect(@view.render).toHaveBeenCalled()

