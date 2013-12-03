angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', 'csEditableHeroMediaService', 'csAlertService', 'csDensityService', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService, csEditableHeroMediaService, csAlertService, csDensityService) ->

  $scope.heroMedia = csEditableHeroMediaService
  $scope.alertService = csAlertService
  $scope.densityService = csDensityService

  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

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

  $scope.textFieldOptions = ["description", "alternative names", "culinary uses", "substitutions", "purchasing tips", "storage", "production", "seasonality", "history"]

  $scope.ingredient = Ingredient.get({}, -> 
  )

  # Overall edit mode
  $scope.startEditMode = ->
    if ! $scope.editMode
      $scope.editMode = true
      $scope.showHeroVisualEdit = false
      $scope.ingredient.text_fields ||= {}
      $scope.backupIngredient = jQuery.extend(true, {}, $scope.ingredient)

  $scope.endEditMode = ->
    $scope.ingredient.$update(
      {},
      ((response) ->
        console.log "INGREDIENT SAVE WIN"
      ),

      ((error) ->
        console.log "INGREDIENT SAVE ERRORS: " + JSON.stringify(error)
        _.each(error.data.errors, (e) -> csAlertService.addAlert({message: e}, $timeout)))
    )
    $scope.editMode = false

  $scope.cancelEditMode = ->
    $scope.ingredient = jQuery.extend(true, {}, $scope.backupIngredient)
    $scope.editMode = false

  $scope.addUndo = ->
    true

  $scope.getObject = ->
    $scope.ingredient
  csEditableHeroMediaService.getObject = $scope.getObject

  $scope.usedInChefStepsActivities = ->
    _.where($scope.ingredient.activities, {creator: null, published: true})[0..5]

  $scope.frequentlyUsedWith = ->
    _.filter($scope.ingredient.frequently_used_with, (x) -> (parseInt(x.id) != $scope.ingredient.id) && (parseInt(x.count) > 1))

  $scope.showStartEditTip = ->
    (! $scope.editMode) && ($scope.heroMedia.heroDisplayType() == "none") && (_.isEmpty($scope.ingredient.text_fields))

  $scope.finishDensityChange = (ingredient) ->
    $scope.densityService.editDensity(null)

  $scope.$watch('ingredient.image_id', (old_val, new_val) ->
    $scope.showHeroVisualEdit = false if old_val != new_val
  )
]
