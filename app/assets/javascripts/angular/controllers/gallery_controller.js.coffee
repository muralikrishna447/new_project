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

  $scope.defaultFilters = {
    sort: "Newest"
    published_status: "Published"
    activity_type: "Recipe"
    difficulty: "Any"
    generator: "ChefSteps"
  }

  $scope.normalizeGalleryIndexParams = (r) ->
    # For unpublished, sort by updated date instead of published date
    if r.published_status == "Unpublished" && r.by_published_at?
      r.by_updated_at = r.by_published_at
      delete r.by_published_at


  $scope.load_no_results_data = ->
    $scope.no_results_activities = $resource($scope.gallery_index + '?activity_type=Recipe&page=3&sort=newest').query ->
      console.log "loaded backups"

  $scope.clear_and_load = ->
    $scope.page = 1
    $scope.all_loaded = false
    $scope.loadData()

  $scope.$watch 'filters.difficulty', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.sort', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.published_status', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.activity_type', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.generator', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.search_all', (newValue) ->
    console.log newValue
    $scope.filters.sort = "Relevance" if newValue? && (newValue.length == 1)
    $scope.filters.sort = "Newest" if (! newValue?)  || newValue.length == 0
    $timeout (->
      $scope.clear_and_load()
    ), 250

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clear_and_load()

  $scope.getActivities = ->
    return $scope.no_results_activities if (! $scope.galleryItems?) || (! $scope.galleryItems.length)
    $scope.galleryItems

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
  $scope.clear_and_load()

  # Load up some activities to use if we need to suggest alternatives for an empty result
  $timeout (->
    $scope.load_no_results_data()
  ), 1000

  $scope.getFooterRightContents = (activity) ->
    if activity?.creator?.id
      return "By #{activity.creator.name}"
    else if activity?.show_only_in_course
      return "<h5 class='pop'>PAID CLASS</h5>"

]



