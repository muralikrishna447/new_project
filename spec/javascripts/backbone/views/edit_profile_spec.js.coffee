describe 'ChefSteps.Views.EditProfile', ->
  beforeEach ->
    loadFixtures('profile')
    @fake_user = jasmine.createSpyObj('fake user', ['save', 'formKeys'])
    @fake_user.formKeys = ['name', 'location', 'website', 'quote']
    @fake_user.radioKeys = ['chef_type']
    @view = new ChefSteps.Views.EditProfile(el: '.edit-user-profile', model: @fake_user )

  describe "#getProfileValues", ->
    it "returns an object containing the profile values", ->
      profileValues =
        name: 'test name'
        location: 'san francisco'
        website: 'www.chefsteps.com'
        quote: 'my quote'
        chef_type: 'noob'
      expect(@view.getProfileValues()).toEqual(profileValues)

  describe "#show", ->
    it "shows the view ", ->
      @view.$el.hide()
      @view.show()
      expect(@view.$el).toBeVisible()

  describe "#hide", ->
    it "hides the view ", ->
      @view.$el.show()
      @view.hide()
      expect(@view.$el).toBeHidden()

