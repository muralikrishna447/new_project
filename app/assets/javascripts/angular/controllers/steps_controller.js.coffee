angular.module('ChefStepsApp').controller 'StepsController', ["$scope", ($scope) ->

  $scope.stepNumber = (index) ->
    _.filter($scope.activity.steps[0...index], (step) -> (! step.hide_number)).length + 1

  $scope.stepImageURL = (step, width) ->
    url = ""
    if step.image_id
      url = JSON.parse(step.image_id).url
      url = url + "/convert?fit=max&w=#{width}&cache=true"
    window.cdnURL(url)

  $scope.stepImageDescription = (step) ->
    desc = step.image_description
    if ((! desc) || (desc.length == 0)) && step.image_id
      desc = JSON.parse(step.image_id).filename
    desc

  $scope.reorderStep = (idx, direction) ->
    t = $scope.activity.steps[idx]
    $scope.activity.steps[idx] = $scope.activity.steps[idx + direction]
    $scope.activity.steps[idx + direction] = t
    $scope.addUndo()

  $scope.removeStep = (idx) ->
    $scope.activity.steps.splice(idx, 1)
    $scope.addUndo()

  $scope.addStepAtIndex = (idx) ->
    step = {ingredients: []}
    if $scope.activity.steps.length == 0
      $scope.activity.steps.push(step)
    else
      $scope.activity.steps.splice(idx, 0, step)
    $scope.addUndo()



]