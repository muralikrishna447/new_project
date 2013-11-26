describe 'csAuthentication', ->
  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(
    angular.mock.module('ChefStepsApp')
    angular.mock.inject ($csAuthentication) ->
      csAuthentication = $csAuthentication

  )
  # now run that scope through the controller function,
  # injecting any services or other injectables we need.

  describe "current_user", ->
    it "should return the current_user", ->
      expect(csAuthentication.current_user).toBe(null)

  # describe "get list", ->
  #   it 'should gather a list of json', ->
  #     httpBackend.expectGET('/ingredients/').respond(response)
  #     i = $scope.ingredient.$get
  #     expect(i).toBe(1)
