@app.controller 'GalleryController', ['$scope', '$location', '$timeout', 'api.activity', 'api.search', 'csAuthentication', ($scope, $location, $timeout, Activity, Search, csAuthentication) ->
  $scope.csAuthentication = csAuthentication
  $scope.activities = []

  $scope.showOptions = {}
  $scope.showOptions.filters = false
  $scope.showOptions.sort = false
  $scope.difficultyChoices = ["any", "easy", "medium", "advanced"]
  $scope.publishedStatusChoices = ["published", "unpublished"]
  $scope.generatorChoices = ["chefsteps", "community"]
  $scope.sortChoices = ["relevance", "newest", "oldest", "popular"]
  $scope.suggestedSearches = ['sous vide', 'beef', 'chicken', 'pork', 'fish', 'salad', 'dessert', 'breakfast', 'cocktail', 'baking', 'vegetarian', 'egg', 'pasta']


  defaultFilters = {
    'difficulty':'any'
    'published_status':'published'
    'generator':"chefsteps"
    'sort':"newest"
  }

  # If the url contains filter parameters then use those.  If not then use the default filters.
  $scope.params = angular.extend({}, defaultFilters, $location.search())
  keys = Object.keys($scope.params)

  $scope.filters = {}
  $scope.filters['published_status'] = $scope.params['published_status']
  $scope.filters['generator'] = $scope.params['generator']
  $scope.filters['sort'] = $scope.params['sort']
  $scope.filters['difficulty'] = $scope.params['difficulty']
  $scope.input = $scope.params['search_all']

  $scope.getSortChoices = ->
    sc = angular.extend($scope.sortChoices)
    sc = sc[1...] unless $scope.params['search_all']?.length > 0
    sc

  $scope.getActivities = ->
    if !$scope.dataLoading
      $scope.dataLoading = true
      $scope.params['page'] = $scope.page
      if $scope.params['difficulty']
        if $scope.params['difficulty'] == 'undefined'
          delete $scope.params['difficulty']
      Activity.query($scope.params).$promise.then (results) ->
        if results.length > 0
          $scope.noResults = false
          angular.forEach results, (result) ->
            $scope.activities.push(result)
          delete $scope.params['page']
          $location.search($scope.params)
        else
          $scope.noResults = true if $scope.activities.length == 0
        $scope.dataLoading = false

  # Search only fires after the user stops typing
  # Seems like 300ms timeout is ideal
  inputChangedPromise = null
  $scope.search = (input) ->
    $scope.input = input

    if inputChangedPromise
      $timeout.cancel(inputChangedPromise)

    inputChangedPromise = $timeout( ->
      if input.length > 0
        console.log 'Searching for: ', input
        $scope.params['search_all'] = input
        $scope.filters['sort'] = "relevance"
        $scope.applyFilter()
    ,300)

  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.params['search_all']
    $scope.filters['sort'] = 'newest'
    $scope.page = 1
    $scope.activities = []
    $scope.applyFilter()

  $scope.applyFilter = ->
    $scope.params['difficulty'] = $scope.filters['difficulty']
    $scope.params['difficulty'] = 'intermediate' if $scope.params['difficulty'] == 'medium'
    $scope.params['published_status'] = $scope.filters['published_status']
    $scope.params['generator'] = $scope.filters['generator']
    $scope.params['sort'] = $scope.filters['sort']
    delete $scope.params['sort'] if $scope.params['sort'] == 'relevance'
    # delete $scope.params['page']
    $scope.page = 1
    $scope.activities = []
    $scope.getActivities()

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  $scope.next = ->
    if $scope.page && $scope.page >= 1
      $scope.page += 1
    else
      $scope.page = 2
    $scope.getActivities()

  # Load the first page
  $scope.applyFilter()
    
]


