deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

angular.module('ChefStepsApp').controller 'ActivityController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  Activity = $resource("/activities/:id", {id:  $('#activity-body').data("activity-id")}, {update: {method: "PUT"}})
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.activity = Activity.get($scope.url_params)
  $scope.undoStack = []
  $scope.undoIndex = -1

  # Overall edit mode
  $scope.startEditMode = ->
    $scope.editMode = true
    $scope.undoStack = [deepCopy $scope.activity]
    $scope.undoIndex = 0

  $scope.endEditMode = ->
    $scope.$broadcast('end_all_edits')
    $scope.editMode = false
    $scope.activity.$update()

  $scope.cancelEditMode = ->
    $scope.$broadcast('end_all_edits')
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

  $scope.addUndo = ->
    # Get rid of any redos past the current spot and put the new state on the stack (unless no change)
    newUndo = deepCopy($scope.activity)
    if ! _.isEqual(newUndo, $scope.undoStack[$scope.undoIndex])
      $scope.undoStack = $scope.undoStack[0..$scope.undoIndex]
      $scope.undoStack.push newUndo
      $scope.undoIndex = $scope.undoStack.length - 1
      $scope.d("After Push")

  $scope.d = (msg) ->
    console.log "------" + msg
    console.log $scope.undoIndex
    idx = 0
    for x in $scope.undoStack
      console.log idx.toString() + ": " + x.title
      idx += 1

  $scope.bodyClick = ->
    if $scope.editMode
      if $(event.target).is('body') || $(event.target).is('html')
        $scope.$broadcast('end_all_edits')

  $scope.showHeroVideo = ->
    $scope.activity.youtube_id? && $scope.activity.youtube_id

  $scope.showHeroImage = ->
    $scope.activity.image_id? && $scope.activity.image_id

  $scope.heroVideoURL = ->
    if $scope.showHeroVideo()
      autoplay = if $scope.url_params.autoplay then "1" else "0"
      "http://www.youtube.com/embed/#{$scope.activity.youtube_id}?wmode=opaque\&rel=0&modestbranding=1\&showinfo=0\&vq=hd720\&autoplay=#{autoplay}"
    else
      ""

  $scope.heroImageURL = (width) ->
    if $scope.showHeroImage()
      console.log $scope.activity.image_id
      url = JSON.parse($scope.activity.image_id).url
      url + "/convert?fit=max&w=#{width}&cache=true"
    else
      ""
]

