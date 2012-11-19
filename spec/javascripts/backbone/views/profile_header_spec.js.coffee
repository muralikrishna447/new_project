describe "ChefSteps.Views.ProfileHeader", ->
  beforeEach ->
    loadFixtures('header')
    @fake_user = jasmine.createSpyObj('fake user', ['bind'])
    @fake_user.attributes =
      name: 'foo bar name'
      location: ''
    @view = new ChefSteps.Views.ProfileHeader(model: @fake_user, el: '.profile-info')

  describe "#initialize", ->
    it "binds to model change event and renders", ->
      expect(@fake_user.bind).toHaveBeenCalledWith('change', @view.render)

  describe "#render", ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view.$el, 'html')
      @view.render()

    it "sets the content to the renderTemplate", ->
      expect(@view.renderTemplate).toHaveBeenCalled()
      expect(@view.$el.html).toHaveBeenCalledWith('rendered template')

