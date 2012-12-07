describe 'ChefStepsAdmin.Models.Question', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.Question()

  describe "#destroySuccess", ->
    beforeEach ->
      spyOn(@model, 'set')
      @model.destroySuccess()

    it "sets image to an empty hash", ->
      expect(@model.set).toHaveBeenCalledWith('image', {})

  describe "#getImage", ->
    beforeEach ->
      spyOn(@model, 'get').andReturn('some image')

    it "returns the image object", ->
      expect(@model.getImage()).toEqual('some image')

