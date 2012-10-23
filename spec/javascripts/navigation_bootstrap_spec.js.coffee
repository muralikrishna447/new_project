describe "Navigation Bootstrap", ->
  beforeEach ->
    @fake_target = 'test-target'
    @bootstrap = new ChefSteps.NavigationBootstrap(@fake_target)

  describe "#constructor", ->
    it "sets the header target", ->
      expect(@bootstrap.headerTarget).toEqual(@fake_target)

  describe "#loadCSS", ->
    it "links to global_navigation.css", ->
      expect(@bootstrap.cssLink).toEqual("<link rel=stylesheet type='text/css' href='http://delve.dev/assets/global_navigation.css' />")

  describe "#getHeader", ->
    beforeEach ->
      spyOn($, "ajax").andCallFake (options) ->
        options.beforeSend()
        options.success()
      spyOn(@bootstrap, 'loadHeader')
      spyOn(@bootstrap, 'allowOrigin')
      @bootstrap.getHeader()

    it "requests the global navigation", ->
      expect($.ajax.mostRecentCall.args[0].url).toEqual("http://delve.dev/global-navigation")

    it "loads the header on success", ->
      expect(@bootstrap.loadHeader).toHaveBeenCalled()

    it "sets the request header", ->
      expect(@bootstrap.allowOrigin).toHaveBeenCalled()

  describe "#bootstrap", ->
    beforeEach ->
      spyOn(@bootstrap, 'loadCSS')
      spyOn(@bootstrap, 'getHeader')
      @bootstrap.bootstrap()

    it "loads the global navigation css", ->
      expect(@bootstrap.loadCSS).toHaveBeenCalled()

    it "gets the header html", ->
      expect(@bootstrap.getHeader).toHaveBeenCalled()

