describe 'ChefSteps.Models.Answer', ->
  beforeEach ->
    @model = new ChefSteps.Models.Answer({question_id: 123})

  describe '#url', ->
    it 'is of form /questions/:question_id/answers', ->
      expect(@model.url()).toEqual('questions/123/answers')

