describe 'ChefSteps.Collections.Questions', ->
  beforeEach ->
    @collection = new ChefSteps.Collections.Questions([{id:1},{id:2},{id:3}])

  describe '.initialize', ->
    it 'sets the index to 0', ->
      expect(@collection.index).toEqual(0)

  describe '#current', ->
    it 'returns the question at the current index', ->
      @collection.index = 1
      model = @collection.current()
      expect(model.id).toEqual(2)

  describe '#next', ->
    it "advances the index", ->
      @collection.next()
      expect(@collection.index).toEqual(1)

    it "triggers the 'next' event", ->
      spyOn(@collection, 'trigger')
      @collection.next()
      expect(@collection.trigger).toHaveBeenCalledWith('next', @collection.at(1))
