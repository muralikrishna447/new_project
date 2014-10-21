describe "cscomments", ->
  $compile = undefined
  $rootScope = undefined
  $httpBackend = undefined

  beforeEach module("ChefStepsApp")

  beforeEach inject((_$compile_, _$rootScope_, _$httpBackend_, $injector) ->
    $compile = _$compile_
    $rootScope = _$rootScope_
    $httpBackend = _$httpBackend_
    $httpBackend = $injector.get('$httpBackend')
    $httpBackend.when('GET', 'http://server.usebloom.com/discussions/activity_2434/comments?apiKey=xchefsteps').respond("[{'content':'hello'}, {'content': 'sup'}]")
  )

  it "should render seo comments when brombone is true", ->
    element = $compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='true'></cscomments>")($rootScope)
    $rootScope.$digest()
    expect(element.html()).toContain('hello')

  it "should render bloom comments iframe when brombone is false", ->
    element = $compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='false'></cscomments>")($rootScope)
    $rootScope.$watch 'commentsId', (newValue, oldValue) ->
      if newValue
        $rootScope.$digest()
        expect(Bloom.installComments()).toHaveBeenCalled()