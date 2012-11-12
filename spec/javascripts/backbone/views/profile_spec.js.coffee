describe 'ChefSteps.Views.Profile', ->
  beforeEach ->
    loadFixtures('profile')
    @fake_user = jasmine.createSpyObj('fake user', ['attributes'])
    @fake_user.attributes =
      name: 'foo bar name'
      location: 'Mars'
      website: 'www.stuff.com'
      quote: 'something deep and meaningful'
    @view = new ChefSteps.Views.Profile(el: '.user-profile-bio', model: @fake_user )

  describe "#updateValues", ->
    beforeEach ->
      @view.updateValues()

    it "updates name", ->
      expect($("[data-attribute=profile-name]", @view.$el).text()).toEqual('foo bar name')

    it "updates location", ->
      expect($("[data-attribute=profile-location]", @view.$el).text()).toEqual('Mars')

    it "updates website", ->
      expect($("[data-attribute=profile-website]", @view.$el).text()).toEqual('www.stuff.com')

    it "updates quote", ->
      expect($("[data-attribute=profile-quote]", @view.$el).text()).toEqual('something deep and meaningful')



