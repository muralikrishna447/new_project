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

  # Load the first page
  Activity.query($scope.params).$promise.then (results) ->
    $scope.activities = results
    $location.search($scope.params)

  $scope.search = (input) ->
    if input.length > 1
      $scope.params.search_all = input

  $scope.applyFilter = ->
    console.log 'applyFilter'
    $scope.params['published_status'] = $scope.filters['published_status']
    $scope.params['generator'] = $scope.filters['generator']
    $scope.params['sort'] = $scope.filters['sort']
    delete $scope.params['page']
    $scope.activities = []
    $scope.getActivities()

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    console.log newValue
    console.log oldValue
    if newValue != oldValue
      $scope.applyFilter()

  $scope.getActivities = ->
    $scope.dataLoading = true
    Activity.query($scope.params).$promise.then (results) ->
      angular.forEach results, (result) ->
        $scope.activities.push(result)
      $location.search($scope.params)
      $scope.dataLoading = false

  $scope.next = ->
    console.log 'loading next'
    if $scope.params['page'] && $scope.params['page'] >= 1
      $scope.params['page'] += 1
    else
      $scope.params['page'] = 2
    $scope.getActivities()
    
]