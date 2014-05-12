angular.module('ChefStepsApp').controller 'LikesController', ["$scope", "$resource", "$location", "$http", "csAlertService", ($scope, $resource, $location, $http, csAlertService) ->

  $scope.showAlert = true

  $scope.likeObject = (likeable_type, likeable_id) ->
    url = '/likes?likeable_type=' + likeable_type + '&likeable_id=' + likeable_id
    $http(
      method: 'POST'
      url: url
    ).success((data, status, headers, config) ->
      $scope.current_user_likes = true
      $scope.likes_count += 1
      mixpanel.track('Liked', {'Activity': likeable_type + "_" + likeable_id})
      mixpanel.people.set('Liked':likeable_type + "_" + likeable_id)
      mixpanel.people.increment('Liked Count')
      $http.get('/splitty/finished?experiment=recommended_vs_curated')

      # TODO will eventually need to angularize the alert notification system and use csAuthentification
      csAlertService.alerts = []
      if data.length > 0
        csAlertService.addAlert({message: "You liked this!", type: "success"}) if $scope.showAlert
      else
        csAlertService.addAlert({message: "<a href='/sign_up'>Create an account</a> or <a href='/sign_in'>sign in</a> to like this.", type: "error"}) if $scope.showAlert
    )

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