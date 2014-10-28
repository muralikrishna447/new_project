# @app.controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", "csGalleryService", "$controller", "Activity", "ActivityMethods", "csAuthentication", "csUtilities", ($scope, $resource, $location, $timeout, csGalleryService, $controller, Activity, ActivityMethods, csAuthentication, csUtilities) ->

#   $controller('GalleryBaseController', {$scope: $scope});
#   $scope.galleryService = csGalleryService
#   $scope.csAuthentication = csAuthentication
#   $scope.resourceName = "Activity"
#   $scope.resource = Activity
#   $scope.objectMethods = ActivityMethods

#   $scope.placeHolderImage = ->
#     ActivityMethods.placeHolderImage()

#   $scope.typeChoices = ["Any", "Recipe", "Technique", "Science"]
#   $scope.difficultyChoices = ["Any", "Easy", "Intermediate", "Advanced"]
#   $scope.publishedStatusChoices = ["Published", "Unpublished"]
#   $scope.generatorChoices = ["ChefSteps", "Community"]
#   $scope.sortChoices = ["Relevance", "Newest", "Oldest", "Popular"]
#   $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x == "Relevance")

#   $scope.defaultFilters = {
#     sort: "Newest"
#     published_status: "Published"
#     activity_type: "Any"
#     difficulty: "Any"
#     generator: "ChefSteps"
#   }

#   # Query results to show if user query results are empty
#   $scope.noResultsFilters = {
#     sort: "newest"
#     activity_type: "recipe"
#   }

#   $scope.getFooterRightContents = (activity) ->  
#     return "By #{activity.creator.name}" if activity?.creator?.id
#     return csUtilities.trustButVerify("<span><i class='icon-star-empty'/></span>&nbsp;#{activity.likes_count}") if activity.likes_count > 0

#   $scope.getSashContents = (activity) ->  
#     return "PAID CLASS" if activity?.show_only_in_course

#   $scope.normalizeGalleryIndexParams = (r) ->
#     # For unpublished, sort by updated date instead of published date
#     if r.published_status == "Unpublished" && r.by_published_at?
#       r.by_updated_at = r.by_published_at
#       delete r.by_published_at
# ]

@app.controller 'GalleryController', ['$scope', '$location', '$timeout', 'api.activity', 'api.search', 'csAuthentication', ($scope, $location, $timeout, Activity, Search, csAuthentication) ->
  $scope.csAuthentication = csAuthentication
  $scope.activities = []

  $scope.showOptions = {}
  $scope.showOptions.filters = false
  $scope.showOptions.sort = false
  $scope.difficultyChoices = ["any", "easy", "intermediate", "advanced"]
  $scope.publishedStatusChoices = ["published", "unpublished"]
  $scope.generatorChoices = ["chefsteps", "community"]
  $scope.sortChoices = ["newest", "oldest", "popular"]


  defaultFilters = {
    'difficulty':'any'
    'published_status':'published'
    'generator':"chefsteps"
    'sort':"newest"
  }

  # If the url contains filter parameters then use those.  If not then use the default filters.
  $scope.params = $location.search()
  keys = Object.keys($scope.params)
  if keys.length == 0
    $scope.params = defaultFilters

  $scope.filters = {}
  $scope.filters['published_status'] = $scope.params['published_status']
  $scope.filters['generator'] = $scope.params['generator']
  $scope.filters['sort'] = $scope.params['sort']
  $scope.filters['difficulty'] = $scope.params['difficulty']

  $scope.getActivities = ->
    $scope.params['page'] = $scope.page
    if $scope.params['difficulty']
      if $scope.params['difficulty'] == 'any' || $scope.params['difficulty'] == 'undefined'
        delete $scope.params['difficulty']
    console.log "params: ", $scope.params
    Activity.query($scope.params).$promise.then (results) ->
      if results.length > 0
        angular.forEach results, (result) ->
          $scope.activities.push(result)
        delete $scope.params['page']
        $location.search($scope.params)
      $scope.dataLoading = false

  # Search only fires after the user stops typing
  # Seems like 300ms timeout is ideal
  inputChangedPromise = null
  $scope.search = (input) ->

    if inputChangedPromise
      $timeout.cancel(inputChangedPromise)

    inputChangedPromise = $timeout( ->
      if input.length > 0
        console.log 'Searching for: ', input
        $scope.dataLoading = true
        delete $scope.params['sort']
        # delete $scope.params['page']
        $scope.page = 1
        $scope.params['search_all'] = input
        $scope.activities = []
        $scope.getActivities()
    ,300)

  $scope.clearSearch = ->
    $scope.input = null
    delete $scope.params['search_all']
    $scope.page = 1
    $scope.activities = []
    $scope.getActivities()

  $scope.applyFilter = ->
    $scope.dataLoading = true
    $scope.params['difficulty'] = $scope.filters['difficulty']
    $scope.params['published_status'] = $scope.filters['published_status']
    $scope.params['generator'] = $scope.filters['generator']
    $scope.params['sort'] = $scope.filters['sort']
    # delete $scope.params['page']
    $scope.page = 1
    $scope.activities = []
    $scope.getActivities()

  # If the filters change, then update the results
  $scope.$watchCollection 'filters', (newValue, oldValue) ->
    if newValue != oldValue
      $scope.applyFilter()

  $scope.next = ->
    $scope.dataLoading = true
    if $scope.page && $scope.page >= 1
      $scope.page += 1
    else
      $scope.page = 2
    $scope.getActivities()

  # Load the first page
  $scope.getActivities()
    
]


