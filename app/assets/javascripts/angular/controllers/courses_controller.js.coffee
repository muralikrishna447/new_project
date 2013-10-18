

angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', '$route', '$routeParams', '$location', ($rootScope, $scope, $resource, $http, $route, $routeParams, $location) ->


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

    # Title tag
    document.title = $scope.currentIncludable.includable_title + ' - ' + $scope.course.title + ' Class - ChefSteps'

    # Keep route sync'ed up if changing not from an anchor
    newPath = "/" + $scope.currentIncludable.includable_slug
    $location.path(newPath) if $location.path() != newPath


    console.log "switching to " + includable_type + 'with id ' + includable_id
    switch includable_type
      when 'Upload'
        $scope.view_inclusion = 'Upload'
      else
        $scope.view_inclusion = includable_type
        $scope.view_inclusion_id = includable_id
        if includable_type == "Activity"
          console.log 'Broadcasting'
          $rootScope.$broadcast("loadActivityEvent", includable_id)
          console.log 'Done Broadcasting'

          # I couldn't get this to work, so for now if you set "include_disqus" on more than one activity in a
          # course, they will all share the same comments. Sucks, but ok for our current use case. 
          # Maybe disqus is looking at window.location, not
          # the @page.url I'm passing it, in which case it will work once deep linking is really there.
          if $scope.currentIncludable.include_disqus
            DISQUS.reset
              reload: true
              config: ->
                @page.identifier = "course-activity-" + includable_id
                @page.url = "http://chefsteps.com/courses/#{$scope.course.id}#!/#{$scope.currentIncludable.includable_id}"
    $scope.showCourseMenu = false

    # So sue me
    window.scrollTo(0, 0)

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
    # Special treatment for upload - put it at end of syllabus or end of last group
    dummy_upload = {"includable_id" : "Upload", "includable_type" : "Upload", "includable_title" : "Upload Your Own", "includable_slug" : "upload"}
    last_inclusion = $scope.course.assembly_inclusions[$scope.course.assembly_inclusions.length - 2]
    if last_inclusion.includable_type == "Assembly"
      last_inclusion.includable.assembly_inclusions.push(dummy_upload)
    else
      $scope.course.assembly_inclusions.push()
]