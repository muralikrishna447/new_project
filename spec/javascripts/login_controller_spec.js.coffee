describe "LoginController", ->
  scope = null
  ctrl = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($rootScope, _$http_backend_) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()
    # we're just declaring the httpBackend here, we're not setting up expectations or when's - they change on each test
    scope.httpBackend = _$httpBackend_
  ));

  afterEach ->
    scope.$digest()
    scope.httpBackend.verifyNoOutstandingExpectation()
    scope.httpBackend.verifyNoOutstandingRequest()

  describe "#login", ->
    it 'should send a login request', ->
      scope.httpBackend.expect(
        'POST'
        '/users/sign_in.json'
        '{"user":{"email":"test@example.com","password":"apassword"}}'
      ).respond(201, '')

      scope.httpBackend.flush();

