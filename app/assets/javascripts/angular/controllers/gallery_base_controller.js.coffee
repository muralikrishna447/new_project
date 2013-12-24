@app.controller 'GalleryBaseController', ["$scope", ($scope) ->

  # Initialization
  $scope.galleryItems = []
    
  $scope.sortChoices = ["relevance", "newest", "oldest"]
 
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "relevance")

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
        if $scope.defaultFilters[key]?.value != value.value
          mem[key] = value
        mem
      {}
    )
    delete r.search_all
    delete r.sort
    r

  $scope.galleryIndexParams = ->
    r = {page: $scope.page}
    for filter, x of $scope.filters
      r[filter] = x.toLowerCase() if x != "Any"
    $scope.normalizeGalleryIndexParams(r)
    r

  PAGINATION_COUNT = 12

  $scope.loadData = ->
    if ! $scope.all_loaded

      $scope.spinner += 1

      gip = $scope.galleryIndexParams()
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
          $scope.all_loaded = true if (! newItems) || (newItems.length < PAGINATION_COUNT)

        else
          console.log ".... FROM OLD PARAMS, IGNORING "
          console.log "old: " + query_filters.search_all
          console.log "new: " + $scope.filters.search_all

        $scope.spinner -= 1
      )

  ]