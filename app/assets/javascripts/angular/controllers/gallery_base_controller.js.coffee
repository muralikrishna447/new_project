@app.controller 'GalleryBaseController', ["$scope", ($scope) ->
    
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

  ]