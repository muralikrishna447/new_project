describe "Navigation Bootstrap", ->
  beforeEach ->
    @ajaxSpy = sinon.spy(jQuery, 'ajax')
    @testHeader = 'foo-header'
    $("<div id=#{@testHeader}></div>").appendTo('body')
    NavigationBootstrap("##{@testHeader}")

  afterEach ->
    jQuery.ajax.restore()

  describe "asynchronously get header", ->
    it "requests the template asynchronously", ->
      expect(jQuery.ajax.calledOnce).toBeTruthy()

    it "requests global-navigation", ->
      expect(jQuery.ajax.getCall(0).args[0].url).toEqual('http://delve.dev/global-navigation')

  describe "displays header", ->
    it "replaces the html of the target specified", ->
      expect($("##{@testHeader}").html()).toEqual('some template')

