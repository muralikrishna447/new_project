angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', '$route', '$routeParams', '$location', "$timeout", '$window', "csDataLoading", ($rootScope, $scope, $resource, $http, $route, $routeParams, $location, $timeout, $window, csDataLoading) ->

  $scope.routeParams = $routeParams
  $scope.route = $route

  csDataLoading.setFullScreen(true)

  $scope.$on "$routeChangeSuccess", (event, $currentRoute, $previousRoute) ->
    if $currentRoute.params.slug != $scope.includable_slug
      $scope.overrideLoadActivityBySlug($currentRoute.params.slug)

  $scope.view_inclusion = {}
  $scope.collapsed = {}
  $scope.flatInclusions = []
  $scope.collapsibleInclusions = []
  $scope.inClass = true

  $scope.init = (course_id) ->
    $http.get('/classes/' + course_id + '/show_as_json').success( (data, status) ->
      $scope.course = data
      $scope.includable_slug = $scope.routeParams.slug
      $scope.sortInclusions($scope.course)
      if $scope.routeParams.slug
        $scope.loadInclusion('Activity', $scope.includable_slug)
      else
        if $scope.routeParams.includable_type
          $scope.includable_type = $scope.routeParams.includable_type.toUpperCase()
          $scope.loadInclusion($scope.includable_type, $scope.includable_slug)
        else
          firstInclusion = $scope.flatInclusions[0]
          $scope.loadInclusion(firstInclusion.includable_type, firstInclusion.includable_slug)
    ).error( (data, status) ->
    )

  $scope.loadInclusion = (includable_type, includable_slug) ->
    $scope.currentIncludable = _.find($scope.flatInclusions, (incl) -> incl.includable_slug == includable_slug && incl.includable_type == includable_type)
    console.log "INCLUDABLE: " + $scope.currentIncludable
    if ! $scope.currentIncludable?
      console.log "Couldn't find " + includable_type + " with slug " + includable_slug
      # Redirect to the landing page if activity isn't found
      window.location.replace $scope.course.path
      return
    includable_id = $scope.currentIncludable.includable_id
    includable_type = $scope.currentIncludable.includable_type

    # Shouldn't happen
    return if includable_type == "Assembly"

    # Keep route sync'ed up if changing not from an anchor
    if includable_type == 'Activity'
      newPath = "/" + $scope.currentIncludable.includable_slug
    else
      newPath = "/" + includable_type.toLowerCase() + "/" + $scope.currentIncludable.includable_slug
    $location.path(newPath) if $location.path() != newPath

    # Title tag
    document.title = $scope.currentIncludable.includable_title + ' | ' + $scope.course.title + ' Class | ChefSteps'

    console.log "switching to " + includable_type + ' with slug ' + includable_slug
    $scope.view_inclusion = includable_type
    $scope.view_inclusion_id = includable_id
    if includable_type == "Activity"
      $rootScope.$broadcast("loadActivityEvent", includable_id)
      $scope.updateDisqus()

    $scope.showCourseMenu = false
    $scope.collapsed = {}
    $scope.determineCollapsed($scope.currentIncludable)

    $scope.$broadcast 'scrollToTop'
    $scope.updateCanonical()

    # Absolutely insane fix to https://www.pivotaltracker.com/story/show/59025778
    # Vaguely inspired by http://mir.aculo.us/2009/01/11/little-javascript-hints-episode-3-force-redraw/, though
    # the actualy fix there didn't work for me. This bug was manifesting only on mobile webkit, and was clearly a redraw
    # issue because you could inspect the DOM and see the right content. It was only showing up doing prev/next into
    # or out of a quiz, so it probably has something to do with the iframe on those pages. Anyhow this seems to fix it.
    $timeout ->
      $('.prev-next-group').hide()
      $timeout ->
        $('.prev-next-group').show()

  $scope.overrideLoadActivityBySlug = (slug) ->
    incl = _.find($scope.flatInclusions, (incl) -> (incl.includable_slug == slug) || (incl.includable_id == parseInt(slug)))
    if incl
      $scope.loadInclusion(incl.includable_type, incl.includable_slug)
      return true
    false

  currentIncludableIndex = ->
    return 0 if ! $scope.flatInclusions?
    $scope.flatInclusions.indexOf($scope.currentIncludable)

  $scope.nextInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() + 1]

  $scope.prevInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() - 1]

  $scope.loadNextInclusion = ->
   $scope.loadInclusion($scope.nextInclusion().includable_type, $scope.nextInclusion().includable_slug)

  $scope.loadPrevInclusion = ->
   $scope.loadInclusion($scope.prevInclusion().includable_type, $scope.prevInclusion().includable_slug)

  lessThanOneMonthAgo = (stringDate) ->
    return false if ! stringDate
    d = new Date(stringDate)
    now = new Date()
    return true if (now - d) < (30 * 24 * 60 * 60 * 1000)

  # True if the course is old and the activity is new
  leafIncludableNew = (course, inclusion) ->
    ! lessThanOneMonthAgo(course.published_at) && lessThanOneMonthAgo(inclusion?.includable?.published_at)

  $scope.sortInclusions = (assembly) ->
    flat = []
    for inclusion in assembly.assembly_inclusions
      if inclusion.includable_type == 'Assembly'
        $scope.collapsed[inclusion.includable_id] = true
        $scope.collapsibleInclusions.push(inclusion)
        inclusion.isNew = false
        for sub in $scope.sortInclusions(inclusion.includable)
          sub.isNew = leafIncludableNew($scope.course, sub)
          inclusion.isNew = inclusion.isNew || sub.isNew
          flat.push(sub)
      else
        inclusion.isNew = leafIncludableNew($scope.course, inclusion)
        flat.push(inclusion)
    $scope.flatInclusions = flat

  $scope.inclusionActiveClass = (inclusion) ->
    return 'active' if (inclusion.includable_type == $scope.view_inclusion) && (inclusion.includable_id == $scope.view_inclusion_id)
    return ''

  # Class Navigation Behavior
  $scope.toggleShowCourseMenu = ->
    $scope.showCourseMenu = ! $scope.showCourseMenu
    # First collapse all
    $scope.collapsed = {}
    $scope.determineCollapsed($scope.currentIncludable)

  $scope.determineCollapsed = (inclusion)->
    $scope.collapsed[inclusion.assembly_id] = false
    # If Assembly is nested
    parent_inclusion = _.find($scope.collapsibleInclusions, (incl) -> incl.includable_id == inclusion.assembly_id && incl.includable_type == 'Assembly')
    $scope.determineCollapsed(parent_inclusion) if parent_inclusion

  $scope.toggleCollapse = (includable_id) ->

    $scope.collapsed[includable_id] ?= true
    $scope.collapsed[includable_id] = ! $scope.collapsed[includable_id]

  $scope.isCollapsed = (includable_id) ->
    if $scope.collapsed[includable_id]?
      return $scope.collapsed[includable_id]
    else
      true

  # Global Navigation Behavior
  $scope.$on 'showGlobalNavChanged', (e) ->
    $scope.showGlobalNav = e.targetScope.showNav
    $scope.$apply()

  $scope.$on 'showBottomChanged', (e) ->
    $scope.showBottomNav = e.targetScope.showBottom
    $scope.$apply()

  # Always show course nav on large screens
  angular.element($window).on 'resize', ->
    if $window.innerWidth >= 1024
      $scope.largeScreen = true
      $scope.showCourseMenu = false
    else
      $scope.largeScreen = false

  $scope.updateCanonical = ->
    canonical = angular.element('head').find("link[rel='canonical']")
    link = canonical.attr('href') + $scope.includable_slug
    canonical.attr('href', link)

  # Disqus
  $scope.updateDisqus = ->
    # Super gross. Was running into an issue where this could get called before DISQUS was loaded, fail, and
    # leave the user commenting on a bogus thread.
    if ! DISQUS?
      $timeout (->
        $scope.updateDisqus()
      ), 500
      return

    # Update to correct disqus view
    if $scope.currentIncludable?.include_disqus
      if $scope.course.id == 3
        # Hack for French Macaron Class Discussion page
        pageURL = "/classes/3#!/discussion"
        pageID = "class-activity-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
      else if $scope.course.id == 29
        # Hack for Vegetable Demi Discussion page
        pageURL = "/recipe-development/vegetable-demi-glace#/vegetable-demi-discussion"
        pageID = "class-activity-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
      else
        pageURL = "/classes/#{$scope.course.id}/#!#{$scope.currentIncludable.includable_slug}"
        pageID = "assembly-inclusion-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
      DISQUS.reset
        reload: true
        config: ->
          @page.identifier = pageID
          @page.url = pageURL
]
