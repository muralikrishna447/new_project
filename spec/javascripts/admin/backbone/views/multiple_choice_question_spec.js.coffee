describe 'ChefStepsAdmin.Views.MultipleChoiceQuestion', ->
  beforeEach ->
    @fake_question = jasmine.createSpyObj('fake question', ['save', 'destroy', 'on'])
    @view = new ChefStepsAdmin.Views.MultipleChoiceQuestion(model: @fake_question)

  describe "#triggerEditQuestion", ->
    beforeEach ->
      spyOn(ChefStepsAdmin.ViewEvents, 'trigger')
      @view.triggerEditQuestion()

    it "triggers the editQuestion event", ->
      expect(ChefStepsAdmin.ViewEvents.trigger).toHaveBeenCalledWith('editQuestion', @view.model.cid)

  describe "#extendTemplateJSON", ->
    beforeEach ->
      spyOn(@view, 'convertImage').andReturn('converted image url')

    it "returns templateJSON if no image", ->
      expect(@view.extendTemplateJSON({foo: 'bar'})).toEqual({foo: 'bar'})

    it "returns templateJSON with modified image url", ->
      template_json =
        foo: 'bar'
        image: { url: 'some url' }

      converted_json =
        foo: 'bar'
        image: { url: 'converted image url' }

      expect(@view.extendTemplateJSON(template_json)).toEqual(converted_json)

  describe "#saveForm", ->
    beforeEach ->
      spyOn(@view, 'render')
      @view.saveForm()

    it "updates the model", ->
      expect(@fake_question.save).toHaveBeenCalled()

    it "renders the show template", ->
      expect(@view.render).toHaveBeenCalled()

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


  describe "#addOption", ->
    beforeEach ->
      spyOn(@view, 'addOptionView').andReturn('some option view')
      spyOn(@view, 'renderOptionView')
      @view.addOption()

    it "adds a new option view", ->
      expect(@view.addOptionView).toHaveBeenCalled()

    it "renders the option view", ->
      expect(@view.renderOptionView).toHaveBeenCalledWith('some option view')

  describe '#render', ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view, 'delegateEvents')
      spyOn(@view, 'updateAttributes')
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

    it "updates the view's attributes", ->
      @view.render()
      expect(@view.updateAttributes).toHaveBeenCalled()

