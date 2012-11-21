describe "ChefSteps.Views.ProfileHeader", ->
  beforeEach ->
    loadFixtures('header')
    @fake_user = jasmine.createSpyObj('fake user', ['bind'])
    @fake_user.url = () -> 'some user url'
    @fake_user.attributes =
      name: 'foo bar name'
      location: ''

    @view = new ChefSteps.Views.ProfileHeader(model: @fake_user, el: '.profile-info')

  describe "#render", ->
    beforeEach ->
      spyOn(@view, 'renderTemplate').andReturn('rendered template')
      spyOn(@view.$el, 'html')
      @view.render()

    it "sets the content to the renderTemplate", ->
      expect(@view.renderTemplate).toHaveBeenCalled()
      expect(@view.$el.html).toHaveBeenCalledWith('rendered template')


  describe "#extendTemplateJSON", ->
    describe "with a valid model", ->
      it "adds the profile_url", ->
        result = @view.extendTemplateJSON({})
        expect(result['profile_url']).toEqual('some user url')

    describe 'without a valid model', ->
      it "does nothing", ->
        @view.model = null
        result = @view.extendTemplateJSON({})
        expect(result).toEqual({})

describe "ChefSteps.Views.ProfileHeader", ->
  describe "#initialize", ->
    describe "with a valid model", ->
      beforeEach ->
        @fake_user = jasmine.createSpyObj('fake user', ['bind'])
        @view = new ChefSteps.Views.ProfileHeader(model: @fake_user)

      it "binds to model change event and renders", ->
        expect(@fake_user.bind).toHaveBeenCalledWith('change', @view.render)

      it "uses the logged in template", ->
        expect(@view.templateName).toEqual('profile_header_logged_in')


    describe "without a valid model", ->
      beforeEach ->
        @view = new ChefSteps.Views.ProfileHeader()

      it "uses the logged out template", ->
        expect(@view.templateName).toEqual('profile_header_logged_out')

