angular.module('ChefStepsApp').controller 'EnrollmentsController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->

  $scope.init = (enrollable_type, enrollable_id, signed_in, current_user_enrolled, enrollable_url, last_viewed_activity, completed) ->
    $scope.enrollable_type = enrollable_type
    $scope.enrollable_id = enrollable_id
    $scope.signed_in = signed_in
    $scope.current_user_enrolled = current_user_enrolled
    $scope.enrollable_url = enrollable_url
    $scope.last_viewed_activity = last_viewed_activity
    $scope.completed = completed

    $scope.Enrollment = $resource('/' + $scope.enrollable_type + '/' + $scope.enrollable_id + '/enrollments')
    $scope.enrollments = $scope.Enrollment.query(->

    )

  $scope.enroll = () ->
    new_enrollment = new $scope.Enrollment
    new_enrollment.$save (data, success) ->
      if success
        $scope.current_user_enrolled = true

  $scope.sign_in = ->
    window.location = '/sign_in?notice=' + encodeURIComponent("Please sign in or sign up before enrolling.")

]