angular.module('ChefStepsApp').controller 'LikesController', ["$scope", "$resource", "$location", "$http", "csAlertService", ($scope, $resource, $location, $http, csAlertService) ->

  $scope.current_user_likes = false
  
  $scope.likeObject = (likeable_type, likeable_id) ->
    url = "/likes?likeable_type=#{likeable_type}&likeable_id=#{likeable_id}"
    $scope.current_user_likes = true
    $scope.activity.likes_count += 1

    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
        mixpanel.track('Liked', {'Activity': likeable_type + "_" + likeable_id})
        mixpanel.people.set('Liked':likeable_type + "_" + likeable_id)
        mixpanel.people.increment('Liked Count')
        $http.get('/splitty/finished?experiment=recommended_vs_curated')
    )

  $scope.unlikeObject = (likeable_type, likeable_id) ->
    url = "/likes/unlike?likeable_type=#{likeable_type}&likeable_id=#{likeable_id}"
    $scope.current_user_likes = false
    $scope.activity.likes_count -= 1

    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
        mixpanel.track('Unliked', {'Activity': likeable_type + "_" + likeable_id})
        mixpanel.people.set('Liked':likeable_type + "_" + likeable_id)
        mixpanel.people.increment('Liked Count', - 1)
    )

  $scope.toggleLikeObject = (likeable_type, likeable_id) ->
    if $scope.current_user_likes
      $scope.unlikeObject(likeable_type, likeable_id)
    else
      $scope.likeObject(likeable_type, likeable_id)

  $scope.getCurrentUserLikes = (likeable_type, likeable_id) ->
    url = '/likes/by_user?likeable_type=' + likeable_type + '&likeable_id=' + likeable_id
    console.log url
    $http(
      method: 'GET'
      url: url
    ).success((data, status, headers, config) ->
      if data && data == 'true'
        $scope.current_user_likes = true
    )

]