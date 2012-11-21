describe 'ChefSteps.AppRouter', ->
  beforeEach ->
    @fake_user = jasmine.createSpy('fake user')
    @router = new ChefSteps.AppRouter(currentUser: @fake_user)

  describe "#initialize", ->
    it "sets the current user", ->
      expect(@router.currentUser).toEqual(@fake_user)

  describe "routes", ->
    it "defines route and callback", ->
      expect(@router.routes).toEqual(
        "/profiles/{id}": "showProfile"
      )

  describe "#loadHeader", ->
    beforeEach ->
      @fake_header = jasmine.createSpyObj('fake header', ['render'])
      spyOn(ChefSteps, 'new').andReturn(@fake_header)
      @router.loadHeader()

    it "instantiates the profile header view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ProfileHeader, model: @router.currentUser)

    it "renders on the header view", ->
      expect(@fake_header.render).toHaveBeenCalled()

