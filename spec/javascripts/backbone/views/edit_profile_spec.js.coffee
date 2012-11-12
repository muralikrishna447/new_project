describe 'ChefSteps.Views.EditProfile', ->
  beforeEach ->
    loadFixtures('profile')
    @fake_user = jasmine.createSpyObj('fake user', ['save', 'attributes'])
    @fake_user.attributes =
      name: ''
      location: ''
      website: ''
      quote: ''
    @view = new ChefSteps.Views.EditProfile(el: '.edit-user-profile', model: @fake_user )

  describe "#getProfileValues", ->
    it "returns an object containing the profile values", ->
      profileValues =
        name: 'test name'
        location: 'san francisco'
        website: 'www.chefsteps.com'
        quote: 'my quote'
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

  describe "when save is clicked", ->
    beforeEach ->
      spyOn(@view, 'getProfileValues').andReturn('foo attributes')
      spyOn(@view, 'hide')
      @view.updateModel()

    it "saves the model with the values from the inputs", ->
      expect(@fake_user.save).toHaveBeenCalledWith('foo attributes')

    it "hides the edit profile view", ->
      expect(@view.hide).toHaveBeenCalled()

