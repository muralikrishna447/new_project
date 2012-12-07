describe 'ChefStepsAdmin.Models.Question', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.Question()

  describe "#destroySuccess", ->
    beforeEach ->
      spyOn(@model, 'set')
      spyOn(@model, 'save')
      @model.destroySuccess()

    it "sets image to an empty hash", ->
      expect(@model.set).toHaveBeenCalledWith('image', {})

    it "saves the model", ->
      expect(@model.save).toHaveBeenCalled()

  describe "#getImage", ->
    beforeEach ->
      spyOn(@model, 'get').andReturn('some image')

    it "returns the image object", ->
      expect(@model.getImage()).toEqual('some image')

  describe "#destroy", ->
    beforeEach ->
      spyOn(@model, 'destroyImage')
      @model.destroy()

    it "destroys associated image", ->
      expect(@model.destroyImage).toHaveBeenCalledWith(false)

