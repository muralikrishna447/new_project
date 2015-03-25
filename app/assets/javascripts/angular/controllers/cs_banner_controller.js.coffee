@app.controller 'csBannerController', ['$scope', ($scope) ->
  $scope.banner = {}

  $scope.banner.dismissed = false

  $scope.dismiss = ->
    $scope.banner.dismissed = true
]