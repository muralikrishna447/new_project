@app.controller 'PlaygroundController', ['$scope', 'api.activity', 'api.search', ($scope, Activity, Search) ->

  $scope.filters = {}
  # $scope.defaultFilters = {}
  $scope.defaultFilters = {
    'published':true
    'generator':"chefsteps"
    'sort':"newest"
  }
  # $scope.defaultFilters.published = true
  # $scope.defaultFilters.generator = 'chefsteps'
  # $scope.defaultFilters.sort = 'newest'

  Activity.query($scope.defaultFilters).$promise.then (results) ->
    console.log 'default filters: ', $scope.defaultFilters
    $scope.activities = results

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
    if newValue != oldValue
      $scope.updateFilter()
    
]