window.deepCopy = (obj) ->
  if _.isArray(obj)
    jQuery.extend(true, [], obj)
  else
    jQuery.extend(true, {}, obj)

# This is a little captive controller only designed for use inside ActivityController for now.
# Would be better as a directive but needs work to abstract it.
@app.controller 'BannerController', ["$scope", "ActivityMethods", "$timeout", ($scope, ActivityMethods, $timeout) ->
  $scope.showVideo = false

  $scope.showHeroVisual = ->
    return true if $scope.editMode && ($scope.heroMedia.heroDisplayType() == 'video')
    # GD ios/yt. Not only does playVideo() not *work*, it actually causes the YT
    # frame to be completely black, not even any chrome. Awesome.
    # So since we don't want the user to have to click play twice, we just
    # freaking always show the video.
    # return true if ($scope.heroMedia.heroDisplayType() == 'video') &&  /(iPad|iPhone|iPod)/g.test( navigator.userAgent )
    return true if $('.banner-image').width() <= 900
    $scope.showVideo

  $scope.toggleHeroVisual = ->
    $scope.showVideo = ! $scope.showVideo
    $scope.$broadcast('playVideo', $scope.showVideo)

  $scope.$on 'resetVideo', ->
    $scope.toggleHeroVisual() if $scope.showVideo

  $scope.bannerImageDimensions = ->
    w = $('.banner-image').width()
    h = 495
    if w < 650
      h = w * 9.0 / 16.0
    {w: w, h: h}

  bannerImageQuality = 20
  $timeout( ( ->
    bannerImageQuality = 90
  ), 1500)

  $scope.bannerImageURL = ->
    url = ActivityMethods.itemImageFpfile($scope.activity, 'hero').url
    url = 'https://d3awvtnmmsvyot.cloudfront.net/api/file/R0opzl5RgGlUFpr57fYx' if url.length == 0
    dims = $scope.bannerImageDimensions()
    if ! $scope.is_brombone
      url += "/convert?fit=crop&h=#{dims.h}&w=#{dims.w}&quality=#{bannerImageQuality}&cache=true"
    else
      # For brombone, don't set a height because the arbitrarily wide aspect ratio seems like it might be
      # preventing google from putting our images in SERPs. It might be afraid of taking a square crop
      # out of that wide of an image.
      url += "/convert?fit=crop&w=#{dims.w}&quality=90&cache=true"
    window.cdnURL(url)

]

# This controller is a freaking abomination and needs to be broken up into about 5 different services and directives.

