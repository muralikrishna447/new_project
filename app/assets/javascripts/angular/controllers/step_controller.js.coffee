angular.module('ChefStepsApp').controller 'StepController', ["$scope", "$timeout", ($scope, $timeout) ->

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

  $scope.stepSpan = ->
    if $scope.step.is_aside
      'span5'
    else
      'span7'

  $scope.asideClass = ->
    if $scope.hasAV()
      'well'
    else
      'well-border'

]