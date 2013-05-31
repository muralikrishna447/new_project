angular.module('ChefStepsApp').controller 'StepController', ["$scope", ($scope) ->

  $scope.addIngredient =  ->
    # *don't* use ingred = {title: ...} here, it will screw up display if an empty one gets in the list
    ingred = ""
    item = {ingredient: ingred}
    $scope.step.ingredients.push(item)
    #$scope.addUndo()

  $scope.removeIngredient = (index) ->
    $scope.step.ingredients.splice(index, 1)
    $scope.addUndo()

]