@app.controller 'PlaygroundController', ['$scope', 'api.activity', 'api.search', ($scope, Activity, Search) ->
  $scope.filters = {}
  $scope.activities = Activity.query()

  $scope.search = (input) ->
    if input.length > 1
      $scope.filters.search_all = input
    # console.log 'Search input was: ', input
    # if input.length > 1
    #   Activity.query({search_all: input}).$promise.then (results) ->
    #     $scope.activities = results

  $scope.updateFilter = ->
    Activity.query($scope.filters).$promise.then (results) ->
      $scope.activities = results

  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    console.log 'old value: ', oldValue
    console.log 'new value: ', newValue
    $scope.updateFilter()
    
]