describe 'ChefSteps.Collections.BoxSortAnswers', ->
  beforeEach ->
    @collection = new ChefSteps.Collections.BoxSortAnswers()

  describe '#addAnswer', ->
    beforeEach ->
      @collection.addAnswer(1, 'ABCD')

    it 'creates new answer for new image id', ->
      expect(@collection.size()).toEqual(1)
      expect(@collection.get(1).attributes).toEqual(id: 1, optionUid: 'ABCD')

    it "changes answer's option UID for existing answer", ->
      @collection.addAnswer(1, 'XYZ')
      expect(@collection.size()).toEqual(1)
      expect(@collection.get(1).attributes).toEqual(id: 1, optionUid: 'XYZ')
