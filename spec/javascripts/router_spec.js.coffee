describe 'ChefSteps.Router', ->
  beforeEach ->
    @fake_user = jasmine.createSpy('fake user')
    @router = new ChefSteps.Router(currentUser: @fake_user)

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

