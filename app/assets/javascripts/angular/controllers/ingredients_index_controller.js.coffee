angular.module('ChefStepsApp').controller 'IngredientsIndexController', ["$scope", "$timeout", "$http", "$filter", "limitToFilter",  ($scope, $timeout, $http, $filter, limitToFilter) ->

  $scope.searchString = ""

  $scope.urlAsNiceText = (url) ->
    result = "Link"
    return "amazon.com" if url.indexOf("amzn") != -1
    matches = url.match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i);
    if matches && matches[1]
      result = matches[1]
      result = result.replace('www.', '')
    result

  $scope.updateFilter = ->
    $scope.displayIngredients = $filter("orderBy")($scope.ingredients, "title")
    if ! $scope.includeRecipes
      $scope.displayIngredients = _.reject($scope.displayIngredients, (x) -> x.sub_activity_id?)

  $scope.findIngredients = (term) ->
    $http.get("/ingredients.json?q=" + encodeURIComponent(term || "")).then (response) ->
      # Avoid race condition with results coming in out of order
      if term == $scope.searchString
        $scope.ingredients = _.reject(response.data, (x) -> x.title == "")
        $scope.updateFilter()

  $scope.$watch 'searchString', (newValue) ->
    $scope.findIngredients(newValue)

  $scope.$watch 'includeRecipes', ->
    $scope.updateFilter()


#  # watch for changes of parameters
#  $scope.$watch "tableParams", ((params) ->
#
#    # use build-in angular filter
#    $scope.displayIngredients = (if params.sorting then $filter("orderBy")($scope.ingredients, params.orderBy()) else $scope.ingredients)
#
#  ), true



]
