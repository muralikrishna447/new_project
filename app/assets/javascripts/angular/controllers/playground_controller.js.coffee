@app.controller 'PlaygroundController', ['$scope', 'api.activity', 'api.search', ($scope, Activity, Search) ->
  $scope.activities = Activity.query()

  $scope.search = (input) ->
    console.log 'Search input was: ', input
    if input.length > 1
      Activity.query({search_all: input, page: 1}).$promise.then (results) ->
        $scope.activities = results
    
]