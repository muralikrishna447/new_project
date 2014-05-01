angular.module('ChefStepsApp').controller 'StepController', ["$scope", "$rootScope", "$element", "$timeout", ($scope, $rootScope, $element, $timeout) ->

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

  $scope.hasAV = -> 
    (!! $scope.step.youtube_id) || (!! $scope.step.image_id)

  $scope.hasIngredients = ->
    $scope.step.ingredients?.length

  $scope.getStepOpenForEdit = ->
    $scope.editMode && $scope.stepOpenForEdit
 
  $scope.toggleStepOpenForEdit = ->
    if ! $scope.stepOpenForEdit
      $rootScope.$broadcast('closeAllSteps')
    $scope.stepOpenForEdit = ! $scope.stepOpenForEdit

  $scope.$on 'closeAllSteps', ->
    $scope.stepOpenForEdit = false

  # If step gets added while in edit mode, default it open
  $scope.stepOpenForEdit = false
  if $scope.editMode
    $scope.toggleStepOpenForEdit()

  $scope.stepSpan = ->
    if $scope.step.is_aside
      'span5 step-with-aside'
    else
      'span7'

  stupidCache = {}
  $scope.asideClass = (index) ->
    result = "left " 
    r = stupidCache[index] || (stupidCache[index] = Math.random())
    if r > 0.5
      result = "right "
    if $scope.hasAV() || $scope.step.image_id
      result += 'well aside-with-media'
    else
      result += 'well-border'
    result

]
