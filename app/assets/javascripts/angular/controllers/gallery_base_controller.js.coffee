# Next step in refactoring would be to move much of this over to a service, but at least it is now shared by
# all gallery controllers.
@app.controller 'GalleryBaseController', ["$scope", "$rootScope", "$timeout", '$route', '$routeParams', '$location', 'csAuthentication', ($scope, $rootScope, $timeout, $route, $routeParams, $location, csAuthentication) ->

  $scope.csAuthentication = csAuthentication
  $scope.filters = $scope.defaultFilters
  $scope.results = []
  $scope.emptyResultsSuggestions = []
  $scope.dataLoading = 0
  $scope.doneLoading = false
  $scope.requestedPages = {}
  $scope.filtersCollapsed = true

  $scope.getSearchTerm = ->
    # If there is a tag filter but no search string, use the tag as the search
    # string as well. That won't affect the results (since tags are also searched),
    # but it gives a much better ordering.
    $scope.filters['search_all'] || $scope.filters['tag']

  $scope.getSortChoices = ->
    sc = angular.extend($scope.sortChoices)
    sc = sc[1...] unless $scope.getSearchTerm()?.length > 0
    sc

  $scope.adjustSortForSearch = ->
    # If search changes, default sort to relevance - but only on search change
    # because we still want to let them switch to a different sort.
    $scope.filters['sort'] = if $scope.getSearchTerm()?.length > 0 then "relevance" else "newest"

  # Sort/filter change from URL. Copy from route params to filters.
  $scope.$on "$routeChangeSuccess", (event, $currentRoute, $prevRoute) ->
    $scope.filters = angular.extend({}, $scope.defaultFilters, $currentRoute.params)
    $scope.input = $currentRoute.params.search_all
    $scope.applyFilter()

  # Filter/sort change from the UI.
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  $scope.search = (input) ->
    $scope.input = input

    if input.length > 0
      console.log 'Searching for: ', input
      $scope.filters['search_all'] = input
    else
      $scope.clearSearch()
    $scope.adjustSortForSearch()
    $scope.applyFilter()


  # Clear search from the UI
  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.filters['search_all']
    $scope.adjustSortForSearch()
    $scope.applyFilter()

  $scope.tags = (tag) ->
    $scope.filters['tag'] = tag
    $scope.applyFilter()
    $scope.adjustSortForSearch()
    mixpanel.track('Gallery Popular Item', _.extend({'context' : $scope.context}, {search_all: tag}));

  $scope.clearTags = ->
    delete $scope.filters['tag']
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

    # Update route params to match filters
    $location.search($scope.filters)
    $scope.loadOnePage()

    # Update mixpanel with changed search. Throttled and trailing edge
    # so if they type we wait until they stop typing.
    _.throttle(
      (->
        filterData = angular.extend({}, $scope.defaultFilters, $scope.filters)
        filterData['defaultFilter'] = _.isEqual(filterData, $scope.defaultFilters)
        filterData['context'] = $scope.context
        mixpanel.track('Gallery Filtered', filterData)
      ),
      2000,
      {leading: false}
    )()

  fixParamEnums = (params) ->
    for k, v of params
      if k != "search_all"
        params[k] = v.toString().toLowerCase()
        params[k] = params[k].replace(' ', "_") unless k == "tag"
    params

  # Get a page of data
  $scope.loadOnePage = ->
    if  (! $scope.doneLoading) && (! $scope.requestedPages[$scope.page])
      $scope.dataLoading += 1

      # Set up actual query params; they are mostly the same as the filters we show with
      # a few minor adjustments.
      queryFilters = _.extend({}, $scope.filters)
      params = _.extend({page: $scope.page}, $scope.filters)
      fixParamEnums(params)
      $scope.adjustParams(params)
      params['search_all'] = $scope.getSearchTerm()
      $scope.requestedPages[$scope.page] = true

      $scope.doQuery(params).$promise.then( ((results) ->
        $scope.dataLoading -= 1
        # This hack makes sure infinite-scroll rechecks itself after we change
        # searches and therefore resize back down to 0. Otherwise it can get stuck.
        $rootScope.$broadcast 'infiniteScrollCheck'

        if ! _.isEqual(queryFilters, $scope.filters)
          console.log "FROM OLD FILTERS, IGNORING"
          return

        if params['page'] == 0
          window.scroll(0, 0)
          $scope.results = []

        if results.length > 0
          angular.forEach results, (result) ->
            $scope.results.push(result)
        else
          $scope.doneLoading = true
      ), ( ->
        console.log("Search error")
        # This will cause the "no results" results to display
        $scope.dataLoading -= 1
        window.scroll(0, 0)
        $scope.results = []
      ))

    Intercom?('update')

  $scope.noResults = ->
    ($scope.results.length == 0) && (! $scope.dataLoading)

  $scope.getResults = ->
    return $scope.emptyResultsSuggestions if $scope.noResults()
    $scope.results

  # Load up some suggested results if the users query set is empty
  $timeout ( ->
    $scope.doQuery?(fixParamEnums($scope.noResultsQuery)).$promise.then (results) ->
      $scope.emptyResultsSuggestions = results
  ), 1000
]