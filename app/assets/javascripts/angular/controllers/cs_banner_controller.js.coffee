@app.controller 'csBannerController', ['$scope', ($scope) ->
  $scope.banner = {}

  $scope.banner.dismissed = false

  $scope.dismiss = ->
    $scope.banner.dismissed = true

]

@app.controller 'csBannerSignupController', ['$scope', 'csAuthentication', ($scope, csAuthentication) ->
  console.log "currentUser: ", csAuthentication.currentUser()
  $scope.includeBanner = !csAuthentication.currentUser()
  $scope.signup = ->
    $scope.$emit 'openLoginModal'
]