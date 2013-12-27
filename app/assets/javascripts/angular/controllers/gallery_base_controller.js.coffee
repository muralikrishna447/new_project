# Next step in refactoring would be to move much of this over to a service, but at least it is now shared by 
# all gallery controllers.
@app.controller 'GalleryBaseController', ["$scope", "$timeout", ($scope, $timeout) ->

  # Initialization
  $scope.galleryItems = []
  $scope.collapse_filters = true
  $scope.page = 1
  $scope.spinner = 0

  # This muck will go away when I do deep routing properly
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  
  $scope.resetFilter = (key) ->
    $scope.filters[key] = $scope.defaultFilters[key]
  
  $scope.itemImageURL = (item, width) ->
    fpfile = $scope.objectMethods.itemImageFpfile(item)
    height = width * 9.0 / 16.0
    return (window.cdnURL(fpfile.url) + "/convert?fit=crop&w=#{width}&h=#{height}&cache=true") if (fpfile? && fpfile.url?)
    $scope.objectMethods.placeHolderImage()

  $scope.serialize = (obj) ->
    str = []
    for p of obj
      str.push encodeURIComponent(p) + "=" + encodeURIComponent(obj[p])
    str.join "&"

  $scope.nonDefaultFilters = ->
    r = _.reduce(
      angular.extend({}, $scope.filters),
      (mem, value, key) ->
        if $scope.defaultFilters[key] != value
          mem[key] = value
        mem
      {}
    )
    delete r.search_all
    delete r.sort
    r

  # Override if needed in derived controllers
  $scope.normalizeGalleryIndexParams = (r) ->
    r

  $scope.galleryIndexParams = (filters, page) ->
    r = {page: page}
    for filter, x of filters
      r[filter] = x.replace(/\s+/g, '_').toLowerCase() if x && x.toLowerCase() != "any"
    $scope.normalizeGalleryIndexParams(r)
    r

  PAGINATION_COUNT = 12

  $scope.loadData = ->
    if ! $scope.allLoaded

      $scope.spinner += 1

      gip = $scope.galleryIndexParams($scope.filters, $scope.page)
      console.log "Querying for " + JSON.stringify(gip)
      query_filters = angular.extend({}, $scope.filters)
      $scope.objectMethods.queryIndex()(gip, (newItems) -> 

        console.log "GOT BACK " + newItems.length + " FOR PAGE " + gip.page

        # Ignore any results that come back that don't match the current filters
        if _.isEqual(query_filters, $scope.filters)

          if newItems
            # Copy over any old activitites that the repeater has already added properties to
            # and use them instead of the ones we just got back. Cuts down on flashing.
            for i in [0...newItems.length]
              a = _.find($scope.galleryItems, (x) -> x.slug == newItems[i].slug)
              newItems[i] = a if a?

            if (gip.page == 1) || (Object.keys($scope.galleryItems).length == 0)
              $scope.galleryItems = []

            base = (gip.page - 1) * PAGINATION_COUNT
            $scope.galleryItems[base..base + PAGINATION_COUNT] = newItems

          $scope.page = gip.page + 1
          $scope.allLoaded = true if (! newItems) || (newItems.length < PAGINATION_COUNT)

        else
          console.log ".... FROM OLD PARAMS, IGNORING "
          console.log "old: " + query_filters.search_all
          console.log "new: " + $scope.filters.search_all

        $scope.spinner -= 1
      )

  $scope.loadNoResultsData = ->
    $scope.objectMethods.queryIndex()($scope.galleryIndexParams($scope.noResultsFilters, 5), (newItems) ->
      $scope.noResultsItems = newItems
      console.log "loaded backups"
    )

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clearAndLoad()

  $scope.getDisplayItems = ->
    return $scope.noResultsItems if (! $scope.galleryItems?) || (! $scope.galleryItems.length)
    $scope.galleryItems

  # Load up some activities to use if we need to suggest alternatives for an empty result
  $timeout (->
    $scope.loadNoResultsData()
  ), 1000

  $scope.clearAndLoad = ->
    $scope.page = 1
    $scope.allLoaded = false
    $scope.loadData()

  $scope.$watch 'filters', 
    (newValue, oldValue) ->
      console.log newValue
      if newValue.search_all != oldValue.search_all
        if newValue.search_all? && (newValue.search_all.length > 0)
          $scope.filters.sort = "relevance" 
        else
          $scope.filters.sort = $scope.defaultFilters.sort
      _.throttle(( ->
        $scope.clearAndLoad()
      ), 250)()
    , true

  $scope.trackSearch = ->
    if $scope.filters.search_all?.length > 0
      mixpanel.track('Search', {'context': $scope.resourceName, 'term' : $scope.filters.search_all});
 

]