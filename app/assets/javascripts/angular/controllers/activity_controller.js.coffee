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

  $scope.bodyClick = ->
    if $scope.editMode
      if $(event.target).is('body') || $(event.target).is('html')
        $scope.$broadcast('end_all_edits')

  # Undo/redo TODO: could be a service I think
  $scope.undo = ->
    if $scope.undoAvailable
      $scope.undoIndex -= 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex ]

  $scope.redo = ->
    if $scope.redoAvailable
      $scope.undoIndex += 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex]

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

  # Hero video/image stuff
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

  # Equipment stuff TODO: nicer using underscore _map?
  $scope.hasRequiredEquipment = ->
    has = false
    angular.forEach $scope.activity.equipment, (item) ->
      has = has || (! item.optional)
    return has

  $scope.hasOptionalEquipment = ->
    has = false
    angular.forEach $scope.activity.equipment, (item) ->
      has = has || (item.optional)
    return has

  $scope.optionalEquipment = (item) ->
    item.optional

  $scope.requiredEquipment = (item) ->
    ! $scope.optionalEquipment(item)

  $scope.addEquipment = (optional) ->
    equip = {}
    item = {equipment: equip, optional: optional}
    $scope.activity.equipment.push(item)
    $scope.addUndo()

  $scope.all_equipment =
    [{id:1, title: "Saucepan"}, {id:2, title: "Widgit", product_url: "http//widgit.com"}, {id: 3, title: "Sauce strainer"}]

]

