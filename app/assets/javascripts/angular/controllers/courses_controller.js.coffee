angular.module('ChefStepsApp').controller 'CoursesController', ['$scope', '$resource', '$http', 'cs_event', ($scope, $resource, $http, cs_event) ->
  
  $scope.view_inclusion = {}

  $scope.init = (course_id) ->
    $http.get('/courses/' + course_id + '/show_as_json').success (data, status) ->
      $scope.course = data
      console.log $scope.course.assembly_inclusions
      console.log $scope.course.assembly_inclusions[0].includable_id
      $scope.view_inclusion = 'Activity_' + $scope.course.assembly_inclusions[0].includable_id
      $scope.view_inclusion_id = $scope.course.assembly_inclusions[0].includable_id

  $scope.load_inclusion = (includable_type, includable_id) ->
    # console.log "switching to " + includable_type + 'with id ' + includable_id
    # $scope.view_inclusion.type = includable_type
    # $scope.view_inclusion.id = includable_id
    if includable_id
      $scope.view_inclusion = [includable_type, includable_id].join('_')
      $scope.view_inclusion_id = includable_id
    else
      $scope.view_inclusion = includable_type
]