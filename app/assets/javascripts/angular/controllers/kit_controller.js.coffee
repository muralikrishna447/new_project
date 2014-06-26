@app.controller 'KitController', ['$scope', '$http', ($scope, $http) ->
  $scope.kit = {}
  
  $scope.loadKit = ->
    $http.get('/kits/pastrami-box/show_as_json').then (response) ->
      $scope.kit = response.data
]