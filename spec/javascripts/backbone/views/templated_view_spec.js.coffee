describe 'ChefSteps.TemplatedView', ->
  beforeEach ->
    @fake_model = jasmine.createSpyObj('fake model', ['toJSON'])
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

  describe "#getTemplateJSON", ->
    beforeEach ->
      spyOn(@view, 'extendTemplateJSON').andCallThrough()
      @fake_model.toJSON.andReturn("some fake model json")

    it "returns the model's toJSON", ->
      expect(@view.getTemplateJSON()).toEqual("some fake model json")

    it "returns an empty hash if no model", ->
      @view.model = null
      expect(@view.getTemplateJSON()).toEqual({})

    it 'extends the json object', ->
      @view.getTemplateJSON()
      expect(@view.extendTemplateJSON).toHaveBeenCalledWith('some fake model json')

  describe "#setupTemplate", ->
    beforeEach ->
      spyOn(@view, 'getTemplate')
      spyOn(@view, 'getTemplateJSON')
      @view.setupTemplate()

    it "gets the template", ->
      expect(@view.getTemplate).toHaveBeenCalled()

    it "builds the JSON object for the template", ->
      expect(@view.getTemplateJSON).toHaveBeenCalled()

  describe "#renderTemplate", ->
    beforeEach ->
      spyOn(@view, 'setupTemplate').andReturn('rainbows and puppies JSON')
      @view.template = jasmine.createSpy('template').andReturn('rendered template')
      @result = @view.renderTemplate()

    it "gets the template", ->
      expect(@view.setupTemplate).toHaveBeenCalled()

    it "passes the templateJSON into the template", ->
      expect(@view.template).toHaveBeenCalledWith('rainbows and puppies JSON')

    it "returns the rendered template", ->
      expect(@result).toEqual('rendered template')

