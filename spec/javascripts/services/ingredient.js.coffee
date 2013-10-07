describe 'Ingredients', ->
  resource = null
  httpBackend = null
  ingredient = null
  response =
    [
      {
        "density":"67.628"
        "for_sale":false
        "id":2
        "product_url":null
        "sub_activity_id":null
        "title":"Salt, Kosher"
        "activities":[{"id":1,"title":"Salt encrusted fish"}]
        "steps":[]
      }
    ]

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($resource, $httpBackend, Ingredient) ->
    # create a scope object for us to use.
    resource = $resource
    httpBackend = $httpBackend
    ingredient = Ingredient

    # now run that scope through the controller function,
    # injecting any services or other injectables we need.
  ));


  describe "get list", ->
    it 'should gather a list of json', ->
      httpBackend.expectGET('/ingredients/').respond(response)
      i = ingredient.$get
      expect(i).toBe(1)
