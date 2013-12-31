angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', '$route', '$routeParams', '$location', "$timeout", ($rootScope, $scope, $resource, $http, $route, $routeParams, $location, $timeout) ->

  $scope.routeParams = $routeParams
  $scope.route = $route

  # $scope.$on "$routeChangeSuccess", ($currentRoute, $previousRoute) ->
  #   $scope.overrideLoadActivityBySlug($scope.routeParams.slug)
  
  $scope.view_inclusion = {}
  $scope.collapsed = {}
 
  $scope.init = (course_id) ->
    $http.get('/classes/' + course_id + '/show_as_json').success (data, status) ->
      $scope.course = data
      console.log $scope.course.assembly_inclusions
      console.log $scope.course.assembly_inclusions[0].includable_id
      # $scope.flatInclusions = $scope.computeflatVisibleInclusions(null, $scope.course.assembly_inclusions)
      $scope.flatInclusions = $scope.computeFlatInclusions($scope.course)
      console.log $scope.flatInclusions
      $scope.includable_type = $scope.routeParams.includable_type
      $scope.includable_slug = $scope.routeParams.slug
      if $scope.routeParams.slug
        $scope.loadInclusion('Activity', $scope.includable_slug)
      else
        $scope.loadInclusion($scope.includable_type, $scope.includable_slug)

  $scope.toggleShowCourseMenu = ->
    $scope.showCourseMenu = ! $scope.showCourseMenu

    # Collapse all groups ... but 
    $scope.collapsed = {} if $scope.showCourseMenu

    # ... make sure the group containing the currently active leaf is open
    # TODO: This actually needs to be recursive, but can get away with this for macarons.
    if $scope.currentIncludable
      parent = $scope.currentIncludable
      while parent
        $scope.collapsed[parent.includable_id] = false
        parent = parent.parent

  $scope.loadInclusion = (includable_type, includable_slug) ->
    $scope.currentIncludable = _.find($scope.flatInclusions, (incl) -> incl.includable_slug == includable_slug && incl.includable_type == includable_type)
    console.log "INCLUDABLE: " + $scope.currentIncludable
    if ! $scope.currentIncludable?
      console.log "Couldn't find " + includable_type + " with slug " + includable_slug
      return
    includable_id = $scope.currentIncludable.includable_id
    includable_type = $scope.currentIncludable.includable_type

    # Shouldn't happen
    return if includable_type == "Assembly"

    # Keep route sync'ed up if changing not from an anchor
    if includable_type == 'Activity'
      newPath = "/" + $scope.currentIncludable.includable_slug
    else
      newPath = "/" + includable_type + "/" + $scope.currentIncludable.includable_slug
    $location.path(newPath) if $location.path() != newPath

    # Title tag
    document.title = $scope.currentIncludable.includable_title + ' - ' + $scope.course.title + ' Class - ChefSteps'

    console.log "switching to " + includable_type + ' with slug ' + includable_slug
    $scope.view_inclusion = includable_type
    $scope.view_inclusion_id = includable_id
    if includable_type == "Activity"
      $rootScope.$broadcast("loadActivityEvent", includable_id)
      $scope.updateDisqus()

    mixpanel.track($scope.currentIncludable.includable_type + ' Viewed Within Class', {'title': $scope.currentIncludable.includable_title, 'class': $scope.course.title})

    $scope.showCourseMenu = false

    # So sue me
    window.scrollTo(0, 0)

    # Absolutely insane fix to https://www.pivotaltracker.com/story/show/59025778
    # Vaguely inspired by http://mir.aculo.us/2009/01/11/little-javascript-hints-episode-3-force-redraw/, though
    # the actualy fix there didn't work for me. This bug was manifesting only on mobile webkit, and was clearly a redraw
    # issue because you could inspect the DOM and see the right content. It was only showing up doing prev/next into
    # or out of a quiz, so it probably has something to do with the iframe on those pages. Anyhow this seems to fix it.
    $timeout ->
      $('.prev-next-group').hide()
      $timeout ->
        $('.prev-next-group').show()

  $scope.inclusionActiveClass = (inclusion) ->
    return 'active' if (inclusion.includable_type == $scope.view_inclusion) && (inclusion.includable_id == $scope.view_inclusion_id)
    return ''

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
        pageURL = "http://chefsteps.com/classes/3#!/discussion"
        pageID = "class-activity-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
      else
        pageURL = "http://chefsteps.com/classes/#{$scope.course.id}/#!#{$scope.currentIncludable.includable_slug}"
        pageID = "assembly-inclusion-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
      DISQUS.reset
        reload: true
        config: ->
          @page.identifier = pageID
          @page.url = pageURL

  $scope.overrideLoadActivity = (id) ->
    if _.find($scope.flatInclusions, (incl) -> incl.includable_id == id)
      $scope.loadInclusion(id) 
      return true
    false

  # $scope.overrideLoadActivityBySlug = (slug) ->
  #   incl = _.find($scope.flatInclusions, (incl) -> incl.includable_slug == slug)
  #   if incl
  #     $scope.loadInclusion('Activity', incl.includable_id) 
  #     return true
  #   false

  currentIncludableIndex = ->
    return 0 if ! $scope.flatInclusions?
    $scope.flatInclusions.indexOf($scope.currentIncludable)
    # for incl, idx in $scope.flatInclusions
    #   return idx if incl.includable_id == $scope.currentIncludable.includable_id

  $scope.nextInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() + 1]

  $scope.prevInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() - 1]

  $scope.loadNextInclusion = ->
   $scope.loadInclusion($scope.nextInclusion().includable_type, $scope.nextInclusion().includable_slug) 

  $scope.loadPrevInclusion = ->
   $scope.loadInclusion($scope.prevInclusion().includable_type, $scope.prevInclusion().includable_slug) 

  $scope.computeFlatInclusions = (assembly) ->
    result = []
    for inclusion in assembly.assembly_inclusions
      if inclusion.includable_type == 'Assembly'
        result.push(sub) for sub in $scope.computeFlatInclusions(inclusion.includable)
      else
        result.push(inclusion)
    result

  $scope.toggleCollapse = (includable_id) ->
    $scope.collapsed[includable_id] ?= true
    $scope.collapsed[includable_id] = ! $scope.collapsed[includable_id] 

  $scope.isCollapsed = (includable_id) ->
    if $scope.collapsed[includable_id]? 
      return $scope.collapsed[includable_id] 
    else 
      true
]