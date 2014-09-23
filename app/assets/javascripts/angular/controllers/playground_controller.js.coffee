@app.controller 'PlaygroundController', ['$scope', '$location', 'api.activity', 'api.search', ($scope, $location, Activity, Search) ->

  defaultFilters = {
    'published_status':'published'
    'generator':"chefsteps"
    'sort':"newest"
  }

  # If the url contains filter parameters then use those.  If not then use the default filters.
  params = $location.search()
  keys = Object.keys(params)
  if keys.length == 0
    params = defaultFilters

  $scope.filters = params

  # Load the first page
  Activity.query($scope.filters).$promise.then (results) ->
    $scope.activities = results
    $location.search($scope.filters)

  $scope.search = (input) ->
    if input.length > 1
      $scope.filters.search_all = input

  $scope.updateFilter = ->
    Activity.query($scope.filters).$promise.then (results) ->
      $scope.activities = results
      $location.search($scope.filters)

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.updateFilter()
    
]