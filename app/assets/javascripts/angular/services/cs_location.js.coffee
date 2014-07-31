@app.controller 'csLocationController', ['$scope','$http', ($scope, $http) ->
  $scope.getPredictions = (input) ->
    url = "/locations/autocomplete?input=#{input}"
    console.log "URL IS: ", url
    $http.get(url).then (response) ->
      predictions = []
      angular.forEach response.data.predictions, (item) ->
        predictions.push(item.description)
      $scope.predictions = predictions
]