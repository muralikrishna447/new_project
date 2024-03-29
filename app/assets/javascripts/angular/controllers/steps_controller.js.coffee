angular.module('ChefStepsApp').controller 'StepsController', ["$scope", "$location", "$anchorScroll", ($scope, $location, $anchorScroll) ->

  $scope.stepNumber = (index) ->
    return "" if $scope.activity.steps[index].hide_number
    _.filter($scope.activity.steps[0...index], (step) -> (! (step.hide_number || step.is_aside))).length + 1

  $scope.numberedSteps = ->
    return [] if ! $scope.activity?.steps?
    _.filter($scope.activity.steps, (step) -> (! step.hide_number))

  $scope.stepImageURL = (step, width) ->
    url = ""
    if step.image_id
      url = JSON.parse(step.image_id).url
      url = url + "/convert?fit=max&w=#{width}&cache=true"
    window.cdnURL(url)

  $scope.stepImageDescription = (step) ->
    desc = step.image_description
    if ((! desc) || (desc.length == 0)) && step.image_id
      desc = $scope.activity.title
    desc

  $scope.removeStep = (idx) ->
    $scope.activity.steps.splice(idx, 1)
    true

  $scope.isAside = (idx) ->
    return true if $scope.activity.steps[idx]?.is_aside
    false
   
  # Whether this step has an aside, *not* whether it is an aside
  $scope.hasAside = (idx) ->
    return $scope.isAside(idx - 1)

  $scope.canMakeAside = (idx) ->
    return false if idx == $scope.activity.steps.length - 1
    # return false if $scope.hasAside(idx)
    return false if $scope.isAside(idx + 1)
    true

  $scope.canMoveStep = (idx, direction) ->
    return false if idx == 0 && direction < 0
    return false if (idx == $scope.activity.steps.length - 1) && (direction > 0)
    return true if ! $scope.isAside(idx)
    return false if (direction < 0) && $scope.isAside(idx - 2) 
    return false if (direction > 0) && $scope.isAside(idx + 2)
    true

  $scope.addStep = (idx, direction) ->
    newStep = angular.extend({}, {ingredients: [], id: "NEW_" + (Math.random() * 999999999).toString()})
    if $scope.activity.steps.length == 0
      $scope.activity.steps.push(newStep)
    else
      newIdx = idx
      if $scope.hasAside(idx)
        newIdx += 2 if direction > 0
      else if $scope.isAside(idx)
        newStep.is_aside = true
        newIdx += 2 if direction > 0
        newIdx -= 1 if direction < 0
      else
        newIdx += 1 if direction > 0

      $scope.activity.steps.splice(newIdx, 0, newStep)

  $scope.reorderStep = (idx, direction) ->
    # Fairly complex because of asides.  I think we should eventually move asides into their own model.  Also it's very brittle.

    # If moving a step with an aside have to bring the aside along.
    # But if moving an aside, it just moves by itself. This feels logical.
    numToMove = if $scope.hasAside(idx) then 2 else 1
    newIdx = idx + direction

    # If moving up and previous step has an aside, have to move up 2
    if direction == -1 && $scope.isAside(idx - 1)
      newIdx = idx - 2

    # If moving down and next step has an aside, have to move down 2
    if direction == 1 && $scope.hasAside(idx + (if $scope.isAside(idx) then 2 else 1))
      newIdx = idx + 2

    if $scope.hasAside(idx)
      moveIndex = idx - 1
    else
      moveIndex = idx
    movers = $scope.activity.steps.splice(moveIndex, numToMove)

    if numToMove > 1
      if direction == -1
        $scope.activity.steps.splice(newIdx, 0, movers[0], movers[1])
      else
        $scope.activity.steps.splice(newIdx - 1, 0, movers[0], movers[1])
    else
      $scope.activity.steps.splice(newIdx, 0, movers[0])

  $scope.effectiveAsideType = (index) ->
    return null if ! $scope.isAside(index)
    pos = $scope.activity.steps?[index].presentation_hints?.aside_position || "right"
    if $scope.activityColumns < 3
      pos = "center" if pos == "left"
    if $scope.activityColumns < 2
      pos = "center" if pos == "left" || pos == "right"
    pos = "center" if $scope.noInsets
    pos

  $scope.isInsetAside = (index) ->
    pos = $scope.effectiveAsideType(index)
    (pos == "leftInset") || (pos == "rightInset")

  $scope.isCenterAside = (index) ->
    $scope.effectiveAsideType(index) == "center"

  $scope.isSeparateAside = (index) ->
    pos = $scope.effectiveAsideType(index)
    (pos == "left") || (pos == "right")
]