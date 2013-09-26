angular.module('ChefStepsApp').controller 'CoursesController', ['$rootScope', '$scope', '$resource', '$http', 'cs_event', ($rootScope, $scope, $resource, $http, cs_event) ->
  
  $scope.view_inclusion = {}
 
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
    if includable_type == "Quiz"
      $scope.view_inclusion = [includable_type, includable_id].join('_')
      $scope.view_inclusion_id = includable_id
    else if includable_type == 'Upload'
      $scope.view_inclusion = 'Upload'
    else
      $scope.view_inclusion = includable_type
      $scope.view_inclusion_id = includable_id
      if includable_type == "Activity"
        $rootScope.$broadcast("loadActivityEvent", includable_id)
    $scope.showCourseMenu = false
    # So sue me
    window.scrollTo(0, 0)
]