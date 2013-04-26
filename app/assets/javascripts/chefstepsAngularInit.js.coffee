# Angular.js wysiwyg mode stuff. This can't wait til after page load, it needs to happen in the <head>

deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

angular.module('ChefStepsApp', ["ngResource", "ui"]).controller 'ActivityController', ($scope, $resource) ->
  Activity = $resource("/activities/:id", {id:  $('#activity-body').data("activity-id")}, {update: {method: "PUT"}})
  $scope.activity = Activity.get()
  $scope.undoStack = []
  $scope.undoIndex = -1

  # Overall edit mode
  $scope.startEditMode = ->
    $scope.editMode = true
    $scope.undoStack = [deepCopy $scope.activity]
    $scope.undoIndex = 0

  $scope.endEditMode = ->
    $scope.endEdit()
    $scope.editMode = false
    $scope.activity.$update()

  $scope.cancelEditMode = ->
    $scope.endEdit()
    $scope.editMode = false
    if $scope.undoAvailable
      $scope.activity = deepCopy $scope.undoStack[0]

  # Undo/redo
  $scope.undo = ->
    if $scope.undoAvailable
      $scope.undoIndex -= 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex ]
      $scope.d("After Undo")

  $scope.redo = ->
    if $scope.redoAvailable
      $scope.undoIndex += 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex]
      $scope.d("After Redo")

  $scope.undoAvailable = ->
    $scope.undoIndex > 0

  $scope.redoAvailable = ->
    $scope.undoIndex < ($scope.undoStack.length - 1)

  $scope.offerEdit = ->
    if $scope.editMode && ! $scope.editActiveInElement(event.currentTarget)
      $('#editTarget').prependTo($(event.currentTarget)).show()

  $scope.unofferEdit = ->
    $('#editTarget').hide().prependTo($('body'))

  # Edit one group
  $scope.startEdit = ->
    $scope.endEdit() # end previous
    pair = $('#editTarget').parent()
    $scope.activeEdit = pair.attr('id')
    $scope.unofferEdit()
    event.stopPropagation()
    window.wysiwygActivatedCallback(pair)

  $scope.endEdit = ->
    # Get rid of any redos past the current spot and put the new state on the stack (unless no change)
    newUndo = deepCopy($scope.activity)
    if ! _.isEqual(newUndo, $scope.undoStack[$scope.undoIndex])
      $scope.undoStack = $scope.undoStack[0..$scope.undoIndex]
      $scope.undoStack.push newUndo
      $scope.undoIndex = $scope.undoStack.length - 1
      $scope.d("After Push")

    if $scope.activeEdit
      $scope.activeEdit = null
      window.wysiwygDeactivatedCallback()

  $scope.d = (msg) ->
    console.log "------" + msg
    console.log $scope.undoIndex
    idx = 0
    for x in $scope.undoStack
      console.log idx.toString() + ": " + x.title
      idx += 1

  $scope.editActiveInElement = (element) ->
    if $scope.editMode && $scope.activeEdit
      target_pair = $(element).closest('.edit-pair')
      if (target_pair.length == 1) && (target_pair.attr('id') == $scope.activeEdit)
        return true
    false

  $scope.bodyClick = ->
    if $scope.editMode && $scope.activeEdit
      if $(event.target).is('body') || $(event.target).is('html')
        $scope.endEdit()

