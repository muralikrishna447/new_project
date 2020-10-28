angular.module('ChefStepsApp').controller 'LikesController', ["$scope", "$resource", "$location", "$http", "csAlertService", "csAuthentication", "$window", ($scope, $resource, $location, $http, csAlertService, csAuthentication, $window) ->


  $scope.current_user_likes = false
  $scope.showAlert = true

  $scope.likeObject = (likeable_type, likeable_id) ->
    if ! csAuthentication.loggedIn()
      csAlertService.addAlert({message: "<a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to like this.", type: "error"}) if $scope.showAlert
      return

    url = "/likes?likeable_type=#{likeable_type}&likeable_id=#{likeable_id}"
    $scope.current_user_likes = true
    $scope.getObject().likes_count += 1

    $http(
      method: 'POST'
      url: url
    )


  $scope.unlikeObject = (likeable_type, likeable_id) ->
    url = "/likes/unlike?likeable_type=#{likeable_type}&likeable_id=#{likeable_id}"
    $scope.current_user_likes = false
    $scope.getObject().likes_count -= 1

    $http(
      method: 'POST'
      url: url
    )

  $scope.toggleLikeObject = (likeable_type, likeable_id) ->
    if $scope.current_user_likes
      $scope.unlikeObject(likeable_type, likeable_id)
    else
      $scope.likeObject(likeable_type, likeable_id)

  $scope.getCurrentUserLikes = (likeable_type, likeable_id) ->
    # No hurry, do this after the whole document and images are ready
    $($window).load ->
      url = '/likes/by_user?likeable_type=' + likeable_type + '&likeable_id=' + likeable_id
      console.log url
      $http(
        method: 'GET'
        url: url
      ).success((data, status, headers, config) ->
        if data && data[0] == true
          $scope.current_user_likes = true
      )
    true

]
