angular.module('ChefStepsApp').controller 'EnrollmentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->

  $scope.init = (enrollable_type, enrollable_id) ->
    $scope.enrollable_type = enrollable_type
    $scope.enrollable_id = enrollable_id

    $scope.Enrollment = $resource('/' + $scope.enrollable_type + '/' + $scope.enrollable_id + '/enrollments')
    $scope.enrollments = $scope.Enrollment.query(->

    ) 

]