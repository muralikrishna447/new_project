describe 'ChefSteps.Router', ->
  beforeEach ->
    @fake_user = jasmine.createSpy('fake user')
    @fake_user.id = 123
    @router = new ChefSteps.Router(currentUser: @fake_user, registrationCompletionPath: 'path')

  describe "#initialize", ->
    it "sets the current user", ->
      expect(@router.currentUser).toEqual(@fake_user)

  describe "#loadHeader", ->
    beforeEach ->
      @fake_header = jasmine.createSpyObj('fake header', ['render'])
      spyOn(ChefSteps, 'new').andReturn(@fake_header)
      @router.loadHeader()

    it "instantiates the profile header view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ProfileHeader, model: @router.currentUser)

    it "renders on the header view", ->
      expect(@fake_header.render).toHaveBeenCalled()

  describe "#showProfile", ->
    beforeEach ->
      spyOn(ChefSteps.Views, 'Profile')

    it "does not create profile view if currentUser doesn't exist", ->
      @router.showProfile()
      expect(ChefSteps.Views.Profile).not.toHaveBeenCalled

    it "does not create profile view if currentUser id doesn't match id param", ->
      @router.showProfile('1')
      expect(ChefSteps.Views.Profile).not.toHaveBeenCalled

    it "creates profile view if currentUser id matches id param", ->
      @router.showProfile('123')
      expect(ChefSteps.Views.Profile).toHaveBeenCalled

