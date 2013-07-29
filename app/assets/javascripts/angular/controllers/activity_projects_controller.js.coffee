angular.module('ChefStepsApp').controller 'ActivityProjectsController', ["$scope", "$resource", ($scope, $resource) ->

  $scope.init = (activity_id) ->
    $scope.activity_id = activity_id

    $scope.Activity = $resource('/activities/' + $scope.activity_id + '/as_json')
    $scope.activity = $scope.Activity.get()

]