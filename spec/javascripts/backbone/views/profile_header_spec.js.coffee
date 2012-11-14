describe "ChefSteps.Views.ProfileHeader", ->
  beforeEach ->
    loadFixtures('header')
    @fake_user = jasmine.createSpyObj('fake user', ['bind'])
    @fake_user.attributes =
      name: 'foo bar name'
      location: ''
    @view = new ChefSteps.Views.ProfileHeader(model: @fake_user, el: '.profile-info')

  describe "#initialize", ->
    it "binds to model change event and updates values", ->
      expect(@fake_user.bind).toHaveBeenCalledWith('change', @view.updateValues)

  describe "#updateValues", ->
    beforeEach ->
      @view.updateValues()

    it "updates name", ->
      expect($(".name", @view.$el).text()).toEqual('foo bar name')

    it "updates location", ->
      expect($(".location", @view.$el).text()).toEqual('')

