describe 'ChefStepsAdmin.Views.Question', ->
  beforeEach ->
    @fake_question = jasmine.createSpyObj('fake question', ['save', 'destroy', 'on'])
    @view = new ChefStepsAdmin.Views.Question(model: @fake_question)

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

  describe "#renderOrderingView", ->
    beforeEach ->
      spyOn(@view, 'render')
      @view.renderOrderingView()

    it "calls render and passes the orderingTemplate", ->
      expect(@view.render).toHaveBeenCalledWith(@view.orderingTemplate)

  describe "#deleteQuestion", ->
    beforeEach ->
      spyOn(@view, 'remove')
      @fake_event = jasmine.createSpy('fake click event')
      @view.deleteQuestion(@fake_event)

    it "destroys the model", ->
      expect(@fake_question.destroy).toHaveBeenCalled()

    it "removes the view", ->
      expect(@view.remove).toHaveBeenCalled()

