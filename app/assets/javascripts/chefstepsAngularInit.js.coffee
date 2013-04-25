# Angular.js wysiwyg mode stuff. This can't wait til after page load, it needs to happen in the <head>

deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

angular.module('ChefStepsApp', ["ngResource"]).controller 'ActivityController', ($scope, $resource) ->
  Activity = $resource("/activities/:id", {id:  $('#activity-body').data("activity-id")})
  $scope.activity = Activity.get()

  $scope.startEditMode = ->
    $scope.editMode = true
    $scope.originalActivity = deepCopy($scope.activity)

  $scope.endEditMode = ->
    $scope.endEdit()
    $scope.editMode = false

  $scope.cancelEditMode = ->
    $scope.endEditMode()
    $scope.activity = deepCopy($scope.originalActivity)

  $scope.offerEdit = ->
    if $scope.editMode && ! $scope.editActiveInElement(event.currentTarget)
      $('#editTarget').prependTo($(event.currentTarget)).show()

  $scope.unofferEdit = ->
    $('#editTarget').hide().prependTo($('body'))

  $scope.startEdit = ->
    pair = $('#editTarget').parent()
    $scope.activeEdit = pair.attr('id')
    $scope.unofferEdit()
    event.stopPropagation()
    window.wysiwygActivatedCallback(pair)

  $scope.endEdit = ->
    if $scope.activeEdit
      $scope.activeEdit = null
      window.wysiwygDeactivatedCallback()

  $scope.editActiveInElement = (element) ->
    if $scope.editMode && $scope.activeEdit
      target_pair = $(element).closest('.edit-pair')
      if (target_pair.length == 1) && (target_pair.attr('id') == $scope.activeEdit)
        return true
    false

  $scope.bodyClick = ->
    if ! $scope.editActiveInElement(event.target)
      $scope.endEdit()

