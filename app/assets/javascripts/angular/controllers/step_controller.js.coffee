angular.module('ChefStepsApp').controller 'StepController', ["$scope", "$rootScope", "$element", "$timeout", "$http", ($scope, $rootScope, $element, $timeout, $http) ->

  $scope.step.presentation_hints ||= {}
  $scope.step.presentation_hints.aside_position = "left"

  $scope.masterSelect = false

  $scope.getIngredientsList = ->
    $scope.step.ingredients

  $scope.setupPossibleIngredients = ->
    $scope.possible_ingredients = deepCopy($scope.activity.ingredients)
    for pi in $scope.possible_ingredients
      pi.included = true if _.find($scope.step.ingredients, (si) -> si.ingredient.title == pi.ingredient.title)

  $scope.transferPossibleIngredients = ->
    new_ingredients = $scope.possible_ingredients
    old_ingredients = $scope.step.ingredients
    result = []

    # Bring over all new ingredients, referencing quantities etc. from existing step ingredient if available.
    # Have to use title, not id as the basis of comparison because ingredients freshly added in this edit session
    # that aren't in the db won't have an id until save.
    for pi in new_ingredients
      if pi.included
        si = _.find(old_ingredients, (si) -> si.ingredient.title == pi.ingredient.title)
        if si?
          result.push(si)
        else
          result.push(pi)

    # Now bring over anything that was in the step ingredients that isn't in the master list; these
    # are probably emergent ingredients from previous steps.
    for si in old_ingredients
      if ! _.find(new_ingredients, (pi) -> pi.ingredient.title == si.ingredient.title)
        result.push(si)

    $scope.step.ingredients = result

    $scope.temporaryNoAutofocus();

  $scope.toggleSelectFromMaster = ->
    $scope.masterSelect = ! $scope.masterSelect
    if $scope.masterSelect
      $scope.setupPossibleIngredients()
    else
      $scope.transferPossibleIngredients()

  $scope.hasVideo = ->
    (!! $scope.step.youtube_id) || (!! $scope.step.vimeo_id)

  $scope.hasAV = ->
    $scope.hasVideo() || (!! $scope.step.image_id)

  $scope.hasIngredients = ->
    $scope.step.ingredients?.length

  $scope.getStepOpenForEdit = ->
    $scope.editMode && $scope.stepOpenForEdit

  $scope.toggleStepOpenForEdit = ->
    if ! $scope.stepOpenForEdit
      $rootScope.$broadcast('closeAllSteps')
    $scope.stepOpenForEdit = ! $scope.stepOpenForEdit
    $scope.stepDetailsOpenForEdit = false

  $scope.getStepDetailsOpenForEdit = ->
    $scope.getStepOpenForEdit() && $scope.step.stepDetailsOpenForEdit

  $scope.toggleStepDetailsOpenForEdit = ->
    # Store in step so it doesn't change when ng-if creates a new scope
    $scope.step.stepDetailsOpenForEdit = ! $scope.step.stepDetailsOpenForEdit

  $scope.$on 'closeAllSteps', ->
    $scope.stepOpenForEdit = false

  # If step gets added while in edit mode, default it open
  $scope.stepOpenForEdit = false
  if $scope.editMode
    $scope.toggleStepOpenForEdit()


  $scope.getStepClass = ->
    return 'wide-item' if $scope.step.presentation_hints?.width == 'wide'
    return 'standard-item'

  $scope.getStepType = ->
    return 'aside' if $scope.step.is_aside
    return $scope.step.presentation_hints?.width || 'normal'

  $scope.isStepType = (t) ->
    $scope.getStepType() == t

  $scope.setStepType = (t) ->
    if t == 'aside'
      $scope.step.is_aside = true
      # $scope.step.presentation_hints.aside_position = 'right'
    else
      $scope.step.is_aside = false
      $scope.step.presentation_hints = {}
      $scope.step.presentation_hints.width = t

  $scope.stepIndex = ->
    return $scope.$index + 1 if $scope.step.is_aside
    $scope.$index

  $scope.asideClass = ->
    result = ($scope.effectiveAsideType($scope.$index) || '')
    if $scope.hasAV() || $scope.step.image_id
      result += ' well aside-with-media'
    else
      result += ' well-white-with-border'
    result

]
