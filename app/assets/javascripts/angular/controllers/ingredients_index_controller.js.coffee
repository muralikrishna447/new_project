angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$timeout", "$http", "$filter", "limitToFilter", "ngTableParams", ($scope, $timeout, $http, $filter, limitToFilter, ngTableParams) ->
  $scope.findIngredients = (term) ->
    $http.get("/ingredients.json?q=" + encodeURIComponent(term)).then (response) ->
      # Avoid race condition with results coming in out of order
      if term == $scope.searchString
        $scope.ingredients = limitToFilter(response.data, 100)
        $scope.tableParams.total = $scope.ingredients.length

  $scope.$watch 'searchString', (newValue) ->
    $scope.findIngredients(newValue)


  $scope.tableParams = new ngTableParams(
    page: 1 # show first page
    total:  0 # length of data
    count: 10 # count per page
    sorting:
      title: "asc" # initial sorting
  )

  # watch for changes of parameters
  $scope.$watch "tableParams", ((params) ->

    # use build-in angular filter
    orderedData = (if params.sorting then $filter("orderBy")($scope.ingredients, params.orderBy()) else $scope.ingredients)

    # slice array data on pages
    $scope.displayIngredients = orderedData.slice((params.page - 1) * params.count, params.page * params.count)
  ), true



]
