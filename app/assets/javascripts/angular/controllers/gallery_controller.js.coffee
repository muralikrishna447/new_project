@app.controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Activity", "ActivityMethods", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Activity, ActivityMethods) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resource = Activity
  $scope.objectMethods = ActivityMethods

  $scope.placeHolderImage = ->
    ActivityMethods.placeHolderImage()

  $scope.typeChoices = ["Any", "Recipe", "Technique", "Science"]
  $scope.difficultyChoices = ["Any", "Easy", "Intermediate", "Advanced"]
  $scope.publishedStatusChoices = ["Published", "Unpublished"]
  $scope.generatorChoices = ["ChefSteps", "Community"]
  $scope.sortChoices = ["relevance", "newest", "oldest"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "relevance")

  $scope.defaultFilters = {
    sort: "Newest"
    published_status: "Published"
    activity_type: "Recipe"
    difficulty: "Any"
    generator: "ChefSteps"
  }

  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "newest"
    activityType: "recipe"
    page: 3
  }

  $scope.normalizeGalleryIndexParams = (r) ->
    # For unpublished, sort by updated date instead of published date
    if r.published_status == "Unpublished" && r.by_published_at?
      r.by_updated_at = r.by_published_at
      delete r.by_published_at


  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    console.log newValue
    if newValue.search_all != oldValue.search_all
      if newValue.search_all? && (newValue.search_all.length > 0)
        $scope.filters.sort = "relevance" 
      else
        $scope.filters.sort = "newest"
    _.throttle(( ->
      $scope.clearAndLoad()
    ), 250)()

  # Initialization
  $scope.collapse_filters = true
  $scope.page = 1
  $scope.spinner = 0
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.filters = angular.extend({}, $scope.defaultFilters)
  if $scope.url_params.search_all
    $scope.filters.search_all = $scope.url_params.search_all
    $scope.filters.sort = $scope.sortChoices[0]
  $scope.filters.generator = _.find($scope.generatorChoices, (x) -> x.value == $scope.url_params.source) if $scope.url_params.source
  $scope.filters.activity_type = _.find($scope.typeChoices, (x) -> x.value == $scope.url_params.activity_type) if $scope.url_params.activity_type
  $scope.clearAndLoad()

 
  $scope.getFooterRightContents = (activity) ->
    if activity?.creator?.id
      return "By #{activity.creator.name}"
    else if activity?.show_only_in_course
      return "<h5 class='pop'>PAID CLASS</h5>"

]



