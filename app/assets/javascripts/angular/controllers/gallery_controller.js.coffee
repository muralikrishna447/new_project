@app.controller 'GalleryController', ['$scope', '$location', '$timeout', 'api.activity', 'api.search', 'csAuthentication', '$route', '$routeParams', ($scope, $location, $timeout, Activity, Search, csAuthentication, $route, $routeParams) ->
  $scope.csAuthentication = csAuthentication
  $scope.activities = []

  $scope.difficultyChoices = ["any", "easy", "medium", "advanced"]
  $scope.publishedStatusChoices = ["published", "unpublished"]
  $scope.generatorChoices = ["chefsteps", "community"]
  $scope.sortChoices = ["relevance", "newest", "oldest", "popular"]
  $scope.suggestedSearches = ['sous vide', 'beef', 'chicken', 'pork', 'fish', 'salad', 'dessert', 'breakfast', 'cocktail', 'baking', 'vegetarian', 'egg', 'pasta']
  $scope.dataLoading = $scope.doneLoading = false
  $scope.filtersCollapsed = true

  defaultFilters = {
    'difficulty':'any'
    'published_status':'published'
    'generator':"chefsteps"
    'sort':"newest"
  }
  $scope.filters = defaultFilters

  $scope.getSortChoices = ->
    sc = angular.extend($scope.sortChoices)
    sc = sc[1...] unless $scope.filters['search_all']?.length > 0
    sc

  # Sort/filter change from URL. Copy from route params to filters. This will fire on first load, and also on search from navbar.
  $scope.$on "$routeChangeSuccess", (event, $currentRoute) ->
    $scope.filters = angular.extend({}, defaultFilters, $currentRoute.params)
    if $scope.input != $currentRoute.params.search_all
      $scope.input = $currentRoute.params.search_all
      # If search changes, default sort to relevance - but only on search change
      # because we still want to let them switch to a different sort.
      $scope.filters['sort'] = if $scope.input?.length > 0 then "relevance" else "newest"
    $scope.applyFilter()

  # Filter/sort change from the UI.
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  # Search change from the UI.
  # Actual search only fires after the user stops typing
  # Seems like 300ms timeout is ideal
  inputChangedPromise = null
  $scope.search = (input) ->
    $scope.input = input

    if inputChangedPromise
      $timeout.cancel(inputChangedPromise)

    inputChangedPromise = $timeout( ->
      if input.length > 0
        console.log 'Searching for: ', input
        $scope.filters['search_all'] = input
        $scope.applyFilter()
    , 300)

  # Clear search from the UI
  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.filters['search_all']
    $scope.applyFilter()

  # Scroll
  $scope.next = ->
    if $scope.page && $scope.page >= 1
      $scope.page += 1
    else
      $scope.page = 2
    $scope.getActivities()

  # Called whenever an option changes; start over at beginning
  $scope.applyFilter = ->
    $scope.doneLoading = false
    $scope.page = 1
    $scope.activities = []
    window.scroll(0, 0)
    # Update route params to match filters
    $location.search($scope.filters)
    $scope.getActivities()

  # Get a page of data
  $scope.getActivities = ->
    if (! $scope.dataLoading) && (! $scope.doneLoading)
      $scope.dataLoading = true

      # Set up actual query params; they are mostly the same as the filters we show with 
      # a few minor adjustments.
      params = _.extend({page: $scope.page}, $scope.filters)
      params['difficulty'] = 'intermediate' if params['difficulty'] == 'medium'
      delete params['sort'] if params['sort'] == 'relevance'
      delete params['difficulty'] if params['difficulty'] && params['difficulty'] == 'undefined'       
      Activity.query(params).$promise.then (results) ->
        if results.length > 0
          $scope.noResults = false
          angular.forEach results, (result) ->
            $scope.activities.push(result)
          # console.log(_.map($scope.activities, (x) -> x.id))
          # This makes sure infinite-scroll rechecks itself after we change
          # searches and therefore resize back down to 0. Otherwise it can get stuck.
          $timeout ->
            window.scrollBy(0, 1)
        else
          $scope.noResults = true if $scope.activities.length == 0
          $scope.doneLoading = true
        $scope.dataLoading = false

  $scope.getDisplayActivities = ->
    return $scope.noResultsActivities if $scope.noResults && ! $scope.dataLoading
    $scope.activities

  $timeout ( ->
    Activity.query(
      'published_status':'published'
      'generator':"chefsteps"
      'sort':"popular"
    ).$promise.then (results) ->
      $scope.noResultsActivities = results
  ), 1000
]


