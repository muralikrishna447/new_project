angular.module('ChefStepsApp').controller 'FollowershipsController', ["$scope", "$http", "csAuthentication", "csAlertService", "csDataLoading", "csFacebook", ($scope, $http, csAuthentication, csAlertService, csDataLoading, csFacebook) ->
  $scope.facebook = csFacebook
  $scope.dataLoading = csDataLoading
  $scope.authentication = csAuthentication

  $scope.searchFriends = null

  $scope.possibleFollowers = []

  $scope.$on "socialConnect", (event, eventData) ->
    $scope.gatherFriendsFromSocial()

  $scope.gatherFriendsFromSocial = ->
    $scope.dataLoading.start()
    if $scope.authentication.currentUser().facebook_user_id
      $scope.facebook.friends().then (friendsFromFacebook) ->
        $http(
          method: "POST"
          url: "/users/contacts/gather_friends.json"
          data:
            friends_from_facebook: friendsFromFacebook
        ).success( (data, status) ->
          # for user in data
          #   user.following = false
          $scope.possibleFollowers = data
          $scope.dataLoading.stop()
        ).error( (data, status) ->
          $scope.dataLoading.stop()
          console.log("Something went wrong!")
        )
    else
      $http(
        method: "POST"
        url: "/users/contacts/gather_friends.json"
        data:
          friends_from_facebook: []
      ).success( (data, status) ->
        # for user in data
        #   user.following = false
        $scope.possibleFollowers = data
        $scope.dataLoading.stop()
      ).error( (data, status) ->
        $scope.dataLoading.stop()
        console.log("Something went wrong!")
      )


  $scope.follow = (possibleFollower, following=true) ->
    $scope.dataLoading.start()
    possibleFollower.following = following
    $http(
      method: "PUT"
      url: "/followerships/#{possibleFollower.id}.json"
    ).success( (data, status) ->
      $scope.dataLoading.stop()
    ).error( (data, status) ->
      $scope.dataLoading.stop()
      console.log("Something went wrong!")
    )

  $scope.followMultiple = ->
    $http(
      method: "POST"
      url: "/followerships/follow_multiple.json"
      data:
        ids: _.map($scope.possibleFollowers, (follower) -> follower.id)
    ).success( (data, status) ->
      for user in data
        follower = _.find($scope.possibleFollowers, (possibleFollower) -> possibleFollower.id == user.id)
        follower.following = true if follower
    ).error( (data, status) ->
      $scope.dataLoading.stop()
      console.log("Something went wrong!")
    )

]