@app.controller 'ActivityController', ["$scope", "$rootScope", "$resource", "$location", "$http", "$timeout", "limitToFilter", "localStorageService", "cs_event", "csEditableHeroMediaService", "Activity", "csTagService", "csAuthentication", "csAlertService", "csConfig", "$anchorScroll", "$window", "$sce", "ActivityMethods", "csFilepickerMethods",
($scope, $rootScope, $resource, $location, $http, $timeout, limitToFilter, localStorageService, cs_event, csEditableHeroMediaService, Activity, csTagService, csAuthentication, csAlertService, csConfig, $anchorScroll, $window, $sce, ActivityMethods, csFilepickerMethods) ->
  $scope.heroMedia = csEditableHeroMediaService

  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.editMode = false
  $scope.editMeta = false
  $scope.preventAutoFocus = false
  $scope.shouldShowRestoreAutosaveModal = false
  $scope.shouldShowAlreadyEditingModal = false
  $scope.alerts = []
  $scope.activities = {}
  $scope.csAuthentication = csAuthentication
  $scope.csAlertService = csAlertService
  $rootScope.loading = 0
  reportedCooked = false

  $scope.csTagService = csTagService

  $scope.getObject = ->
    $scope.activity

  $scope.getObjectTypeName = ->
    "Activity"

  csEditableHeroMediaService.getObject = $scope.getObject

  $scope.hasFeaturedImage = ->
    $scope.getObject()?.featured_image_id? && $scope.getObject().featured_image_id

  $scope.baseFeaturedImageURL = ->
    url = ""
    if $scope.hasFeaturedImage()
      url = JSON.parse($scope.getObject().featured_image_id).url
    url

  $scope.featuredImageURL = (width) ->
    url = $scope.baseFeaturedImageURL() + "/convert?fit=max&w=#{width}&cache=true"
    window.cdnURL(url)

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
    "Adjust based on recipe " + $scope.maybeDisplayCurrentScaling()

  $scope.fork = ->
    if $scope.csAuthentication.currentUser()
      $rootScope.loading += 1
      $scope.activity.$update({fork: true},
      ((response) ->
        # Hacky way of handling a slug change. History state would be better, just not ready to delve into that yet.
        window.location = response.redirect_to if response.redirect_to)
      )
    else
      $scope.$emit 'openLoginModal'

  $scope.createdByAdmin = ->
    return true if $scope.activity && $scope.activity.creator == null
    false


  # Overall edit mode
  $scope.startEditMode = ->
    if ! $scope.editMode
      $scope.editMode = true
      $scope.editMeta = false
      $scope.showHeroVisualEdit = false
      $scope.activity.$startedit()
      $scope.activityBeforeEdit = deepCopy $scope.activity

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
    console.log "ACTIVITY SAVE START - Here's the JSON ---------"
    console.log JSON.stringify($scope.activity)
    console.log "-----------------------------------------------"
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
        _.each(error.data.errors, (e) -> csAlertService.addAlert({message: e})))
    )

  $scope.cancelEditMode = ->
    $scope.activity = deepCopy $scope.activityBeforeEdit
    $scope.postEndEditMode()

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

  window.setInterval ( ->
    if $scope.editMode
      $scope.saveToLocalStorage()
      console.log("Autosaved")
  ), 5000

  $scope.saveBaseToLocalStorage = ->
    localStorageService.add($scope.localStorageBaseKey(), JSON.stringify($scope.activity))

  $scope.maybeRestoreFromLocalStorage = ->
    restored = localStorageService.get($scope.localStorageKey())
    if restored
      $scope.activity = new Activity(JSON.parse(restored))

      $scope.temporaryNoAutofocus();
      $scope.startEditMode()

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
      $scope.activity?.printed = false
      $scope.activity.is_new = ($scope.activity.title.length == 0)
      true
    else
      false
    $scope.updateCommentCount()

  $scope.fetchActivity = (id, callback) ->
    console.log("START FETCH ACTIVITY #{id}")

    if _.isNumber(id) && ! $scope.activities[id]
      $rootScope.loading += 1
      console.log "Loading count #{$rootScope.loading}"
      console.log "Loading activity " + id
      Activity.get({id: id}, ( (value) ->
        $scope.activities[id] = value
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
    $scope.trackActivityEngagementFinal() if $scope.activity?.id
    reportedCooked = false
    $scope.activity = $scope.activities[id]
    $scope.activity.printed = false
    cs_event.track(id, 'Activity', 'show')
    mixpanel.track('Activity Viewed', $scope.getEventData());
    $scope.csGlobals.units = "grams"
    $scope.csGlobals.scaling = 1
    $timeout ->
      window.updateUnits(false)

  $scope.loadActivity = (id) ->
    return if id == $scope.activity?.id
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
    $scope.updateCommentCount()
    $scope.$broadcast('resetVideo')


  $scope.commentCount = -1
  $scope.updateCommentCount = ->
    if $scope.activity?
      $http.get("#{csConfig.bloom.api_endpoint}/discussions/activity_#{$scope.activity.id}?apiKey=xchefsteps").success((data, status) ->
        $scope.commentCount = data["commentCount"]
      )

  $scope.$on 'loadActivityEvent', (event, activity_id) ->
    $scope.loadActivity(activity_id)

  $scope.startViewActivity = (id, prefetch_id) ->
    $scope.loadActivity(id)

    # If there is a prefetch request, do it a little later
    if prefetch_id
      $timeout (->
       $scope.fetchActivity(prefetch_id)
      ), 3000


  # We've had bad luck getting the youtube iframe player API state change event to work reliably, so instead
  # we're asking youtube for the video duration and making the assumption that the video is done playing after
  # that time period.
  $scope.schedulePostPlayEvent = ->
    $scope.heroVideoDuration = -1
    if $scope.activity && csEditableHeroMediaService.hasHeroVideo()
      $http.jsonp("//gdata.youtube.com/feeds/api/videos/" + $scope.activity.youtube_id + "?v=2&callback=JSON_CALLBACK").then (response) ->
        return if _.isEmpty(response.data)

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

  $scope.ingredientSpanClass = ->
    if $scope.activity && $scope.activity.description
      'span6'
    else
      'span7'

  $scope.tellMeMore = ->
    $rootScope.$broadcast "hideNellPopup"
    mixpanel.track('Why By Weight Tell Me More', {'title' : $scope.activity.title, 'slug' : $scope.activity.slug})

  $scope.showNell = (view) ->
    $rootScope.$broadcast "showNellPopup",
      include: view

  $scope.showTitle = ->
    if $scope.activity
      switch $scope.activity.title
        when 'FAQ'
          false
        when 'Discussion'
          false
        else
          true


  # Why by weight was removed but can always be added back by adding reached-screen-callback="maybeShowWhyByWeight()" as a attribute
  $scope.maybeShowWhyByWeight = ->
    return if localStorageService.get('whyByWeightShown')
    return if csAuthentication.loggedIn()
    return if ! $scope.activity || ! $scope.activity.ingredients?.length > 0
    $rootScope.$broadcast "showNellPopup",
      include: '_why_by_weight.html'
    localStorageService.set('whyByWeightShown', true)


  # Keep track of when the activity was loaded
  $scope.resetPageLoadedTime = ->
    $scope.lastActiveTime = $scope.pageLoadedTime = Date.now()
  $scope.resetPageLoadedTime()

  # Keep track of last time the user was active on the page
  $scope.activeMinutes = ->
    Math.floor(($scope.lastActiveTime - $scope.pageLoadedTime) / (1000 * 60.0))

  $scope.updateActiveTime = ->
    $scope.lastActiveTime = Date.now()
    $scope.maybeReportCooked()

  angular.element($window).on 'scroll', _.throttle($scope.updateActiveTime, 10000)
  $('.course-content-wrapper').on 'scroll', _.throttle($scope.updateActiveTime, 10000)

  $scope.probablyCooked = ->
    $scope.activity.printed || ($scope.activeMinutes() >= 15)

  $scope.maybeReportCooked = ->
    return if reportedCooked
    if $scope.probablyCooked()
      reportedCooked = true
      eventData = $scope.getExtendedEventData()
      mixpanel?.track "Activity Probably Cooked2", eventData
      Intercom?('trackEvent', "probably-cooked", eventData)
      Intercom?('trackEvent', "probably-cooked-souffle", eventData) if eventData.slug == "molten-chocolate-souffle"
      Intercom?('trackEvent', "probably-cooked-standing-rib-roast", eventData) if eventData.slug == "standing-rib-roast"
      Intercom?('update')

  # various ways of tracking printing; if you google it you'll find out how unreliable they all are
  window.onbeforeprint = ->
    $scope.activity?.printed = true
    $scope.maybeReportCooked()

  if window.matchMedia
    window.matchMedia("print").addListener (mql) ->
      if mql.matches
        # In chrome "matches" never seems to be true. But we've also instrumented the print button in the tools menu so maybe that helps.
        $scope.activity?.printed = true
        $scope.maybeReportCooked()

  $scope.doPrint = ->
    $scope.activity?.printed = true
    window.print()
    $scope.maybeReportCooked()

    # Hack for horrible chrome printing bug
    # http://stackoverflow.com/questions/18622626/chrome-window-print-print-dialogue-opens-only-after-page-reload-javascript
    if window.stop
      window.location.reload()
      window.stop()
    false

  # Track everything we know about the user engagement on this activity, then reset it
  # in case loading new activity in class
  $scope.trackActivityEngagementFinal =  ->
    mixpanel?.track "Activity Engagement Final", $scope.getExtendedEventData()
    $scope.resetPageLoadedTime()
    $scope.activity.printed = false

  $(window).unload ->
    $scope.trackActivityEngagementFinal()

    # http://stackoverflow.com/questions/8350215/delay-page-close-with-javascript
    # Without this, a lot of times the mixpanel event doesn't get recorded; request shows as cancelled in network tab
    # Hmm, and even with this it doesn't work in mobile safari. I tried 'pagehide' stuff but didn't have any luck
    # with that either; so now we track this final engagement when we can but also track send an event as soon
    # as we think we've cooked, see maybeReportCooked()
    start = Date.now()
    while ((Date.now() - start) < 250)
      ;

  $scope.getEventData = ->
    'context' : if $scope.course then 'course' else 'naked'
    'classTitle' : $scope.course?.title
    'title' : $scope.activity.title,
    'slug' : $scope.activity.slug
    'isRecipe' : $scope.activity.ingredients?.length > 1
    'tags': _.pluck($scope.activity.tags, 'name')

  $scope.getExtendedEventData = ->
    activeMinutes = $scope.activeMinutes()
    probablyCooked = $scope.probablyCooked()
    eventData = $scope.getEventData()

    angular.extend eventData,
                    printed: $scope.activity.printed
                    activeMinutes: activeMinutes
                    probablyCooked: probablyCooked

  # One time stuff
  if $scope.parsePreloaded()
    $scope.schedulePostPlayEvent()
    mixpanel?.track('Activity Viewed', $scope.getEventData());

    if ! $scope.maybeRestoreFromLocalStorage()
      $scope.saveBaseToLocalStorage()

      if ($scope.activity.title == "") || ($scope.url_params.start_in_edit)
        $scope.startEditMode()
        $scope.editMeta = true

  # Scroll to comment. Very hacky but it works
  $scope.scrollToComments = ->
    # Super hacky, without the condition, it creates some really really bad looking/long urls
    if $location.path() && (($location.path() == 'discussion') || ($location.path().indexOf('/numbered-step-') == 0))
      anchor = $location.path().replace(/\//g,'')
      $location.path('')
      $location.hash(anchor)

    # Regardless, make sure we get to our anchor
    $anchorScroll()
    $location.hash('')

  # Attempt at a universal anchor scroll
  # Usage http://localhost:3000/activities/creme-brulee/#/?anchor=strain will scroll to the div with id="strain"
  $scope.anchor = ->
    if $location.search() && $location.search().anchor
      anchor = $location.search().anchor
      $location.hash(anchor)

  # Only ChefSteps content that looks like a recipe
  $scope.shouldIncludeJSONLD = ->
    ($scope.activity.ingredients.length > 0) && ! $scope.creator

  # Don't even think of changing this unless you've read and understood:
  #   https://developers.google.com/structured-data/rich-snippets/recipes
  #
  # and tested the output against:
  #   https://developers.google.com/structured-data/testing-tool/
  #
  # For the testing, the best way is to render the page locally and paste in the HTML;
  # if you want to test against chefsteps.com, be sure to add ?_escaped_fragment_=
  # to the end of the URL so you get the static render that the google spider sees via brombone.
  $scope.getJSONLD = ->
    a = $scope.activity

    ingredients = _.map(a.ingredients, (ai) -> ai.ingredient.title)

    steps = _.chain(a.steps)
      .filter((step) -> (! step.hide_number) && (step.directions?.length > 0))
      .map((step) -> step.directions)
      .value()

    image = csFilepickerMethods.convert(ActivityMethods.itemImageFpfile(a, 'hero').url,
        width: 1200
    )

    # Not including totalTime because our time is unformatted, can't reliably convert
    jsonld =
      '@context'          : 'http://schema.org/'
      '@type'             : 'Recipe'
      name                : a.title
      image               : image
      datePublished       : a.published_at
      recipeYield         : a.yield
      description         : a.description
      ingredients         : ingredients
      recipeInstructions  : steps
      author:
        '@type'     : 'Organization'
        name        : 'ChefSteps'

    $sce.trustAsHtml JSON.stringify _.pick jsonld, (v, k) -> !! v

  # Not particularly proud of this.  Had to bump up the timeout time. window.onload doesn't seem to work.  If we start using ng-view more, we should use this: http://stackoverflow.com/questions/21715256/angularjs-event-to-call-after-content-is-loaded
  $timeout ( ->
    $scope.scrollToComments()
    $scope.anchor()
  ), 3000

]
