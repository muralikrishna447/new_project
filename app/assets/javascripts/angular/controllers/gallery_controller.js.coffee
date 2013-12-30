@app.controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Activity", "ActivityMethods", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Activity, ActivityMethods) ->

  $controller('GalleryBaseController', {$scope: $scope});
  $scope.galleryService = csGalleryService
  $scope.resourceName = "Activity"
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
    activity_type: "Any"
    difficulty: "Any"
    generator: "ChefSteps"
  }
  $scope.filters = angular.extend({}, $scope.defaultFilters)


  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "newest"
    activity_type: "recipe"
    page: 3
  }

  $scope.getFooterRightContents = (activity) ->
    if activity?.creator?.id
      return "By #{activity.creator.name}"
    else if activity?.show_only_in_course
      return "<h5 class='pop'>PAID CLASS</h5>"

  $scope.normalizeGalleryIndexParams = (r) ->
    # For unpublished, sort by updated date instead of published date
    if r.published_status == "Unpublished" && r.by_published_at?
      r.by_updated_at = r.by_published_at
      delete r.by_published_at

  # This muck will go away when I do deep routing properly
  if $scope.url_params.search_all
    $scope.filters.search_all = $scope.url_params.search_all
    $scope.filters.sort = $scope.sortChoices[0]
  $scope.filters.generator = $scope.url_params.source if $scope.url_params.source
  $scope.filters.activity_type = $scope.url_params.activity_type if $scope.url_params.activity_type

  # Initialize the view
  $scope.clearAndLoad()
]



