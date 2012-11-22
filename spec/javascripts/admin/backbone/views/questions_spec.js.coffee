describe 'ChefStepsAdmin.Views.Questions', ->
  beforeEach ->
    loadFixtures('question_list')

    @collection = new ChefStepsAdmin.Collections.Questions([{id: 1}, {id: 2}])
    spyOn(@collection, 'on')

    @view = new ChefStepsAdmin.Views.Questions(collection: @collection)

    @fakeView = jasmine.createSpyObj('view',['renderTemplate'])

  describe '#initialize', ->
    it "adds listener to collections's 'add' event", ->
      expect(@collection.on).toHaveBeenCalledWith('add', @view.addQuestionToList, @view)

  describe '#render', ->
    it 'returns reference to self for chaining', ->
      expect(@view.render()).toEqual(@view)

    it 'calls addQuestionToList for each model in collection', ->
      spyOn(@view, 'addQuestionToList')
      @view.render()
      expect(@view.addQuestionToList.calls.length).toEqual(2)

  describe '#addQuestionToList', ->
    beforeEach ->
      @model = new ChefStepsAdmin.Models.Question(id: 1)

    it 'creates a new Question view for the new model', ->
      spyOn(ChefStepsAdmin.Views, 'Question').andReturn(@fakeView)
      @view.addQuestionToList(@model)
      expect(ChefStepsAdmin.Views.Question).toHaveBeenCalled()

    it "adds new question html to list view", ->
      @view.addQuestionToList(@model)
      expect($('ul#question-list li').length).toEqual(1)
