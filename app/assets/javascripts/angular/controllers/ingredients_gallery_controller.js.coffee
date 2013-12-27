@app.controller 'IngredientsGalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Ingredient", "IngredientMethods", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Ingredient, IngredientMethods) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resource = Ingredient
  $scope.objectMethods = IngredientMethods

  $scope.placeHolderImage = ->
    IngredientMethods.placeHolderImage()

  $scope.sortChoices = ["name", "added", "edited", "relevance"]
  $scope.imageChoices = ["Any", "With Image", "No Image"]
  $scope.editLevelChoices = ["Any", "Not Started", "Started", "Well Edited"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "relevance")
  $scope.purchaseableChoices = ["Any", "With Purchase Link", "No Purchase Link"]

  $scope.defaultFilters = {
    detailed: "false" # speeds up query
    image: "With Image"
    sort: "name"
  }
  $scope.filters = angular.extend({}, $scope.defaultFilters)


  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "title"
    image: "With Image"
  }

  $scope.getFooterRightContents = (activity) ->
    ""

  # Initialize the view
  $scope.clearAndLoad()
]



