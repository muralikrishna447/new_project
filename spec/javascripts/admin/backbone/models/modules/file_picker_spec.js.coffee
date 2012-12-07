describe 'ChefStepsAdmin.Models.Modules.FilePicker', ->
  beforeEach ->
    @model_module = ChefStepsAdmin.Models.Modules.FilePicker

  describe "#buildFPFile", ->
    beforeEach ->
      spyOn(@model_module, 'getImage').andReturn({ filename: 'filename Zor', url: 'some url' } )

    it "builds a file object with the url and filename", ->
      expect(@model_module.buildFPFile()).toEqual({url: 'some url', filename: 'filename Zor'})

  describe "#destroyImage", ->
    describe "with a valid image", ->
      beforeEach ->
        spyOn(@model_module, 'buildFPFile').andReturn('filepicker object')
        spyOn(@model_module, 'hasImage').andReturn(true)
        @model_module.destroyImage()

      it "uses the filepicker remove method to destroy the file", ->
        expect(filepicker.remove).toHaveBeenCalledWith('filepicker object', @model_module.destroySuccess)

    describe "without a valid image", ->
      beforeEach ->
        spyOn(@model_module, 'hasImage').andReturn(false)
        @model_module.destroyImage()

      it "does nothing if image isn't present", ->
        expect(filepicker.remove).not.toHaveBeenCalled()

  describe "#destroySuccess", ->
    it "throws an NotImplementedError", ->
      expect(@model_module.destroySuccess).toThrow("NotImplementedError")

  describe "#getImage", ->
    it "throws an NotImplementedError", ->
      expect(@model_module.getImage).toThrow("NotImplementedError")

  describe "#hasImage", ->
    it "returns true if image and image.url is present", ->
      spyOn(@model_module, 'getImage').andReturn({url: 'foo'})
      expect(@model_module.hasImage()).toBeTruthy()

    it "returns false if image isn't present", ->
      spyOn(@model_module, 'getImage').andReturn({})
      expect(@model_module.hasImage()).toBeFalsy()

    it "returns false if image.url isn't present", ->
      spyOn(@model_module, 'getImage').andReturn({url: ''})
      expect(@model_module.hasImage()).toBeFalsy()

