describe 'ChefSteps.Router', ->
  beforeEach ->
    @fake_crossroads = jasmine.createSpyObj('fake crossroads instance', ['addRoute', 'parse'])
    spyOn(crossroads, 'create').andReturn(@fake_crossroads)
    @fake_user = jasmine.createSpy('fake user')
    @router = new ChefSteps.Router(currentUser: @fake_user)
    @router.routes = 'route': 'function'

  describe "#constructor", ->
    it "sets the current user", ->
      expect(@router.currentUser).toEqual(@fake_user)

    it "creates a new instance of crossroads", ->
      expect(crossroads.create).toHaveBeenCalled()
      expect(@router.crossroads).toEqual(@fake_crossroads)

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

  describe "#loadHeader", ->
    beforeEach ->
      @fake_header = jasmine.createSpyObj('fake header', ['render'])
      spyOn(ChefSteps, 'new').andReturn(@fake_header)
      @router.loadHeader()

    it "instantiates the profile header view", ->
      expect(ChefSteps.new).toHaveBeenCalledWith(ChefSteps.Views.ProfileHeader, model: @router.currentUser)

    it "renders on the header view", ->
      expect(@fake_header.render).toHaveBeenCalled()

