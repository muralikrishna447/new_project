window.deepCopy = (obj) ->
  if _.isArray(obj)
    jQuery.extend(true, [], obj)
  else
    jQuery.extend(true, {}, obj)


angular.module('ChefStepsApp').controller 'ActivityController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "$anchorScroll", "csEditableHeroMediaService", "Activity", "csTagService", 
($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, $anchorScroll, csEditableHeroMediaService, Activity, csTagService) ->

  $scope.heroMedia = csEditableHeroMediaService

  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.undoStack = []
  $scope.undoIndex = -1
  $scope.editMode = false
  $scope.editMeta = false
  $scope.preventAutoFocus = false
  $scope.shouldShowRestoreAutosaveModal = false
  $scope.shouldShowAlreadyEditingModal = false
  $scope.alerts = []
  $scope.activities = {}
  $rootScope.loading = 0

  $scope.csTagService = csTagService

  $scope.getObject = ->
    $scope.activity
  csEditableHeroMediaService.getObject = $scope.getObject

  $scope.hasFeaturedImage = ->
    $scope.getObject()?.featured_image_id? && $scope.getObject().featured_image_id

  $scope.featuredImageURL = (width) ->
    url = ""
    if $scope.hasFeaturedImage()
      url = JSON.parse($scope.getObject().featured_image_id).url
      url = url + "/convert?fit=max&w=#{width}&cache=true"
    window.cdnURL(url)

  $timeout ( ->
    $rootScope.$broadcast('showPopupCTA') if $scope.popupEligible
  ), 5000

  $scope.csGlobals =
    scaling: 1.0
    units: "grams"

  $scope.displayScaling = (scale) ->
    r = (Math.round(scale * 10) / 10)
    if r > 100
      r = Math.round(r)
    r = r.toString()
    r = "&frac12;" if r == "0.5"
    "x" + r

  $scope.maybeDisplayCurrentScaling = ->
    return null if $scope.csGlobals.scaling == 1.0
    $scope.displayScaling($scope.csGlobals.scaling)

  $scope.maybeWarnCurrentScaling = ->
    return null if $scope.csGlobals.scaling == 1.0
    "- Adjust based on recipe " + $scope.maybeDisplayCurrentScaling()

  $scope.fork = ->
    $rootScope.loading += 1
    $scope.activity.$update({fork: true},
    ((response) ->
      # Hacky way of handling a slug change. History state would be better, just not ready to delve into that yet.
      window.location = response.redirect_to if response.redirect_to)
    )

  # Overall edit mode
  $scope.startEditMode = ->
    if ! $scope.editMode
      $scope.editMode = true
      $scope.editMeta = false
      $scope.showHeroVisualEdit = false
      $scope.undoStack = [deepCopy $scope.activity]
      $scope.undoIndex = 0
      $scope.activity.$startedit()
      $timeout ->
        $scope.csGlobals.scaling = 1
        $scope.csGlobals.units = "grams"
        window.updateUnits(false)

  $scope.maybeStartEditMode = ->
    # Must reload activity before checking currently_editing_user - want to get any changes that have
    # been made since we loaded the original page *and* want to know if anyone started editing.
    $scope.preventAutoFocus = true
    $rootScope.loading += 1
    temp_activity = Activity.get($scope.url_params, ->
      $rootScope.loading -= 1
      $scope.temporaryNoAutofocus()

      if temp_activity.updated_at != $scope.activity.updated_at
        $scope.activity = temp_activity

      if temp_activity.currently_editing_user
        $scope.activity.currently_editing_user = temp_activity.currently_editing_user
        $scope.shouldShowAlreadyEditingModal = true
      else
        $scope.startEditMode()
    )

  $scope.postEndEditMode = ->
    $scope.editMode = false
    $timeout (->
      window.updateUnits(false)
    ), 0.5
    $scope.clearLocalStorage()
    $scope.saveBaseToLocalStorage()
    $scope.activity.$endedit()
    true

  $scope.endEditMode = ->

    $scope.alerts = []
    $scope.normalizeModel()
    $scope.normalizeWeightUnits()
    $rootScope.loading += 1
    $scope.activity.$update(
      {},
      ((response) ->
        $rootScope.loading -= 1
        console.log "ACTIVITY SAVE WIN"
        # Hacky way of handling a slug change. History state would be better, just not ready to delve into that yet.
        window.location = response.redirect_to if response.redirect_to
        $scope.postEndEditMode()
        $scope.activity.is_new = false),

      ((error) ->
        $rootScope.loading -= 1
        console.log "ACTIVITY SAVE ERRORS: " + JSON.stringify(error)
        _.each(error.data.errors, (e) -> $scope.addAlert({message: e})))
    )

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
      $scope.saveToLocalStorage()
      $scope.temporaryNoAutofocus();
    true

  $scope.redo = ->
    if $scope.redoAvailable
      $scope.undoIndex += 1
      $scope.activity = deepCopy $scope.undoStack[$scope.undoIndex]
      $scope.saveToLocalStorage()
      $scope.temporaryNoAutofocus();
    true

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
      $scope.saveToLocalStorage()

  # Gray out a section if the contents are empty
  $scope.disableIf = (condition) ->
    if condition then "disabled-section" else ""

  $scope.addEditModeClass = ->
    if $scope.editMode then "edit-mode" else "show-mode"

  $scope.temporaryNoAutofocus = ->
    # Pretty ugly, but I don't see a cleaner solution
    $scope.preventAutoFocus = true
    $timeout ( ->
      $scope.preventAutoFocus = false
    ), 1000

  $scope.localStorageKeyId = ->
    $('#activity-body').data("activity-id")

  # Local storage (to prevent data loss on tab close etc.)
  $scope.localStorageKey = ->
    'ChefSteps Activity ' + $scope.localStorageKeyId()

  $scope.localStorageBaseKey = ->
    'ChefSteps Activity Base' + $scope.localStorageKeyId()

  $scope.saveToLocalStorage = ->
    if $scope.editMode
      localStorageService.add($scope.localStorageKey(), JSON.stringify($scope.activity))

  $scope.saveBaseToLocalStorage = ->
    localStorageService.add($scope.localStorageBaseKey(), JSON.stringify($scope.activity))

  $scope.maybeRestoreFromLocalStorage = ->
    restored = localStorageService.get($scope.localStorageKey())
    if restored
      $scope.activity = new Activity(JSON.parse(restored))

      $scope.temporaryNoAutofocus();
      $scope.startEditMode()

      # Coming back from local storage, our undo stack will be the [original, restored]
      orig = localStorageService.get($scope.localStorageBaseKey())
      if orig
        $scope.undoStack = [new Activity(JSON.parse(orig)), $scope.undoStack[0]]
        $scope.undoIndex = 1

      $timeout ( ->
        $scope.shouldShowRestoreAutosaveModal = true
      ), 1000

      return true
    else
      false

  $scope.clearLocalStorage = ->
    localStorageService.remove($scope.localStorageKey())

  # Activity types
  $scope.activityTypes = ["Recipe", "Science", "Technique"]

  $scope.hasActivityType = (t) ->
    _.contains($scope.activity?.activity_type, t)

  $scope.toggleActivityType = (t) ->
    if $scope.hasActivityType(t)
      $scope.activity.activity_type = _.without($scope.activity.activity_type, t)
    else
      $scope.activity.activity_type = _.union($scope.activity.activity_type, [t])

  # Activity difficulties
  $scope.activityDifficulties = ["Easy", "Intermediate", "Advanced"]

  $scope.hasActivityDifficulty = (t) ->
    ($scope.activity?.difficulty || "").toUpperCase() == t.toUpperCase()

  $scope.setActivityDifficulty = (t) ->
    $scope.activity.difficulty = t.toLowerCase()

  # These IDs are stored in the database, don't go changing them!!
  $scope.sourceActivityTypes = [
    {id: 0, name: "Adapted from"},
    {id: 1, name: "Inspired by"},
  ]

  $scope.sourceActivityTypeString = ->
    act_type = _.where($scope.sourceActivityTypes, {id: $scope.activity.source_type})[0]
    act_type =  $scope.sourceActivityTypes[0] if ! act_type
    act_type.name

  $scope.tagsSelect2 = ->
    csTagService.getSelect2Info($scope.activity?.tags, "/activities/all_tags.json")

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
    angular.forEach $scope.activity?.equipment, (item) ->
      has = has || (! item.optional)
    return has

  $scope.hasOptionalEquipment = ->
    has = false
    angular.forEach $scope.activity?.equipment, (item) ->
      has = has || (item.optional)
    return has

  $scope.hasAnyEquipment = ->
    $scope.activity?.equipment?.length > 0

  $scope.optionalEquipment = (item) ->
    item.optional

  $scope.requiredEquipment = (item) ->
    ! $scope.optionalEquipment(item)

  $scope.anyEquipment = (item) ->
    true

  $scope.addEquipment = (optional) ->
    # *don't* use equip = {title: ...} here, it will screw up display if an empty one gets in the list
    equip = ""
    item = {equipment: equip, optional: false}
    $scope.activity.equipment.push(item)
    #$scope.addUndo()

  $scope.all_equipment = (equip_name) ->
    $http.get("/equipment.json?q=" + equip_name).then (response) ->
      # always include current search text as an option
      r = limitToFilter(response.data, 15)
      r.unshift({title: equip_name})
      r

  # Using _.compact was confusing angular - specifically ui-sortable for ingredients.
  # https://www.pivotaltracker.com/story/show/59722984
  # I don't know the exact reason.
  myCompact = (a) ->
    i = a.length - 1
    while i >= 0
      if ! a[i]
        a.splice(i, 1)
      i -= 1
    a


  # Use this to fix up anything that might be screwed up by our angular editing. E.g.
  # for the equipment edit, when typing in a new string, if it hasn't gone through the
  # autocomplete (unshift in all_equipment), it will be missing a nesting level in the model.
  $scope.normalizeModel = () ->
    myCompact($scope.activity.equipment)
    angular.forEach $scope.activity.equipment, (item) ->
      if _.isString(item["equipment"])
        item["equipment"] = {title: item["equipment"]}

    myCompact($scope.activity.ingredients)
    angular.forEach $scope.activity.ingredients, (item) ->
      if _.isString(item["ingredient"])
        item["ingredient"] = {title: item["ingredient"]}

    myCompact($scope.activity.steps)
    angular.forEach $scope.activity.steps, (step) ->
      step.ingredients = myCompact(step.ingredients)
      angular.forEach step.ingredients, (item) ->
        if _.isString(item["ingredient"])
          item["ingredient"] = {title: item["ingredient"]}

  $scope.normalizeWeightUnits = () ->
    angular.forEach _.flatten([$scope.activity.ingredients, _.map($scope.activity.steps, (s) -> s.ingredients)]), (item) ->
      if item.unit == "lb"
        item.display_quantity = item.display_quantity * 453.592
        item.unit = "g"
      else if item.unit == "oz"
        item.display_quantity = item.display_quantity * 28.3495
        item.unit = "g"


  $scope.getIngredientsList = ->
    $scope.activity.ingredients

  $scope.parsePreloaded = ->
    # prestoring the JSON in the HTML on initial load for speed
    preloaded_activity = $("#preloaded-activity-json").text()

    if preloaded_activity
      $scope.activity = new Activity(JSON.parse(preloaded_activity))
      $scope.activity.is_new = ($scope.activity.title.length == 0)
      true
    else
      false

  $scope.fetchActivity = (id, callback) ->
    console.log("START FETCH ACTIVITY #{id}")

    if _.isNumber(id) && ! $scope.activities[id]
      $rootScope.loading += 1
      console.log "Loading count #{$rootScope.loading}"
      console.log "Loading activity " + id
      $scope.activities[id] = Activity.get({id: id}, ( ->
        $rootScope.loading -= 1
        console.log "Loading count #{$rootScope.loading}"
        console.log "Loaded activity " + id
        callback() if callback
      ),( (response) ->
        $rootScope.loading -= 1
        console.log "Loading count #{$rootScope.loading}"
        console.log "Error response loading #{id}: #{response}.toString()"
        window.location = response.data.path
      ))
    console.log("END FETCH ACTIVITY #{id}")

  $scope.makeActivityActive = (id) ->
    return if id == $scope.activity?.id
    $scope.activity = $scope.activities[id]
    cs_event.track(id, 'Activity', 'show')
    mixpanel.track('Activity Viewed', {'context' : 'course', 'title' : $scope.activity.title, 'slug' : $scope.activity.slug});
    $scope.csGlobals.units = "grams"
    $scope.csGlobals.scaling = 1
    $timeout ->
      window.updateUnits(false)

  $scope.loadActivity = (id) ->
    return if id == $scope.activity?.id
    $scope.maybeShowWhyByWeight()
    if $scope.activities[id]
      # Even if we have it cached, use a slight delay and dissolve to
      # make it feel smooth and let youtube load
      $scope.makeActivityActive(id)
      console.log "Cached"
      $rootScope.loading += 1
      console.log "Loading count #{$rootScope.loading}"
      $timeout (  -> 
        $rootScope.loading -= 1
        console.log "Loading count #{$rootScope.loading}"
      ), 500
    else
      $scope.fetchActivity(id, -> $scope.makeActivityActive(id))

  $scope.$on 'loadActivityEvent', (event, activity_id) ->
    $scope.loadActivity(activity_id)

  $scope.startViewActivity = (id, prefetch_id) ->
    $scope.loadActivity(id)

    # If there is a prefetch request, do it a little later
    if prefetch_id
      $timeout (->
       $scope.fetchActivity(prefetch_id)
      ), 3000

  $scope.addAlert = (alert) ->
    $scope.alerts.push(alert)
    $timeout ->
      $("html, body").animate({ scrollTop: -500 }, "slow")

  $scope.closeAlert = (index) ->
    $scope.alerts.splice(index, 1)

  # We've had bad luck getting the youtube iframe player API state change event to work reliably, so instead
  # we're asking youtube for the video duration and making the assumption that the video is done playing after
  # that time period.
  $scope.schedulePostPlayEvent = ->
    $scope.heroVideoDuration = -1
    if $scope.activity && csEditableHeroMediaService.hasHeroVideo()
      $http.jsonp("//gdata.youtube.com/feeds/api/videos/" + $scope.activity.youtube_id + "?v=2&callback=JSON_CALLBACK").then (response) ->
        # Good god, parsing XML that contains namespaces in the elements using jquery is a compatibility disaster!
        # See http://stackoverflow.com/questions/853740/jquery-xml-parsing-with-namespaces
        # So for now I'm doing a fugly regexp parse. At least it works.
        duration = response.data.match(/yt:duration seconds=.([\d]*)/)[1]
        if duration > 1
          $scope.heroVideoDuration = duration
          $timeout (->
            $scope.videoDurationExceeded = true
            $rootScope.$broadcast('expandSocialButtons')
          ), duration * 1000 + 5000

  # Social share callbacks
  $scope.socialURL = ->
    "http://chefsteps.com/activities/" + $scope.activity?.slug

  $scope.socialTitle = ->
    $scope.activity.title

  $scope.socialMediaItem = ->
    return $scope.featuredImageURL(800) if $scope.hasFeaturedImage()
    null

  $scope.cs140Message = ->
    $scope.activity.summary_tweet || $scope.activity.title

  $scope.tweetMessage = ->
    "I love this:"

  $scope.emailSubject = ->
    "I thought you might like " + $scope.socialTitle()

  $scope.emailBody = ->
    "Hey, I thought you might like " + $scope.socialTitle() + " at ChefSteps.com. Here's the link: " + $scope.socialURL()

  $scope.maximizeDescription = false
  $scope.toggleMaximizeDescription = ->
    $scope.maximizeDescription = ! $scope.maximizeDescription
    # Fugly!
    window.setMaximizeDescription($scope.maximizeDescription)
    if $scope.maximizeDescription
     mixpanel.track('Activity Description Maximized', {'slug' : $scope.activity.slug});
     mixpanel.people.increment('Activity Description Maximized Count')

  $scope.ingredientSpanClass = ->
    if $scope.activity && $scope.activity.description
      'span6'
    else
      'span7'

  $scope.getShowWhyByWeight = ->
    $scope.showWhyByWeight

  $scope.hideWhyByWeight = (abandon) ->
    $scope.showWhyByWeight = false
    if abandon
      mixpanel.track('Why By Weight Abandoned', {'title' : $scope.activity.title, 'slug' : $scope.activity.slug})
    else
      mixpanel.track('Why By Weight Tell Me More', {'title' : $scope.activity.title, 'slug' : $scope.activity.slug})

  $scope.maybeShowWhyByWeight = ->
    return if ! $scope.activity || ! $scope.activity.ingredients?.length > 0
    return if $scope.activity.ingredients[0].ai.unit != "g"
    $scope.showWhyByWeight = ! localStorageService.get('whyByWeightShown')
    localStorageService.set('whyByWeightShown', true)

  # One time stuff

  if $scope.parsePreloaded()
    $scope.maybeShowWhyByWeight()
    $scope.schedulePostPlayEvent()

    if ! $scope.maybeRestoreFromLocalStorage()
      $scope.saveBaseToLocalStorage()

      if ($scope.activity.title == "") || ($scope.url_params.start_in_edit)
        $scope.startEditMode()
        $scope.editMeta = true






]

