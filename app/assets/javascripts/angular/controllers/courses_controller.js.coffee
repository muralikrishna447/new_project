angular.module('ChefStepsApp').controller 'CoursesController', ['$scope', '$resource', 'cs_event', ($scope, $resource, cs_event) ->
  
  $scope.init = (course_id) ->
    $scope.course = $resource('/courses/:id/show_as_json', {'id': course_id})
    $scope.course_inclusions = $scope.course.query(->
      console.log $scope.course_inclusions
    )
]