

angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', '$route', '$routeParams', '$location', "$timeout", ($rootScope, $scope, $resource, $http, $route, $routeParams, $location, $timeout) ->


  $scope.routeParams = $routeParams
  $scope.route = $route

  $scope.$on "$routeChangeSuccess", ($currentRoute, $previousRoute) ->
    $scope.overrideLoadActivityBySlug($scope.routeParams.slug)
  
  $scope.view_inclusion = {}
  $scope.collapsed = {}
 
  $scope.init = (course_id) ->
    $http.get('/classes/' + course_id + '/show_as_json').success (data, status) ->
      $scope.course = data
      console.log $scope.course.assembly_inclusions
      console.log $scope.course.assembly_inclusions[0].includable_id
      addUploadToEnd()
      $scope.flatInclusions = $scope.computeflatVisibleInclusions($scope.course.assembly_inclusions)
      if $scope.routeParams.slug
        $scope.overrideLoadActivityBySlug($scope.routeParams.slug)
      else
        $scope.loadInclusion($scope.flatInclusions[0].includable_id)

  $scope.toggleShowCourseMenu = ->
    $scope.showCourseMenu = ! $scope.showCourseMenu

    # Collapse all groups ... but 
    $scope.collapsed = {} if $scope.showCourseMenu

    # ... make sure the group containing the currently active leaf is open
    # TODO: This actually needs to be recursive, but can get away with this for macarons.
    if $scope.currentIncludable
      for top_incl in $scope.course.assembly_inclusions
        if top_incl.includable_type == "Assembly"
          if _.where(top_incl.includable.assembly_inclusions, {includable_id: $scope.currentIncludable.includable_id}).length
            $scope.collapsed[top_incl.includable_id] = false

  $scope.loadInclusion = (includable_id) ->
    return if $scope.currentIncludable?.includable_id == includable_id
    $scope.currentIncludable = _.find($scope.flatInclusions, (incl) -> incl.includable_id == includable_id)
    if ! $scope.currentIncludable?
      console.log "Couldn't find id " + includable_id
      return
    includable_type = $scope.currentIncludable.includable_type

    # Shouldn't happen
    return if includable_type == "Assembly"

    # Keep route sync'ed up if changing not from an anchor
    newPath = "/" + $scope.currentIncludable.includable_slug
    $location.path(newPath) if $location.path() != newPath

    # Title tag
    document.title = $scope.currentIncludable.includable_title + ' - ' + $scope.course.title + ' Class - ChefSteps'

    console.log "switching to " + includable_type + ' with id ' + includable_id
    switch includable_type
      when 'Upload'
        $scope.view_inclusion = 'Upload'
      else
        $scope.view_inclusion = includable_type
        $scope.view_inclusion_id = includable_id
        if includable_type == "Activity"
          $rootScope.$broadcast("loadActivityEvent", includable_id)
          $scope.updateDisqus()

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
      DISQUS.reset
        reload: true
        config: ->
          @page.identifier = "class-activity-" + $scope.currentIncludable.includable_type + "-" + $scope.currentIncludable.includable_id
          @page.url = "http://chefsteps.com/classes/#{$scope.course.id}#!/#{$scope.currentIncludable.includable_slug}"

  $scope.overrideLoadActivity = (id) ->
    if _.find($scope.flatInclusions, (incl) -> incl.includable_id == id)
      $scope.loadInclusion(id) 
      return true
    false

  $scope.overrideLoadActivityBySlug = (slug) ->
    incl = _.find($scope.flatInclusions, (incl) -> incl.includable_slug == slug)
    if incl
      $scope.loadInclusion(incl.includable_id) 
      return true
    false

  currentIncludableIndex = ->
    return 0 if ! $scope.flatInclusions?
    for incl, idx in $scope.flatInclusions
      return idx if incl.includable_id == $scope.currentIncludable.includable_id

  $scope.nextInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() + 1]

  $scope.prevInclusion = ->
    $scope.flatInclusions?[currentIncludableIndex() - 1]

  $scope.loadNextInclusion = ->
   $scope.loadInclusion($scope.nextInclusion().includable_id) 

  $scope.loadPrevInclusion = ->
   $scope.loadInclusion($scope.prevInclusion().includable_id) 

  $scope.computeflatVisibleInclusions = (inclusions) ->
    result = []
    for incl in inclusions
      if incl.includable_type != "Assembly"
        result.push(incl)
      else
        result.push(sub) for sub in $scope.computeflatVisibleInclusions(incl.includable.assembly_inclusions)
    result

  $scope.toggleCollapse = (includable_id) ->
    $scope.collapsed[includable_id] ?= true
    $scope.collapsed[includable_id] = ! $scope.collapsed[includable_id] 

  $scope.isCollapsed = (includable_id) ->
    if $scope.collapsed[includable_id]? 
      return $scope.collapsed[includable_id] 
    else 
      true

  addUploadToEnd = ->
    # Special treatment for upload - put it at end of last group
    dummy_upload = {"includable_id" : "Upload", "includable_type" : "Upload", "includable_title" : "Upload Your Own", "includable_slug" : "upload"}
    last_group = _.last(_.where($scope.course.assembly_inclusions, {includable_type: "Assembly"}))
    if last_group
      last_group.includable.assembly_inclusions.push(dummy_upload)
    else
      $scope.course.assembly_inclusions.push(dummy_upload)
]