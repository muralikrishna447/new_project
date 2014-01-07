@app.controller 'IngredientsGalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Ingredient", "IngredientMethods", "$http", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Ingredient, IngredientMethods, $http) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Ingredient"
  $scope.resource = Ingredient
  $scope.objectMethods = IngredientMethods

  $scope.placeHolderImage = ->
    IngredientMethods.placeHolderImage()

  $scope.sortChoices = ["Name", "Recently Added", "Recently Edited", "Most Edited", "Most Used", "Relevance"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "Relevance")
  $scope.imageChoices = ["Any", "With Image", "No Image"]
  $scope.editLevelChoices = ["Any", "Not Started", "Started", "Well Edited"]
  $scope.purchaseableChoices = ["Any", "With Purchase Link", "No Purchase Link"]

  $scope.defaultFilters = {
    edit_level: "Any"
    image: "Any"
    sort: "Name"
  }

  # This is for an odd little special case. We want "with image" to clearly be an applied filter (so it gets the
  # litte "x" thingy) which it won't be if it is in defaultFilters. But we also want it to be applied by 
  # default when you hit the root route for this page. This can go away when we go to a new filter UI that is
  # open by default.
  $scope.setAnyNonDefaultDefaults = ->
    $scope.filters["image"] = "With Image"

  # Results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "Name"
    image: "With Image"
  }

  $scope.maybeEditLink = (ingredient) ->
    if  ! ingredient.image_id
      return "<a href='/ingredients/#{ingredient.slug}?edit=true' target='_blank'>Edit Ingredient...</a>"

  $scope.addAndEditNewIngredient = ->
    $scope.showNewIngredientModal = false

  $scope.possibleIngredientMatches = []

  $scope.$watch 'newIngredientName', (newVal) -> 
    if newVal
      $scope.newIngSpinner = true
      $http.get("/ingredients.json?limit=15&include_sub_activities=false&detailed=false&search_title=" + newVal).then (response) ->
        $scope.newIngSpinner = false
        $scope.possibleIngredientMatches = response.data
    else
      $scope.possibleIngredientMatches = []

  $scope.exactMatchNewIngredient = ->
    _.find($scope.possibleIngredientMatches, (x) -> x.title.toLowerCase() == $scope.newIngredientName?.toLowerCase())
]



