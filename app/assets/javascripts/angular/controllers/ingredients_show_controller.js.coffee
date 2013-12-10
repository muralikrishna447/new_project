angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', 'csEditableHeroMediaService', 'csAlertService', 'csDensityService', 'localStorageService', 'csAuthentication', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService, csEditableHeroMediaService, csAlertService, csDensityService, localStorageService, csAuthentication) ->

  $scope.heroMedia = csEditableHeroMediaService
  $scope.alertService = csAlertService
  $scope.densityService = csDensityService
  $scope.csAuthentication = csAuthentication

  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

  $scope.editMode = false

  $scope.addEditModeClass = ->
    if $scope.editMode then "edit-mode" else "show-mode"

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

  $timeout ->
    if csAuthentication.loggedIn() && ! localStorageService.get("seenEditIngredientWelcome6")
      csAlertService.addAlert({type: "info", message: "Welcome to ingredient pages! You are invited to contribute your knowledge to the community. Click the edit button to get started."}, $timeout) 
      localStorageService.add("seenEditIngredientWelcome6", true)

  # Overall edit mode
  $scope.startEditMode = ->
    if ! $scope.editMode
      $scope.editMode = true
      $scope.showHeroVisualEdit = false
      $scope.ingredient.text_fields ||= {}
      $scope.backupIngredient = jQuery.extend(true, {}, $scope.ingredient)
      $scope.showHelpModal = true if ! localStorageService.get("seenEditIngredientsHelp")
      localStorageService.add("seenEditIngredientsHelp", true)

  $scope.endEditMode = ->
    if JSON.stringify($scope.ingredient) == JSON.stringify($scope.backupIngredient)
      console.log "INGREDIENT NO CHANGES"
    else
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
    _.where($scope.ingredient.chefsteps_activities, {published: true})[0..5]

  $scope.frequentlyUsedWith = ->
    _.filter($scope.ingredient.frequently_used_with, (x) -> (parseInt(x.id) != $scope.ingredient.id) && (parseInt(x.count) > 1))

  $scope.showStartEditTip = ->
    (! $scope.editMode) && ($scope.heroMedia.heroDisplayType() == "none") && (_.isEmpty($scope.ingredient.text_fields))

  $scope.finishDensityChange = (ingredient) ->
    $scope.densityService.editDensity(null)

  $scope.$watch('ingredient.image_id', (old_val, new_val) ->
    $scope.showHeroVisualEdit = false if old_val != new_val
  )

   # Tags - TODO: needs to share code with activity_controller!!
  $scope.tagsSelect2 =

    placeholder: "Add some tags"
    tags: true
    multiple: true
    width: "100%"

    ajax:
      url: "/ingredients/all_tags.json",
      data: (term, page) ->
        return {
          q: term
        }

      results: (data, page) ->
        return {results: data}

    formatResult: (tag) ->
      tag.name

    formatSelection: (tag) ->
      tag.name

    createSearchChoice: (term, data) ->
      id: term
      name: term

    initSelection: (element, callback) ->
      callback($scope.activity.tags)

  # Social share callbacks
  $scope.socialURL = ->
    "http://chefsteps.com/ingredients/" + $scope.ingredient?.slug

  $scope.socialTitle = ->
    $scope.ingredient.title

  $scope.socialMediaItem = ->
    return csEditableHeroMediaService.heroImageURL(800) if csEditableHeroMediaService.hasHeroImage()
    null

  $scope.cs140Message = ->
    $scope.ingredient.title

  $scope.tweetMessage = ->
    "Check the info for"

  $scope.emailSubject = ->
    "I thought you might like " + $scope.socialTitle()

  $scope.emailBody = ->
    "Hey, I thought you might like " + $scope.socialTitle() + " at ChefSteps.com. Here's the link: " + $scope.socialURL()

  $scope.reportProblem = ->
    window.open("mailto:info@chefsteps.com?subject=Problem with \'#{encodeURIComponent($scope.ingredient.title)}\ ingredient page'&body=[Please describe the problem].#{encodeURIComponent("\n\n")}Problem page: #{encodeURIComponent($scope.socialURL())}")

  $scope.lastEditingUser = ->
    $scope.ingredient.editing_users?[0]

  $scope.getEditingUsers = ->
    return null if ! $scope.ingredient?.editing_users?
    _.filter($scope.ingredient.editing_users, (x) -> x.role != 'admin')

]
