@app.controller 'IngredientsGalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Ingredient", "IngredientMethods", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Ingredient, IngredientMethods) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resource = Ingredient
  $scope.objectMethods = IngredientMethods

  $scope.placeHolderImage = ->
    IngredientMethods.placeHolderImage()

  $scope.sortChoices = ["title", "density"]
  $scope.imageChoices = ["any", "withImage", "noImage"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "relevance")

  $scope.defaultFilters = {
    detailed: "false" # speeds up query
    image: "withImage"
    sort: "title"
  }
  $scope.filters = angular.extend({}, $scope.defaultFilters)


  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "title"
    page: 3
  }

  $scope.getFooterRightContents = (activity) ->
    ""

  # Initialize the view
  $scope.clearAndLoad()
]



