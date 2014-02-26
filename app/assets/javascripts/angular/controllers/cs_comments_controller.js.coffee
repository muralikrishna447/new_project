@app.controller 'csCommentsController', ["$scope", "Session", "csAuthentication", ($scope, Session, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()

  # Session.me = 'xmichael'
  $scope.getName = ->
    console.log $scope.currentUser.name

  $scope.getAvatarUrl = ->
    console.log $scope.currentUser.image_id

  $scope.getMe = ->
    console.log $scope.currentUser.id

  $scope.getName()
  $scope.getAvatarUrl()
  $scope.getMe()

]