describe 'ChefStepsAdmin.Models.QuizImage', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.QuizImage()

  describe "#destroySuccess", ->
    beforeEach ->
      spyOn(@model, 'destroy')
      @model.destroySuccess()

    it "destroys the model on success", ->
      expect(@model.destroy).toHaveBeenCalled()

