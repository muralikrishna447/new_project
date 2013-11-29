angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', 'csEditableHeroMediaService', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService, csEditableHeroMediaService) ->

  $scope.heroMedia = csEditableHeroMediaService

  $scope.editMode = true

  # There are better ways of getting the id, but I was running into some hassles
  # because of our odd way of not being a single page app, and didn't want to take time
  # to chase them down right now.
  Ingredient = $resource( "/ingredients/:id/get_as_json",
                          id:  $('body').data("ingredient-id"),
                          {
                            update: {method: "PUT"}
                          }
                        )


  $scope.ingredient = Ingredient.get({}, ->
    console.log JSON.stringify($scope.ingredient)
  )

  $scope.getObject = ->
    $scope.ingredient
  csEditableHeroMediaService.getObject = $scope.getObject

  $scope.usedInChefStepsActivities = ->
    _.where($scope.ingredient.activities, {creator: null})[0..5]

  $scope.frequentlyUsedWith = ->
    _.filter($scope.ingredient.frequently_used_with, (x) -> (parseInt(x.id) != $scope.ingredient.id) && (parseInt(x.count) > 1))

  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)
]
