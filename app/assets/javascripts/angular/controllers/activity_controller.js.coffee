window.deepCopy = (obj) ->
  jQuery.extend(true, {}, obj)

angular.module('ChefStepsApp').controller 'ActivityController', ["$scope", "$resource", "$location", "$http", "limitToFilter", "$timeout", ($scope, $resource, $location, $http, limitToFilter, $timeout) ->
  Activity = $resource( "/activities/:id/as_json",
                        {id:  $('#activity-body').data("activity-id")},
                        {update: {method: "PUT"}}
                      )
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.activity = Activity.get($scope.url_params, ->
    if ($scope.activity.title == "") || ($scope.url_params.start_in_edit)
      $scope.startEditMode()
      setTimeout (->
        title_elem = $('#title-edit-pair')
        angular.element(title_elem).scope().setMouseOver(true)
        title_elem.click()
      ), 0
  )
  $scope.undoStack = []
  $scope.undoIndex = -1
  $scope.editMode = false
  $scope.editMeta = false

  $scope.fork = ->
    $scope.activity.$update({fork: true},
    ((response) ->
      # Hacky way of handling a slug change. History state would be better, just not ready to delve into that yet.
      window.location = response.redirect_to if response.redirect_to),
    )
  # Overall edit mode
  $scope.startEditMode = ->
    $scope.editMode = true
    $scope.editMeta = false
    $scope.showHeroVisualEdit = false
    $scope.undoStack = [deepCopy $scope.activity]
    $scope.undoIndex = 0
    $timeout ->
      window.csScaling = 1
      window.updateUnits(false)
      window.expandSteps()

  $scope.postEndEditMode = ->
    $scope.editMode = false
    window.collapseSteps()

  $scope.endEditMode = ->
    $scope.normalizeModel()
    $scope.activity.$update({},
      ((response) ->
        # Hacky way of handling a slug change. History state would be better, just not ready to delve into that yet.
       window.location = response.redirect_to if response.redirect_to),
    )
    $scope.postEndEditMode()

  $scope.cancelEditMode = ->
    if $scope.undoAvailable
      $scope.activity = deepCopy $scope.undoStack[0]
    $scope.postEndEditMode()

  # Tweak to let dropdowns leak out of collapse when not collapsed
  # http://stackoverflow.com/questions/11926028/bootstrap-dropdown-in-collapse
  $scope.toolbarBonusStyle = ->
    s = {}
    s = {overflow: "visible"} if ! $scope.editMode
    s

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

  # Gray out a section if the contents are empty
  $scope.disableIf = (condition) ->
    if condition then "disabled-section" else ""

  # Activity types
  $scope.activityTypes = ["Recipe", "Science", "Technique"]

  $scope.hasActivityType = (t) ->
    _.contains($scope.activity.activity_type, t)

  $scope.toggleActivityType = (t) ->
    if $scope.hasActivityType(t)
      $scope.activity.activity_type = _.without($scope.activity.activity_type, t)
    else
      $scope.activity.activity_type = _.union($scope.activity.activity_type, [t])

  # These IDs are stored in the database, don't go changing them!!
  $scope.sourceActivityTypes = [
    {id: 0, name: "Adapted from"},
    {id: 1, name: "Inspired by"},
  ]

  $scope.sourceActivityTypeString = ->
    _.where($scope.sourceActivityTypes, {id: $scope.activity.source_type})[0].name

  # Keep <title> tag in sync
  $scope.$watch 'activity.title', ->
    $(document).attr("title", "ChefSteps " + ($scope.activity.title || "New Recipe"))

  # Tags
  $scope.tagsSelect2 =

    placeholder: "Add some tags"
    tags: true
    multiple: true
    width: "100%"

    ajax:
      url: "/activities/all_tags.json",
      data: (term, page) ->
        return {
          q: term
        }

      results: (data, page) ->
        return {results: data}

    formatResult: (tag) ->
      tag.name

    formatSelection: (tag) ->
      tag.name

    createSearchChoice: (term, data) ->
      id: term
      name: term

  # Video/image stuff
  $scope.hasHeroVideo = ->
    $scope.activity.youtube_id? && $scope.activity.youtube_id

  $scope.hasHeroImage = ->
    $scope.activity.image_id? && $scope.activity.image_id

  $scope.hasFeaturedImage = ->
    $scope.activity.featured_image_id? && $scope.activity.featured_image_id

  $scope.heroVideoURL = ->
    autoplay = if $scope.url_params.autoplay then "1" else "0"
    "http://www.youtube.com/embed/#{$scope.activity.youtube_id}?wmode=opaque\&rel=0&modestbranding=1\&showinfo=0\&vq=hd720\&autoplay=#{autoplay}"

  $scope.heroVideoStillURL = ->
    "http://img.youtube.com/vi/#{$scope.activity.youtube_id}/0.jpg"

  $scope.heroImageURL = (width) ->
    url = ""
    if $scope.hasHeroImage()
      url = JSON.parse($scope.activity.image_id).url
      url + "/convert?fit=max&w=#{width}&cache=true"

  $scope.featuredImageURL = (width) ->
    url = ""
    if $scope.hasFeaturedImage()
      url = JSON.parse($scope.activity.featured_image_id).url
      url + "/convert?fit=max&w=#{width}&cache=true"

  $scope.heroDisplayType = ->
    return "video" if $scope.hasHeroVideo()
    return "image" if $scope.hasHeroImage()
    return "none"

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

  # Not currently used - maybe come back to it
  $scope.ingredientSelect2 =
    ajax:
      url: "/ingredients.json?q=a",
      data: (term, page) ->
        return {
          q: term
        }

      results: (data, page) ->
        return {results: data}

    formatResult: (ingredient) ->
      ingredient.title

    formatSelection: (ingredient) ->
      ingredient.title

    initSelection: (element, callback) ->
      callback(angular.element(element).scope().ai.ingredient)

    width: "element"

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

