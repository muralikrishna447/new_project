describe 'ChefStepsAdmin.Views.Question', ->
  beforeEach ->
    @fake_question = jasmine.createSpy('fake question')
    @view = new ChefStepsAdmin.Views.Question(model: @fake_question)

  describe '#render', ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view, 'delegateEvents')
      spyOn(@view.$el, 'html')

    it "calls renderTemplate", ->
      @view.render()
      expect(@view.$el.html).toHaveBeenCalledWith('rendered template')

    it 'delegateEvents on the rendered template', ->
      @view.render()
      expect(@view.delegateEvents).toHaveBeenCalled()

    it 'returns reference to self for chaining', ->
      expect(@view.render()).toEqual(@view)

