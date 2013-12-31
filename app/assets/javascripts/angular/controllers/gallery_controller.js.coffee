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
  $scope.sortChoices = ["Relevance", "Newest", "Oldest"]
  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "Relevance")

  $scope.defaultFilters = {
    sort: "Newest"
    published_status: "Published"
    activity_type: "Any"
    difficulty: "Any"
    generator: "ChefSteps"
  }

  # Query results to show if user query results are empty
  $scope.noResultsFilters = {
    sort: "newest"
    activity_type: "recipe"
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
]



