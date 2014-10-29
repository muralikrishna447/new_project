@app.controller 'GalleryController', ['$scope', '$location', '$timeout', 'api.activity', 'api.search', 'csAuthentication', ($scope, $location, $timeout, Activity, Search, csAuthentication) ->
  $scope.csAuthentication = csAuthentication
  $scope.activities = []

  $scope.showOptions = {}
  $scope.showOptions.filters = false
  $scope.showOptions.sort = false
  $scope.difficultyChoices = ["any", "easy", "intermediate", "advanced"]
  $scope.publishedStatusChoices = ["published", "unpublished"]
  $scope.generatorChoices = ["chefsteps", "community"]
  $scope.sortChoices = ["newest", "oldest", "popular"]


  defaultFilters = {
    'difficulty':'any'
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
  $scope.filters['difficulty'] = $scope.params['difficulty']

  $scope.getActivities = ->
    $scope.params['page'] = $scope.page
    if $scope.params['difficulty']
      if $scope.params['difficulty'] == 'undefined'
        delete $scope.params['difficulty']
    Activity.query($scope.params).$promise.then (results) ->
      if results.length > 0
        angular.forEach results, (result) ->
          $scope.activities.push(result)
        delete $scope.params['page']
        $location.search($scope.params)
      $scope.dataLoading = false

  # Search only fires after the user stops typing
  # Seems like 300ms timeout is ideal
  inputChangedPromise = null
  $scope.search = (input) ->

    if inputChangedPromise
      $timeout.cancel(inputChangedPromise)

    inputChangedPromise = $timeout( ->
      if input.length > 0
        console.log 'Searching for: ', input
        $scope.dataLoading = true
        delete $scope.params['sort']
        # delete $scope.params['page']
        $scope.page = 1
        $scope.params['search_all'] = input
        $scope.activities = []
        $scope.getActivities()
    ,300)

  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.params['search_all']
    $scope.page = 1
    $scope.activities = []
    $scope.getActivities()

  $scope.applyFilter = ->
    $scope.dataLoading = true
    $scope.params['difficulty'] = $scope.filters['difficulty']
    $scope.params['published_status'] = $scope.filters['published_status']
    $scope.params['generator'] = $scope.filters['generator']
    $scope.params['sort'] = $scope.filters['sort']
    # delete $scope.params['page']
    $scope.page = 1
    $scope.activities = []
    $scope.getActivities()

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  $scope.next = ->
    $scope.dataLoading = true
    if $scope.page && $scope.page >= 1
      $scope.page += 1
    else
      $scope.page = 2
    $scope.getActivities()

  # Load the first page
  $scope.getActivities()
    
]


