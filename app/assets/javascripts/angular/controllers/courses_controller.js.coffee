angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', ($rootScope, $scope, $resource, $http) ->
  
  $scope.view_inclusion = {}
  $scope.collapsed = {}
 
  $scope.init = (course_id) ->
    $http.get('/courses/' + course_id + '/show_as_json').success (data, status) ->
      $scope.course = data
      console.log $scope.course.assembly_inclusions
      console.log $scope.course.assembly_inclusions[0].includable_id
      $scope.load_inclusion($scope.course.assembly_inclusions[0].includable_type, $scope.course.assembly_inclusions[0].includable_id)

  $scope.load_inclusion = (includable_type, includable_id) ->
    return if includable_type == "Assembly"
    console.log "switching to " + includable_type + 'with id ' + includable_id
    # $scope.view_inclusion.type = includable_type
    # $scope.view_inclusion.id = includable_id
    switch includable_type
      when 'Quiz'
        $scope.view_inclusion = [includable_type, includable_id].join('_')
        $scope.view_inclusion_id = includable_id
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

  $scope.toggleCollapse = (includable_id) ->
    $scope.collapsed[includable_id] ?= false
    $scope.collapsed[includable_id] = ! $scope.collapsed[includable_id] 

  $scope.isCollapsed = (includable_id) ->
    $scope.collapsed[includable_id]

]