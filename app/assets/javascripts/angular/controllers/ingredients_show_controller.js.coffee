angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService) ->

  # There are better ways of getting the id, but I was running into some hassles
  # because of our odd way of not being a single page app, and didn't want to take time
  # to chase them down right now.
  Ingredient = $resource( "/ingredients/:id/get_as_json",
                          id:  $('body').data("ingredient-id"),
                          {
                            update: {method: "PUT"}
                          }
                        )


  $scope.ingredient = Ingredient.get({})

  $scope.usedInChefStepsActivities = ->
    _.where($scope.ingredient.activities, {creator: null})

  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

]
