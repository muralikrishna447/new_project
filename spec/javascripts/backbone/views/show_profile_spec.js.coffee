describe 'ChefSteps.Views.ShowProfile', ->
  beforeEach ->
    loadFixtures('profile')
    @fake_user = jasmine.createSpyObj('fake user', ['bind'])
    @fake_user.attributes =
      name: 'foo bar name'
      location: ''
      website: 'www.stuff.com'
      quote: 'something deep and meaningful'
      chef_type: 'culinary_student'
    @fake_user.chefType = ->
      'Culinary Student'

    @view = new ChefSteps.Views.ShowProfile(el: '.user-profile-bio', model: @fake_user )

  describe "#initialize", ->
    it "binds to model change event and updates values", ->
      expect(@fake_user.bind).toHaveBeenCalledWith('change', @view.updateValues)

  describe "#updateValues", ->
    beforeEach ->
      @view.updateValues()

    it "updates name", ->
      expect($("[data-attribute=profile-name]", @view.$el).text()).toEqual('foo bar name')

    it "updates chef type", ->
      expect($("[data-attribute=profile-chef_type]", @view.$el).text()).toEqual('Culinary Student')

    it "updates location", ->
      expect($("[data-attribute=profile-location]", @view.$el).text()).toEqual('')

    it "updates website", ->
      expect($("[data-attribute=profile-website]", @view.$el).text()).toEqual('www.stuff.com')

    it "updates quote", ->
      expect($("[data-attribute=profile-quote]", @view.$el).text()).toEqual('something deep and meaningful')


  describe "#checkEmptyValues ", ->
    beforeEach ->
      @view.checkEmptyValues()

    it "hides empty fields", ->
      expect($("[data-attribute-invisible=profile-location]")).toHaveClass('invisible')

