@app.controller 'IngredientsGalleryController', ['$scope', 'Ingredient', '$controller', ($scope, Ingredient, $controller) ->

  $scope.context            = "Ingredient"
  $scope.sortChoices        = [ "Relevance", "Name", "Recently Added", "Recently Edited", 
                            "Most Edited", "Most Used"]
  $scope.imageChoices       = ["Any", "With Image", "No Image"]
  $scope.editLevelChoices   = ["Any", "Not Started", "Started", "Well Edited"]
  $scope.suggestedSearches  = ['Modernist', 'Meat', 'Cheese', 'Seafood', 'Vegetable', 'Condiment', 'Fruit', 'Gluten Free']

  $scope.defaultFilters = {
    sort: "Name"
    image: "With Image"
  }

  $scope.noResultsQuery = 
    sort: "Most Used"
    image: "With Image"

  $scope.adjustParams = (params) ->
    params['detailed'] = false
    params

  $scope.doQuery = (params) ->
    Ingredient.index_for_gallery(params)

  $controller('GalleryBaseController', {$scope: $scope});

  $scope.addAndEditNewIngredient = ->
    $scope.showNewIngredientModal = false
    Ingredient.create(
      {title: $scope.newIngredientName}, 
      (newIng) ->
        $scope.newIngredientName = ""
        window.open("/ingredients/#{newIng.slug}?edit=true", '_blank')
      (error) ->
        _.each(error.data.errors, (e) -> csAlertService.addAlert({message: e}, $timeout))
    )  

  $scope.possibleIngredientMatches = []

  $scope.$watch 'newIngredientName', (newVal) -> 
    if newVal
      $scope.newIngSpinner = true
      Ingredient.query {limit: 15, include_sub_activities: false, detailed: false, search_title: newVal}, (response) ->
        $scope.newIngSpinner = false
        $scope.possibleIngredientMatches = response
    else
      $scope.possibleIngredientMatches = []

  $scope.exactMatchNewIngredient = ->
    _.find($scope.possibleIngredientMatches, (x) -> x.title.toLowerCase() == $scope.newIngredientName?.toLowerCase())
]



