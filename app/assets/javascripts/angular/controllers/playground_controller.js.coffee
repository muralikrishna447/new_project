@app.controller 'PlaygroundController', ['$scope', '$location', 'api.activity', 'api.search', ($scope, $location, Activity, Search) ->

  $scope.activities = []

  defaultFilters = {
    'published_status':'published'
    'generator':"chefsteps"
    'sort':"newest"
  }

  # If the url contains filter parameters then use those.  If not then use the default filters.
  $scope.params = $location.search()
  keys = Object.keys($scope.params)
  if keys.length == 0
    $scope.params = defaultFilters

  $scope.filters = {}
  $scope.filters['published_status'] = $scope.params['published_status']
  $scope.filters['generator'] = $scope.params['generator']
  $scope.filters['sort'] = $scope.params['sort']

  $scope.getActivities = ->
    Activity.query($scope.params).$promise.then (results) ->
      angular.forEach results, (result) ->
        $scope.activities.push(result)
      $location.search($scope.params)
      $scope.dataLoading = false

  $scope.search = (input) ->
    $scope.dataLoading = true
    delete $scope.params['sort']
    delete $scope.params['page']
    $scope.params['search_all'] = input
    $scope.activities = []
    $scope.getActivities()

  $scope.applyFilter = ->
    $scope.dataLoading = true
    $scope.params['published_status'] = $scope.filters['published_status']
    $scope.params['generator'] = $scope.filters['generator']
    $scope.params['sort'] = $scope.filters['sort']
    delete $scope.params['page']
    $scope.activities = []
    $scope.getActivities()

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  $scope.next = ->
    $scope.dataLoading = true
    if $scope.params['page'] && $scope.params['page'] >= 1
      $scope.params['page'] += 1
    else
      $scope.params['page'] = 2
    $scope.getActivities()

  # Load the first page
  $scope.getActivities()
    
]