describe "cscomments", ->
  scope = undefined
  $compile = undefined
  $rootScope = undefined
  $httpBackend = undefined

  beforeEach module("ChefStepsApp")
  beforeEach inject((_$compile_, _$rootScope_, _$httpBackend_) ->
    $compile = _$compile_
    $rootScope = _$rootScope_
    $httpBackend = _$httpBackend_
    scope = $rootScope.$new()
    $httpBackend.when('GET', 'http://production-bloom.herokuapp.com/discussion/activity_2434/comments?apiKey=xchefsteps').respond('[{"content":"hello"}]')
  )

  it "should render comments when brombone is true", ->
    element = $compile("<cscomments comments-type='activity' comments-id='2434' seo-bot='true'></cscomments>")($rootScope)
    scope.commentsId = '2434'
    $rootScope.$digest()
    expect(scope.commentsId).toBe('2434')
    expect(scope).toBe(true)
    expect(element).toContain('hello')
