# Next step in refactoring would be to move much of this over to a service, but at least it is now shared by 
# all gallery controllers.
@app.controller 'GalleryBaseController', ["$scope", "$rootScope", "$timeout", '$route', '$routeParams', '$location', ($scope, $rootScope, $timeout, $route, $routeParams, $location) ->

  $scope.filters = $scope.defaultFilters
  $scope.results = []
  $scope.emptyResultsSuggestions = []
  $scope.dataLoading = 0
  $scope.doneLoading = false
  $scope.requestedPages = {}
  $scope.filtersCollapsed = true

  $scope.getSortChoices = ->
    sc = angular.extend($scope.sortChoices)
    sc = sc[1...] unless $scope.filters['search_all']?.length > 0
    sc

  $scope.adjustSortForSearch = ->
    # If search changes, default sort to relevance - but only on search change
    # because we still want to let them switch to a different sort.
    $scope.filters['sort'] = if $scope.input?.length > 0 then "relevance" else "newest"

  # Sort/filter change from URL. Copy from route params to filters. This will fire on first load, and also on search from navbar.
  $scope.$on "$routeChangeSuccess", (event, $currentRoute) ->
    $scope.filters = angular.extend({}, $scope.defaultFilters, $currentRoute.params)
    #$scope.input = $currentRoute.params.search_all
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
    $scope.adjustSortForSearch()

    if inputChangedPromise
      $timeout.cancel(inputChangedPromise)

    inputChangedPromise = $timeout( ->
      if input.length > 0
        console.log 'Searching for: ', input
        $scope.filters['search_all'] = input
        mixpanel.track('Gallery Popular Item', _.extend({'context' : $scope.context}, {search_all: input}));        
        $scope.applyFilter()
    , 300)

  # Clear search from the UI
  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.filters['search_all']
    $scope.adjustSortForSearch()
    $scope.applyFilter()

  # Scroll
  $scope.next = ->
    if $scope.page && $scope.page >= 1
      $scope.page += 1
    else
      $scope.page = 2
    $scope.loadOnePage()

  # Called whenever an option changes; start over at beginning
  $scope.applyFilter = ->
    return if JSON.stringify($scope.filters) == JSON.stringify($scope.prevFilters)
    $scope.prevFilters = _.extend({}, $scope.filters)
    $scope.doneLoading = false
    $scope.page = 1
    $scope.results = []
    $scope.requestedPages = {}
    $scope.filtersCollapsed = true
    $scope.reloading = true
    window.scroll(0, 0)
    # Update route params to match filters
    $location.search($scope.filters)
    mixpanel.track('Gallery Filtered', _.extend({'context' : $scope.context}, $scope.filters));
    $scope.loadOnePage()

  fixParamEnums = (params) ->
    for k, v of params
      if k != "search_all"
        params[k] = v.toString().toLowerCase().replace(' ', "_")
    params

  # Get a page of data
  $scope.loadOnePage = ->
    if  (! $scope.doneLoading) && (! $scope.requestedPages[$scope.page])
      $scope.dataLoading += 1
      $rootScope.$broadcast('showPopupCTA') if $scope.page == 3

      # Set up actual query params; they are mostly the same as the filters we show with 
      # a few minor adjustments.
      queryFilters = _.extend({}, $scope.filters)
      params = _.extend({page: $scope.page}, $scope.filters)
      fixParamEnums(params)      
      $scope.adjustParams(params)
      $scope.requestedPages[$scope.page] = true

      $scope.doQuery(params).$promise.then (results) ->
        $scope.dataLoading -= 1
        # This hack makes sure infinite-scroll rechecks itself after we change
        # searches and therefore resize back down to 0. Otherwise it can get stuck.
        $rootScope.$broadcast 'infiniteScrollCheck'

        if ! _.isEqual(queryFilters, $scope.filters)
          console.log "FROM OLD FILTERS, IGNORING"
          return

        $scope.reloading = false

        if results.length > 0
          angular.forEach results, (result) ->
            $scope.results.push(result)
        else
          $scope.doneLoading = true

  $scope.noResults = ->
    ($scope.results.length == 0) && (! $scope.dataLoading)

  $scope.getResults = ->
    return $scope.emptyResultsSuggestions if $scope.noResults()
    $scope.results

  # Load up some suggested results if the users query set is empty
  $timeout ( ->
    $scope.doQuery(fixParamEnums($scope.noResultsQuery)).$promise.then (results) ->
      $scope.emptyResultsSuggestions = results
  ), 1000
]