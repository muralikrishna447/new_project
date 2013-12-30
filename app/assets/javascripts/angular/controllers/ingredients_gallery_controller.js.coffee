@app.controller 'IngredientsGalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Ingredient", "IngredientMethods", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Ingredient, IngredientMethods) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Ingredient"
  $scope.resource = Ingredient
  $scope.objectMethods = IngredientMethods

  $scope.placeHolderImage = ->
    IngredientMethods.placeHolderImage()

  $scope.sortChoices = ["Name", "Recently Added", "Recently Edited", "Most Edited", "Most Used", "Relevance"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "relevance")
  $scope.imageChoices = ["Any", "With Image", "No Image"]
  $scope.editLevelChoices = ["Any", "Not Started", "Started", "Well Edited"]
  $scope.purchaseableChoices = ["Any", "With Purchase Link", "No Purchase Link"]

  $scope.defaultFilters = {
    detailed: "false" # speeds up query
    edit_level: "Any"
    image: "Any"
    sort: "Name"
  }
  $scope.filters = angular.extend({}, $scope.defaultFilters)

  # Not setting this in defaultFilters on purpose because I want it to be clear it is an applied filter
  # even though it is on when the page loads.
  $scope.filters["image"] = "With Image"

  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "Name"
    image: "With Image"
  }

  # Initialize the view
  $scope.clearAndLoad()
]



