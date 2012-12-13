describe 'ChefStepsAdmin.Models.MultipleChoiceQuestion', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.MultipleChoiceQuestion()

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

  describe "#toJSON", ->
    beforeEach ->
      @imageObject = { 'name': 'some image name'}
      @model.set('image', @imageObject)

    it "it creates a cloned image object", ->
      expect(@model.toJSON()['image']).not.toBe(@imageObject)

  describe "#snapshot and #revert", ->
    describe 'when snapshot has been taken', ->
      beforeEach ->
        @model.set('id', 123)
        @model.snapshot()

      it 'stores snapshotted attributes in separate object', ->
        @model.set('id', 456)
        expect(@model.attributeSnapshot.id).toEqual(123)

      it 'reverts model back to snapshot', ->
        @model.set('id', 456)
        @model.revert()
        expect(@model.id).toEqual(123)

      it 'clears new attributes that were set since snapshot', ->
        @model.set('newAttribute', 'attrValue')
        @model.revert()
        expect(@model.get('newAttribute')).toBeUndefined()

    it 'does not revert if no snapshot taken', ->
      @model.set('newAttribute', 'attrValue')
      @model.revert()
      expect(@model.get('newAttribute')).toEqual('attrValue')
