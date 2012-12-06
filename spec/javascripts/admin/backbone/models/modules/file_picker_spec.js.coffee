describe 'ChefStepsAdmin.Models.Modules.FilePicker', ->
  beforeEach ->
    @model_module = ChefStepsAdmin.Models.Modules.FilePicker

  describe "#buildFPFile", ->
    beforeEach ->
      @model_module.get = (opt) ->
        switch opt
          when 'url' then 'some url'
          when 'filename' then 'filename Zor'

    it "builds a file object with the url and filename", ->
      expect(@model_module.buildFPFile()).toEqual({url: 'some url', filename: 'filename Zor'})

  describe "#destroyImage", ->
    beforeEach ->
      spyOn(@model_module, 'buildFPFile').andReturn('filepicker object')
      @model_module.destroyImage()

    it "uses the filepicker remove method to destroy the file", ->
      expect(filepicker.remove).toHaveBeenCalledWith('filepicker object', @model_module.destroySuccess)

  describe "#destroySuccess", ->
    it "throws an NotImplementedError", ->
      expect(@model_module.destroySuccess).toThrow("NotImplementedError")

