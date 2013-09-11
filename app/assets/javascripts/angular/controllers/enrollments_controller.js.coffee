angular.module('ChefStepsApp').controller 'EnrollmentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->

  $scope.init = (enrollable_type, enrollable_id, current_user_present, current_user_enrolled) ->
    $scope.enrollable_type = enrollable_type
    $scope.enrollable_id = enrollable_id
    $scope.current_user_present = current_user_present
    $scope.current_user_enrolled = current_user_enrolled

    $scope.Enrollment = $resource('/' + $scope.enrollable_type + '/' + $scope.enrollable_id + '/enrollments')
    $scope.enrollments = $scope.Enrollment.query(->

    )

  $scope.enroll = () ->
    new_enrollment = new $scope.Enrollment
    new_enrollment.$save (data, success) ->
      if success
        $scope.current_user_enrolled = true

]