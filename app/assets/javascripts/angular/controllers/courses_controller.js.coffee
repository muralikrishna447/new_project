angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', ($rootScope, $scope, $resource, $http) ->
  
  $scope.view_inclusion = {}
  $scope.collapsed = {}
 
  $scope.init = (course_id) ->
    $http.get('/courses/' + course_id + '/show_as_json').success (data, status) ->
      $scope.course = data
      console.log $scope.course.assembly_inclusions
      console.log $scope.course.assembly_inclusions[0].includable_id
      addUploadToEnd()
      $scope.flatInclusions = $scope.computeflatVisibleInclusions($scope.course.assembly_inclusions)
      $scope.loadInclusion($scope.flatInclusions[0].includable_id)

  $scope.loadInclusion = (includable_id) ->
    $scope.currentIncludable = _.find($scope.flatInclusions, (incl) -> incl.includable_id == includable_id)
    if ! $scope.currentIncludable?
      console.log "Couldn't find id " + includable_id
      return
    includable_type = $scope.currentIncludable.includable_type
    return if includable_type == "Assembly"

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
    $scope.showCourseMenu = false

    # So sue me
    window.scrollTo(0, 0)

  $scope.overrideLoadActivity = (id) ->
    if _.find($scope.flatInclusions, (incl) -> incl.includable_id == id)
      $scope.loadInclusion(id) 
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
    $scope.collapsed[includable_id] ?= false
    $scope.collapsed[includable_id] = ! $scope.collapsed[includable_id] 

  $scope.isCollapsed = (includable_id) ->
    $scope.collapsed[includable_id]

  addUploadToEnd = ->
    # Special treatment for upload - put it at end of syllabus or end of last group
    dummy_upload = {"includable_id" : "Upload", "includable_type" : "Upload", "includable_title" : "Upload Your Own"}
    last_inclusion = $scope.course.assembly_inclusions[$scope.course.assembly_inclusions.length - 1]
    if last_inclusion.includable_type == "Assembly"
      last_inclusion.includable.assembly_inclusions.push(dummy_upload)
    else
      $scope.course.assembly_inclusions.push()
]