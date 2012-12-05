describe 'ChefStepsAdmin.Models.QuizImage', ->
  beforeEach ->
    @model = new ChefStepsAdmin.Models.QuizImage()

  describe "#buildFPFile", ->
    beforeEach ->
      @model.set('url', 'some url')
      @model.set('filename', 'something silly')

    it "builds a filepicker file object", ->
      expect(@model.buildFPFile()).toEqual({url: 'some url', filename: 'something silly'})

  describe "#destroyImage", ->
    beforeEach ->
      @model.buildFPFile = () -> 'filepicker object'
      @model.destroyImage()

    it "uses the filepicker remove method to destroy the file", ->
      expect(filepicker.remove).toHaveBeenCalledWith('filepicker object', @model.destroySuccess)

