@app.controller 'PlaygroundController', ['$scope', 'api.activity', 'api.search', ($scope, Activity, Search) ->
  $scope.activities = Activity.query()

  $scope.search = (input) ->
    console.log 'Search input was: ', input
    Search.query({query: input, page: 1}).$promise.then (results) ->
      $scope.activities = results
    
]