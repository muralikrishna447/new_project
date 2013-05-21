window.deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

angular.module('ChefStepsApp').controller 'ActivityController', ["$scope", "$resource", "$location", "$http", "limitToFilter", "$timeout", ($scope, $resource, $location, $http, limitToFilter, $timeout) ->
  Activity = $resource("/activities/:id/as_json", {id:  $('#activity-body').data("activity-id")}, {update: {method: "PUT"}})
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
    $timeout ->
      window.csScaling = 1
      window.updateUnits(false)

  $scope.postEndEditMode = ->
    $scope.editMode = false

  $scope.endEditMode = ->
    $scope.normalizeModel()
    $scope.activity.$update()
    $scope.postEndEditMode()

  $scope.cancelEditMode = ->
    if $scope.undoAvailable
      $scope.activity = deepCopy $scope.undoStack[0]
    $scope.postEndEditMode()

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

  $scope.$on 'maybe_save_undo', ->
    $scope.addUndo()

  # Hero video/image stuff
  $scope.hasHeroVideo = ->
    $scope.activity.youtube_id? && $scope.activity.youtube_id

  $scope.hasHeroImage = ->
    $scope.activity.image_id? && $scope.activity.image_id

  $scope.heroVideoURL = ->
    autoplay = if $scope.url_params.autoplay then "1" else "0"
    "http://www.youtube.com/embed/#{$scope.activity.youtube_id}?wmode=opaque\&rel=0&modestbranding=1\&showinfo=0\&vq=hd720\&autoplay=#{autoplay}"

  $scope.heroVideoStillURL = ->
    "http://img.youtube.com/vi/#{$scope.activity.youtube_id}/0.jpg"

  $scope.heroImageURL = (width) ->
    console.log $scope.activity.image_id
    url = JSON.parse($scope.activity.image_id).url
    url + "/convert?fit=max&w=#{width}&cache=true"

  $scope.heroDisplayType = ->
    return "video_still" if $scope.editMode && $scope.hasHeroVideo()
    return "video" if $scope.hasHeroVideo()
    return "image" if $scope.hasHeroImage()
    return "add_button" if $scope.editMode

  $scope.sortOptions = {
    axis: 'y',
    containment: 'parent',
    cursor: 'move',
    handle: '.drag-handle'
  }

  # Equipment stuff TODO: make a controller just for equipment

  $scope.equipmentDisplayType = (item) ->
    result = "basic"
    result = "product" if !! item.equipment.product_url
    result = "fake_link" if $scope.editMode && (result == "product")
    result

  # TODO: nicer using underscore _map?
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
    # *don't* use equip = {title: ...} here, it will screw up display if an empty one gets in the list
    equip = ""
    item = {equipment: equip, optional: optional}
    $scope.activity.equipment.push(item)
    #$scope.addUndo()

  $scope.all_equipment = (equip_name) ->
    $http.get("/equipment.json?q=" + equip_name).then (response) ->
      # always include current search text as an option
      r = limitToFilter(response.data, 15)
      r.unshift({title: equip_name})
      r

  # Ingredient stuff TODO: make a controller just for ingredients

  $scope.ingredient_display_type = (ai) ->
    result = "basic"
    result = "product" if !! ai.ingredient.product_url
    result = "subrecipe" if !! ai.ingredient.sub_activity_id
    result = "fake_link" if $scope.editMode && (result == "product" || result == "subrecipe")
    result

  $scope.unitMultiplier = (unit_name) ->
    result = 1
    result = 1000 if unit_name == "kg"
    result

  $scope.addIngredient =  ->
    # *don't* use ingred = {title: ...} here, it will screw up display if an empty one gets in the list
    ingred = ""
    item = {ingredient: ingred}
    $scope.activity.ingredients.push(item)
    #$scope.addUndo()

  $scope.all_ingredients = (ingredient_name) ->
    $http.get("/ingredients.json?q=" + ingredient_name).then (response) ->
      # always include current search text as an option
      r = limitToFilter(response.data, 15)
      r.unshift({title: ingredient_name})
      r


  # Use this to fix up anything that might be screwed up by our angular editing. E.g.
  # for the equipment edit, when typing in a new string, if it hasn't gone through the
  # autocomplete (unshift in all_equipment), it will be missing a nesting level in the model.
  $scope.normalizeModel = () ->
    angular.forEach $scope.activity.equipment, (item) ->
      if _.isString(item["equipment"])
        item["equipment"] = {title: item["equipment"]}

    angular.forEach $scope.activity.ingredients, (item) ->
      if _.isString(item["ingredient"])
        item["ingredient"] = {title: item["ingredient"]}

]

