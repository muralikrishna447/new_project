angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', 'csEditableHeroMediaService', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService, csEditableHeroMediaService) ->

  $scope.heroMedia = csEditableHeroMediaService

  $scope.editMode = false

  # There are better ways of getting the id, but I was running into some hassles
  # because of our odd way of not being a single page app, and didn't want to take time
  # to chase them down right now.
  Ingredient = $resource( "/ingredients/:id/as_json",
                          id:  $('body').data("ingredient-id"),
                          {
                            update: {url: "/ingredients/:id", method: "PUT"}
                          }
                        )


  $scope.ingredient = Ingredient.get({}, ->
    if ! $scope.ingredient.text_fields
      $scope.ingredient.text_fields =
        [
          { 
            title: "Description"
            contents: "Oh I love me some stuff"
          },
          { 
            title: "History"
            contents: "Never heard of it"
          }
        ]
  )

    # Overall edit mode
  $scope.startEditMode = ->
    if ! $scope.editMode
      $scope.editMode = true
      $scope.showHeroVisualEdit = false

  $scope.endEditMode = ->
    $scope.ingredient.$update(
      {},
      ((response) ->
        console.log "INGREDIENT SAVE WIN"
      ),

      ((error) ->
        console.log "INGREDIENT SAVE ERRORS: " + JSON.stringify(error)
        _.each(error.data.errors, (e) -> $scope.addAlert({message: e})))
    )
    $scope.editMode = false

  $scope.toggleEditMode = ->
    if $scope.editMode
      $scope.endEditMode()
    else 
      $scope.startEditMode()


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
