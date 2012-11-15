describe 'ChefSteps.TemplatedView', ->
  beforeEach ->
    @fake_model = jasmine.createSpyObj('fake model', ['toJSON'])
    @fake_model.toJSON.andReturn("model json")
    @fake_template = "some template"
    Handlebars.templates['templates/fake_template'] = @fake_template

    @view = new ChefSteps.Views.TemplatedView(model: @fake_model)

  describe "#getTemplate", ->
    it "throws an exception if templateName is undefined", ->
      @view.templateName = null
      expect(@view.getTemplate).toThrow('NoTemplateSpecifiedError')

    it "sets the view's template", ->
      @view.templateName = 'fake_template'
      @view.getTemplate()
      expect(@view.template).toEqual(@fake_template)

