describe 'ChefSteps.Models.Question', ->
  beforeEach ->
    @model = new ChefSteps.Models.Question({id: 123})

  describe '#url', ->
    it 'is of form /questions/:id', ->
      expect(@model.url()).toEqual('questions/123')
