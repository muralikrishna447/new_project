describe 'ChefSteps.BaseRouter', ->
  beforeEach ->
    @fake_crossroads = jasmine.createSpyObj('fake crossroads instance', ['addRoute', 'parse'])
    spyOn(crossroads, 'create').andReturn(@fake_crossroads)
    @router = new ChefSteps.BaseRouter()

  describe "#constructor", ->
    it "creates a new instance of crossroads", ->
      expect(crossroads.create).toHaveBeenCalled()
      expect(@router.crossroads).toEqual(@fake_crossroads)

  describe "#initializeRoutes", ->
    beforeEach ->
      @router.routes =
        foo: 'bar'
      @router.bar = () -> 'stuff'
      @router.initializeRoutes()

    it "addsRoute for each route under the routes hash" , ->
      expect(@fake_crossroads.addRoute).toHaveBeenCalledWith('foo', @router.bar)

  describe "#parse", ->
    beforeEach ->
      @router.parse('some hash')

    it "has crossroads parse the hash", ->
      expect(@router.crossroads.parse).toHaveBeenCalledWith('some hash')

