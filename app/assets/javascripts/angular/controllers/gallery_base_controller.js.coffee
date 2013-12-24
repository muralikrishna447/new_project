@app.controller 'GalleryBaseController', ["$scope", ($scope) ->
    
  $scope.sortChoices = [
    {name: "RELEVANCE", value: "relevance"}
    {name: "NEWEST", value: "newest"},
    {name: "OLDEST", value: "oldest"},
  ]

  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x.value == "relevance")
  
  $scope.itemImageURL = (item, width) ->
    fpfile = $scope.objectMethods.itemImageFpfile(item)
    height = width * 9.0 / 16.0
    return (window.cdnURL(fpfile.url) + "/convert?fit=crop&w=#{width}&h=#{height}&cache=true") if (fpfile? && fpfile.url?)
    $scope.placeHolderImage()

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

  ]