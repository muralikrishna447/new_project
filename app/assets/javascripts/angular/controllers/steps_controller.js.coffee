angular.module('ChefStepsApp').controller 'StepsController', ["$scope", "$location", "$anchorScroll", ($scope, $location, $anchorScroll) ->

  $scope.stepNumber = (index) ->
    return "" if $scope.activity.steps[index].hide_number
    _.filter($scope.activity.steps[0...index], (step) -> (! step.hide_number)).length + 1

  $scope.numberedSteps = ->
    return [] if ! $scope.activity?.steps?
    _.filter($scope.activity.steps, (step) -> (! step.hide_number))

  $scope.showStepDot = (index) ->
    ! $scope.activity.steps[index].hide_number

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