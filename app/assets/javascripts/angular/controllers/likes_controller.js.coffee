angular.module('ChefStepsApp').controller 'LikesController', ["$scope", "$resource", "$location", "$http", ($scope, $resource, $location, $http) ->
  
  $scope.likeObject = (likeable_type, likeable_id) ->
    url = '/likes?likeable_type=' + likeable_type + '&likeable_id=' + likeable_id
    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
      $scope.current_user_likes = true
    )
]