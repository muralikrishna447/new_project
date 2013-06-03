angular.module('ChefStepsApp').controller 'StepController', ["$scope", ($scope) ->

  $scope.masterSelect = false

  $scope.addIngredient =  ->
    # *don't* use ingred = {title: ...} here, it will screw up display if an empty one gets in the list
    ingred = ""
    item = {ingredient: ingred}
    $scope.step.ingredients.push(item)
    #$scope.addUndo()

  $scope.removeIngredient = (index) ->
    $scope.step.ingredients.splice(index, 1)
    $scope.addUndo()

  $scope.setupPossibleIngredients = ->
    $scope.possible_ingredients = deepCopy($scope.activity.ingredients)
    if $scope.possible_ingredients.length > 0
      $scope.possible_ingredients[0].included = true

  $scope.toggleSelectFromMaster = ->
    $scope.masterSelect = ! $scope.masterSelect
    $scope.setupPossibleIngredients() if $scope.masterSelect

]