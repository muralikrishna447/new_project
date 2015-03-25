@app.controller 'csBannerController', ['$scope', ($scope) ->
  $scope.banner = {}

  $scope.banner.dismissed = false

  $scope.dismiss = ->
    $scope.banner.dismissed = true

]

@app.controller 'csBannerSignupController', ['$scope', ($scope) ->
  $scope.signup = ->
    $scope.$emit 'openLoginModal'
]