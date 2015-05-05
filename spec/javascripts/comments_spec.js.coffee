describe "cscomments", ->
  scope = null
  $_compile = null
  $_rootScope = null
  $_httpBackend = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  beforeEach angular.mock.inject(($compile, $rootScope, $httpBackend) ->
    $_compile = $compile
    $_rootScope = $rootScope
    $_httpBackend = $httpBackend

    scope = $rootScope.$new()
    $httpBackend.whenGET(/.*/).respond ->
      [200, {"commentCount":0,"comments":[{"content" : "zzzyfzzy"}], "lastOpened":null}]
  )

  afterEach ->
    $_httpBackend.verifyNoOutstandingExpectation();
    $_httpBackend.verifyNoOutstandingRequest();


  it "should render seo comments when brombone is true", ->
    element = $_compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='true'></cscomments>")(scope)
    $_httpBackend.flush()
    scope.$digest()
    console.log("*** expecty")
    expect(element.html()).toContain('zzzyfzzy')

  it "should render bloom comments iframe when brombone is false", ->
    element = $_compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='false'></cscomments>")($_rootScope)
    $_rootScope.$watch 'commentsId', (newValue, oldValue) ->
      if newValue
        $_rootScope.$digest()
        expect(Bloom.installComments()).toHaveBeenCalled()
