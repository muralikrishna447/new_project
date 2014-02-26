@app.controller 'csCommentsController', ["$scope", "Session", "csAuthentication", ($scope, Session, csAuthentication) ->
  $scope.currentUser = csAuthentication.currentUser()

  # Session.me = 'xmichael'
  $scope.getName = ->
    console.log $scope.currentUser.name

  $scope.getAvatarUrl = ->
    imageId = JSON.parse($scope.currentUser.image_id)
    imageUrl = imageId.url.replace("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
    console.log imageUrl

  $scope.getMe = ->
    console.log $scope.currentUser.id

  $scope.getName()
  $scope.getAvatarUrl()
  $scope.getMe()

]