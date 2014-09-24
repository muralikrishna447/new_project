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
    console.log 'updateFilter'
    Activity.query($scope.filters).$promise.then (results) ->
      $scope.activities = results
      $location.search($scope.filters)

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    console.log newValue
    console.log oldValue
    if newValue != oldValue
      $scope.updateFilter()

  $scope.dataLoading = false
  $scope.addMoreActivities = ->
  
    if $scope.dataLoading == false
      $scope.dataLoading = true
      console.log 'Adding more activities'
      params = $scope.filters
      if params['page'] && parseInt(params['page']) > 0
        page = parseInt(params['page'])
        params['page'] = page + 1
      else
        params['page'] = 1
      Activity.query(params).$promise.then (results) ->
        # console.log $scope.activities
        # $scope.activities.concat(results)
        angular.forEach results, (result) ->
          $scope.activities.push(result)


        $location.search($scope.filters)
        $scope.dataLoading = false
        # console.log $scope.activities
    
]