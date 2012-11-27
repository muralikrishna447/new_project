describe 'ChefStepsAdmin.Views.Question', ->
  beforeEach ->
    @fake_question = jasmine.createSpyObj('fake question', ['save', 'destroy'])
    @view = new ChefStepsAdmin.Views.Question(model: @fake_question)

  describe '#render', ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view, 'delegateEvents')
      spyOn(@view.$el, 'html')

    it "calls renderTemplate", ->
      @view.render()
      expect(@view.templateName).toEqual('admin/question')
      expect(@view.$el.html).toHaveBeenCalledWith('rendered template')

    it 'delegateEvents on the rendered template', ->
      @view.render()
      expect(@view.delegateEvents).toHaveBeenCalled()

    it 'returns reference to self for chaining', ->
      expect(@view.render()).toEqual(@view)

  describe "#cancelEdit", ->
    beforeEach ->
      spyOn(@view, 'render')
      @fake_event = jasmine.createSpyObj('fake click event', ['preventDefault'])
      @view.cancelEdit(@fake_event)

    it "prevents event defaults", ->
      expect(@fake_event.preventDefault).toHaveBeenCalled()

    it "renders the show template without saving", ->
      expect(@view.render).toHaveBeenCalled()
      expect(@fake_question.save).not.toHaveBeenCalled()

  describe "#saveForm", ->
    beforeEach ->
      spyOn(@view, 'render')
      @fake_event = jasmine.createSpyObj('fake click event', ['preventDefault'])
      @view.saveForm(@fake_event)

    it "prevents event defaults", ->
      expect(@fake_event.preventDefault).toHaveBeenCalled()

    it "updates the model", ->
      expect(@fake_question.save).toHaveBeenCalled()

    it "renders the show template", ->
      expect(@view.render).toHaveBeenCalled()

  describe "#deleteQuestion", ->
    beforeEach ->
      spyOn(@view, 'remove')
      @fake_event = jasmine.createSpyObj('fake click event', ['preventDefault'])
      @view.deleteQuestion(@fake_event)

    it "prevents event defaults", ->
      expect(@fake_event.preventDefault).toHaveBeenCalled()

    it "destroys the model", ->
      expect(@fake_question.destroy).toHaveBeenCalled()

    it "removes the view", ->
      expect(@view.remove).toHaveBeenCalled()

  describe "#isEditState", ->
    it "returns true if templateName is set to question form", ->
      expect(@view.isEditState()).toEqual(false)

    it "returns true if templateName is set to question form", ->
      @view.templateName = @view.formTemplate
      expect(@view.isEditState()).toEqual(true)

  describe "#editQuestionEventHandler", ->
    beforeEach ->
      @view.model.cid = 'matching id'
      spyOn(@view, 'render')
      spyOn(@view, 'saveForm')

    it "renders editForm", ->
      @view.editQuestionEventHandler('matching id')
      expect(@view.render).toHaveBeenCalledWith(@view.formTemplate)

    describe 'without matching cid', ->
      describe 'and in edit state', ->
        it "and in edit state, saves the form", ->
          spyOn(@view, 'isEditState').andReturn(true)
          @view.editQuestionEventHandler('some non matching id')
          expect(@view.saveForm).toHaveBeenCalled()

      describe 'and not in edit state', ->
        it "renders the normal template", ->
          spyOn(@view, 'isEditState').andReturn(false)
          @view.editQuestionEventHandler('some non matching id')
          expect(@view.render).toHaveBeenCalled()

  describe "#triggerEditQuestion", ->
    beforeEach ->
      spyOn(ChefStepsAdmin.ViewEvents, 'trigger')
      @view.triggerEditQuestion()

    it "triggers the editQuestion event", ->
      expect(ChefStepsAdmin.ViewEvents.trigger).toHaveBeenCalledWith('editQuestion', @view.model.cid)

