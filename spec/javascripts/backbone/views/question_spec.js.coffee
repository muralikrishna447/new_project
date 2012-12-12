describe 'ChefSteps.Views.Question', ->
  beforeEach ->
    @model = {id: 123}
    @view = new ChefSteps.Views.Question(model: @model)

  describe '#submitAnswer', ->
    beforeEach ->
      spyOn(@view, 'answerData').andReturn('data')
      @answer = jasmine.createSpyObj('answer', ['save'])
      spyOn(ChefSteps.Models, 'Answer').andReturn(@answer)

    it 'creates answer with question_id', ->
      @view.submitAnswer()
      expect(ChefSteps.Models.Answer).toHaveBeenCalledWith(question_id: 123)

    it 'saves answer with data', ->
      @view.submitAnswer()
      expect(@answer.save).toHaveBeenCalledWith('data', jasmine.any(Object))

  describe '#submitSuccess', ->
    it "calls #next event on model's collection", ->
      @model.collection = jasmine.createSpyObj('collection', ['next'])
      @view.submitSuccess()
      expect(@model.collection.next).toHaveBeenCalled()

