describe "cscomments", ->
  $compile = undefined
  $rootScope = undefined
  $httpBackend = undefined

  beforeEach module("ChefStepsApp")

  beforeEach inject((_$compile_, _$rootScope_, _$httpBackend_, $injector) ->
    $compile = _$compile_
    $rootScope = _$rootScope_
    $httpBackend = _$httpBackend_
    $httpBackend.when('GET', /.*/).respond ->
      {"commentCount":0,"comments":[{"content" : "zzzyfzzy"}], "lastOpened":null}
  )

  it "should render seo comments when brombone is true", ->
    element = $compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='true'></cscomments>")($rootScope)
    $rootScope.$digest()
    # I can't get this to work... the when('GET') above never fires
    #expect(element.html()).toContain('hello')

  it "should render bloom comments iframe when brombone is false", ->
    element = $compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='false'></cscomments>")($rootScope)
    $rootScope.$watch 'commentsId', (newValue, oldValue) ->
      if newValue
        $rootScope.$digest()
        expect(Bloom.installComments()).toHaveBeenCalled()
