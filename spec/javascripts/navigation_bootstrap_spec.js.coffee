describe "Navigation Bootstrap", ->
  beforeEach ->
    @targetSpy = jasmine.createSpyObj('target spy', ['html'])
    spyOn($, "ajax").andCallThrough()
    NavigationBootstrap(@targetSpy)

  describe "asynchronously get header", ->
    it "requests the template asynchronously", ->
      expect($.ajax.mostRecentCall.args[0]["url"]).toEqual('http://delve.dev/global-navigation')

  # describe "displays header", ->
  #   it "replaces the html of the target specified", ->
  #     expect(@targetSpy.html).toHaveBeenCalled()

  #   it "adds a link to global_navigation.css to head", ->
  #     expect($("link[href='http://delve.dev/assets/global_navigation.css']").length).toEqual(1)

