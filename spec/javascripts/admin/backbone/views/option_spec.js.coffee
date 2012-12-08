describe "ChefStepsAdmin.Views.Option", ->
  beforeEach ->
    @view = new ChefStepsAdmin.Views.Option(option: {title: 'some option'} )

  describe "#deleteOption", ->
    beforeEach ->
      spyOn(@view, 'remove')
      spyOn(@view, 'destroyImage')
      @view.deleteOption()

    it "destroys the image without callback", ->
      expect(@view.destroyImage).toHaveBeenCalledWith(true)

    it "removes itself from the DOM", ->
      expect(@view.remove).toHaveBeenCalled()

  describe "#filePickerOnSuccess", ->
    beforeEach ->
      spyOn(@view, 'render')
      spyOn(@view, 'destroyImage')

    describe "without a pre-existing image", ->
      beforeEach ->
        spyOn(@view, 'hasImage').andReturn(false)
        @view.filePickerOnSuccess('fp file')

      it "sets the image", ->
        expect(@view.option['image']).toEqual('fp file')

      it "renders the view", ->
        expect(@view.render).toHaveBeenCalled()

      it "doesn't destroy the image", ->
        expect(@view.destroyImage).not.toHaveBeenCalled()

    describe "with a pre-existing image", ->
      beforeEach ->
        spyOn(@view, 'hasImage').andReturn(true)
        @view.filePickerOnSuccess('fp file')

      it "sets the image", ->
        expect(@view.option['image']).toEqual('fp file')

      it "renders the view", ->
        expect(@view.render).toHaveBeenCalled()

      it "destroys the image with the callback", ->
        expect(@view.destroyImage).toHaveBeenCalledWith(true)

  describe "#destroySuccess", ->
    beforeEach ->
      spyOn(@view, 'render')
      @view.destroySuccess()

    it "sets the image to an empty hash", ->
      expect(@view.option['image']).toEqual({})

    it "renders the view", ->
      expect(@view.render).toHaveBeenCalled()

