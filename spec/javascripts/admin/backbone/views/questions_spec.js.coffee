describe 'ChefStepsAdmin.Views.Questions', ->
  beforeEach ->
    loadFixtures('question_list')

    @collection = new ChefStepsAdmin.Collections.Questions([{id: 1}, {id: 2}], quizId: 'test')
    spyOn(@collection, 'on')

    @view = new ChefStepsAdmin.Views.Questions(collection: @collection)

    @fakeView = jasmine.createSpyObj('view', ['render'])
    @fakeView.render.andReturn(@fakeView)

  describe '#initialize', ->
    it "adds listener to collections's 'add' event", ->
      expect(@collection.on).toHaveBeenCalledWith('add', @view.addNewQuestionToList, @view)

    it "adds listener to collections's 'add' and 'remove' event", ->
      expect(@collection.on).toHaveBeenCalledWith('add remove', @view.updateQuestionCount, @view)

  describe '#render', ->
    beforeEach ->
      spyOn(@view, 'addQuestionToList')

    it 'returns reference to self for chaining', ->
      expect(@view.render()).toEqual(@view)

    it 'calls addQuestionToList for each model in collection', ->
      @view.render()
      expect(@view.addQuestionToList.calls.length).toEqual(2)

  describe '#addQuestionToList', ->
    beforeEach ->
      spyOn(@view, 'scrollElementIntoView')
      @model = new ChefStepsAdmin.Models.Question(id: 1)

    it 'creates a new Question view for the new model', ->
      spyOn(ChefStepsAdmin.Views, 'Question').andReturn(@fakeView)
      @view.addQuestionToList(@model)
      expect(ChefStepsAdmin.Views.Question).toHaveBeenCalled()

    it "adds new question html to list view", ->
      @view.addQuestionToList(@model)
      expect($('ul#question-list li').length).toEqual(1)

    it "scrolls content into view by default", ->
      @view.addQuestionToList(@model)
      expect(@view.scrollElementIntoView).toHaveBeenCalled()

    it "doesn't scroll content into view if requested", ->
      @view.addQuestionToList(@model, false)
      expect(@view.scrollElementIntoView).not.toHaveBeenCalled()

  describe "#addNewQuestionToList", ->
    beforeEach ->
      spyOn(ChefStepsAdmin.ViewEvents, 'trigger')
      spyOn(@view, 'addQuestionToList')
      @model = new ChefStepsAdmin.Models.Question(id: 1)
      @view.addNewQuestionToList(@model)

    it "adds the question to the list", ->
      expect(@view.addQuestionToList).toHaveBeenCalledWith(@model)

    it "triggers editQuestion event", ->
      expect(ChefStepsAdmin.ViewEvents.trigger).toHaveBeenCalledWith('editQuestion', @model.cid)

  describe "#updateQuestionCount", ->
    it "sets the question count ", ->
      @view.updateQuestionCount()
      expect($('#question-count .count').text()).toEqual("#{@collection.length}")


  describe "#getQuestionView", ->
    it "defaults to QuestionView", ->
      model = new ChefStepsAdmin.Models.Question()
      subject = @view.getQuestionView(model)
      expect(subject instanceof ChefStepsAdmin.Views.Question ).toBeTruthy()

    it "instantiates a view based on model", ->
      model = new ChefStepsAdmin.Models.MultipleChoiceQuestion()
      subject = @view.getQuestionView(model)
      expect(subject instanceof ChefStepsAdmin.Views.MultipleChoiceQuestion).toBeTruthy()

