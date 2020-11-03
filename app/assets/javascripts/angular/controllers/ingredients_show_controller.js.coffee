angular.module('ChefStepsApp').controller 'IngredientShowController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", 'csUrlService', 'csEditableHeroMediaService', 'csAlertService', 'csDensityService', 'localStorageService', 'csAuthentication', 'csTagService', '$modal', ($scope, $rootScope, $resource, $location, $http, $timeout, csUrlService, csEditableHeroMediaService, csAlertService, csDensityService, localStorageService, csAuthentication, csTagService, $modal) ->

  # This muck will go away when I do deep routing properly
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0

  $scope.heroMedia = csEditableHeroMediaService
  $scope.alertService = csAlertService
  $scope.densityService = csDensityService
  $scope.csAuthentication = csAuthentication
  $scope.csTagService = csTagService

  $scope.urlAsNiceText = (url) ->
    csUrlService.urlAsNiceText(url)

  $scope.editMode = false
  $scope.edited = false

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

  $scope.textFieldOptions = ["description", "alternative names", "culinary uses", "preparation tips", "suggested cooking times and temperatures", "substitutions", "purchasing tips", "storage", "production", "safety", "seasonality", "history", "references"]

  $scope.ingredient = Ingredient.get({}, ->
    $scope.startEditMode() if $scope.url_params?["edit"]? && csAuthentication.loggedIn()
  )

  $scope.showHeroVisual = ->
    true

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
          eventData = {'context' : 'naked', 'title' : $scope.ingredient.title, 'slug' : $scope.ingredient.slug}
          console.log "INGREDIENT SAVE WIN"
          $scope.edited = true
          $scope.showPostEditModal = true
        ),

        ((error) ->
          console.log "INGREDIENT SAVE ERRORS: " + JSON.stringify(error)
          _.each(error.data.errors, (e) -> csAlertService.addAlert({message: e}, $timeout)))
      )
    $scope.editMode = false

  $scope.cancelEditMode = ->
    $scope.ingredient = jQuery.extend(true, {}, $scope.backupIngredient)
    $scope.editMode = false

  $scope.getObject = ->
    $scope.ingredient

  csEditableHeroMediaService.getObject = $scope.getObject

  $scope.usedInChefStepsActivities = ->
    _.where($scope.ingredient.chefsteps_activities, {published: true})[0..5]

  $scope.frequentlyUsedWith = ->
    _.filter($scope.ingredient.frequently_used_with, (x) -> (parseInt(x.id) != $scope.ingredient.id) && (parseInt(x.count) > 1))

  $scope.showStubTip = ->
    (! $scope.editMode) && (_.isEmpty($scope.ingredient.text_fields))

  $scope.finishDensityChange = (ingredient) ->
    $scope.densityService.editDensity(null)

  $scope.$watch('ingredient.image_id', (old_val, new_val) ->
    $scope.showHeroVisualEdit = false if old_val != new_val
  )

  $scope.tagsSelect2 = ->
    csTagService.getSelect2Info($scope.ingredient.tags, "/ingredients/all_tags.json")

  # Social share callbacks
  $scope.socialURL = ->
    "https://www.chefsteps.com/ingredients/" + $scope.ingredient?.slug

  $scope.socialTitle = ->
    $scope.ingredient.title

  $scope.socialMediaItem = ->
    return csEditableHeroMediaService.heroImageURL(800) if csEditableHeroMediaService.hasHeroImage()
    null

  $scope.cs140Message = ->
    $scope.ingredient.title

  $scope.tweetMessage = ->
    if ! $scope.edited then "Check the info for" else "I just edited"

  $scope.emailSubject = ->
    if ! $scope.edited
      "I thought you might like " + $scope.socialTitle()
    else
      "I just edited " + $scope.socialTitle()

  $scope.emailBody = ->
    if ! $scope.edited
      "Hey, I thought you might like " + $scope.socialTitle() + " at ChefSteps.com. Here's the link: " + $scope.socialURL()
    else
      "Hey, I just edited " + $scope.socialTitle() + " at ChefSteps.com. Here's the link: " + $scope.socialURL()

  $scope.reportProblem = ->
    window.open("mailto:info@chefsteps.com?subject=Problem with \'#{encodeURIComponent($scope.ingredient.title)}\ ingredient page'&body=[Please describe the problem].#{encodeURIComponent("\n\n")}Problem page: #{encodeURIComponent($scope.socialURL())}")

  $scope.lastEditingUser = ->
    $scope.ingredient.editing_users?[0]

  $scope.getEditingUsers = ->
    return null if ! $scope.ingredient?.editing_users?
    _.filter($scope.ingredient.editing_users, (x) -> x.role != 'admin')

  $scope.showTagsModal = ->
    modalInstance = $modal.open(
      templateUrl: "ingredientTagChooserModal.html"
      backdrop: false
      keyboard: false
      windowClass: "takeover-modal"
      resolve:
        ingredient: -> $scope.ingredient
        csTagService: -> $scope.csTagService
      controller: ["$scope", "$modalInstance", "ingredient", "csTagService", ($scope, $modalInstance, ingredient, csTagService) ->
        $scope.ingredient = ingredient
        $scope.csTagService = csTagService
      ]
    )
]
