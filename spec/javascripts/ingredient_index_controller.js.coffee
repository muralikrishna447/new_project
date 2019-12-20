describe "IngredientsIndexController", ->
  scope = null
  ctrl = null

  # A mocked version of our service, someService
  # we're mocking this so we have total control and we're
  # testing this in isolation from any calls it might
  # be making.
  urlService =
    updateQueryStringParameter: (uri, key, value) ->
      "amazon.com?tag=chefsteps02-20"
    fixAffiliateLink: (i) ->
      "http://www.amazon.com/gp/product/amazon.com?tag=chefsteps02-20"
    urlAsNiceText: (url) ->
      "google.com"
    sortByNiceUrl: (a,b) ->
      0

  alertService =
    addAlert: (alert, $timeout) ->
      true

  # Ingredient = angular.mock.module('ChefStepsApp').factory 'Ingredient', ($resource) ->
  #   return $resource(Ingredient)


  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($rootScope, $controller) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()

    # now run that scope through the controller function,
    # injecting any services or other injectables we need.
    ctrl = $controller 'IngredientsIndexController',
      $scope: scope
      # alertService: alertService
      # Ingredient: Ingredient
      csUrlService: urlService
  ));

  describe "#displayDensity", ->
    it 'should display the density rounded', ->
      expect(scope.densityService.displayDensity(1.22222222222222)).toEqual('1.2')
    it 'should return Set... if no density', ->
      expect(scope.densityService.displayDensity(null)).toEqual("Set...")

  describe "#displayDensityNoSet", ->
    it 'should display the density when it is set', ->
      expect(scope.densityService.displayDensityNoSet(1)).toEqual('1')
    it 'should return Set... if no density', ->
      expect(scope.densityService.displayDensityNoSet(null)).toEqual("")

  describe "#urlAsNiceText", ->
    it "should return the value from urlService.urlAsNiceText", ->
      expect(scope.urlAsNiceText("blahblah")).toEqual("google.com")

  # describe "#ingredientChanged", ->
  #   it "should update an ingredient", ->

  # describe "#canMerge", ->
  #   it "should return false if selected items is less than 2", ->




