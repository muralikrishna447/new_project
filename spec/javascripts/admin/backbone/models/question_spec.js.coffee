describe 'ChefStepsAdmin.Models.Question', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.Question()

  describe "#destroy", ->
    beforeEach ->
      spyOn(@model, 'destroyImage')
      @model.destroy()

    it "destroys associated image", ->
      expect(@model.destroyImage).toHaveBeenCalledWith(false)

