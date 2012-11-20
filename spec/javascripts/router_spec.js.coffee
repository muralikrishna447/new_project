describe 'ChefSteps.Router', ->
  beforeEach ->
    @fake_crossroads = jasmine.createSpyObj('fake crossroads instance', ['addRoute', 'parse'])
    spyOn(crossroads, 'create').andReturn(@fake_crossroads)
    @fake_user = jasmine.createSpy('fake user')
    @router = new ChefSteps.Router(currentUser: @fake_user)

  describe "#constructor", ->
    it "sets the current user", ->
      expect(@router.currentUser).toEqual(@fake_user)

    it "creates a new instance of crossroads", ->
      expect(crossroads.create).toHaveBeenCalled()
      expect(@router.crossroads).toEqual(@fake_crossroads)

  describe "routes", ->
    it "defines route and callback", ->
      expect(@router.routes).toEqual(
        "/profiles/{id}": "showProfile"
      )

  describe "#initializeRoutes", ->
    beforeEach ->
      @router.initializeRoutes()

    it "addsRoute for each route under the routes hash" , ->
      expect(@fake_crossroads.addRoute).toHaveBeenCalledWith('/profiles/{id}', @router.showProfile)

  describe "#parse", ->
    beforeEach ->
      @router.parse('some hash')

    it "has crossroads parse the hash", ->
      expect(@router.crossroads.parse).toHaveBeenCalledWith('some hash')

