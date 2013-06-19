describe "Navigation Bootstrap", ->
  beforeEach ->
    @fake_target = 'test-target'
    @bootstrap = new ChefSteps.NavigationBootstrap(@fake_target)

  describe "#constructor", ->
    it "sets the header target", ->
      expect(@bootstrap.headerTarget).toEqual(@fake_target)

  describe "#getHeader", ->
    beforeEach ->
      spyOn($, "ajax").andCallFake (options) ->
        options.success()
      spyOn(@bootstrap, 'loadHeader')
      @bootstrap.getHeader()

    it "requests the global navigation", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("http://delve.dev/global-navigation")

    it "loads the header on success", ->
      expect(@bootstrap.loadHeader).toHaveBeenCalled()

  describe "#bootstrap", ->
    beforeEach ->
      spyOn(@bootstrap, 'getHeader')
      @bootstrap.bootstrap()

    it "gets the header html", ->
      expect(@bootstrap.getHeader).toHaveBeenCalled()

