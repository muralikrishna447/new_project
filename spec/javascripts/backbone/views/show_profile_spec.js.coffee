describe 'ChefSteps.Views.ShowProfile', ->
  beforeEach ->
    loadFixtures('profile')
    @fake_user = jasmine.createSpyObj('fake user', ['bind'])
    @fake_user.attributes =
      name: 'foo bar name'
      location: 'Mars'
      website: 'www.stuff.com'
      quote: 'something deep and meaningful'

    @view = new ChefSteps.Views.ShowProfile(el: '.user-profile-bio', model: @fake_user )

  describe "#initialize", ->
    it "binds to model change event and updates values", ->
      expect(@fake_user.bind).toHaveBeenCalledWith('change', @view.updateValues)

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


  describe "#checkEmptyValues ", ->
    beforeEach ->
      $("[data-attribute=profile-location]", @view.$el).text('')
      @view.checkEmptyValues()

    it "hides empty fields", ->
      expect($("[data-attribute=profile-location]", @view.$el).parent()).toHaveClass('invisible')

