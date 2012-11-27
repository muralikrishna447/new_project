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


  describe "#renderForm", ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view, 'delegateEvents')
      spyOn(@view.$el, 'html')
      @view.renderForm()

    it "set the content to the question template", ->
      expect(@view.templateName).toEqual('admin/question_form')

    it "uses the view's editEvents for delegateEvents", ->
      expect(@view.delegateEvents).toHaveBeenCalledWith(@view.editEvents)

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

