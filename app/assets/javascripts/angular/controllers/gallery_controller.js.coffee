angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  Activity = $resource(document.location.pathname + '/index_as_json')
  $scope.activities = Activity.query()

  $scope.activityImageFpfile = (activity) ->
    if activity?
      if activity.featured_image_id
        return JSON.parse(activity.featured_image_id)
      else if activity.image_id
        return JSON.parse(activity.image_id)
      else
        if activity.steps?
          images = activity.steps.map (step) -> step.image_id
          image_fpfile = images[images.length - 1]
          return JSON.parse(image_fpfile) if image_fpfile?
    nil

  $scope.activityImageURL = (activity, width) ->
    fpfile = $scope.activityImageFpfile(activity)
    return JSON.parse(fpfile).url + "/convert?fit=max&w=#{width}&cache=true" if fpfile
    ""

  $scope.serialize = (obj) ->
    str = []
    for p of obj
      str.push encodeURIComponent(p) + "=" + encodeURIComponent(obj[p])
    str.join "&"

  # Total gallery items
  $scope.gallery_count = document.getElementById('gallery-count').getAttribute('gallery-count')

  $scope.page = 2
  currently_loading = false
  $scope.gallery_index = document.location.pathname + '/index_as_json.json'
  $scope.gallery_index_params = {}

  $scope.load_data = ->
    # $scope.page < $scope.gallery_count/12 + 1 stops attempting to load more pages when all the activities are loaded
    if !currently_loading && $scope.page < $scope.gallery_count/12 + 1
      currently_loading = true
      $scope.spinner = true
      $scope.gallery_index_params['page'] = $scope.page
      more_activities = $resource($scope.gallery_index + '?' + $scope.serialize($scope.gallery_index_params)).query ->
        console.log $scope.gallery_index + '?' + $scope.serialize($scope.gallery_index_params)
        if Object.keys($scope.activities).length == 0
          $scope.activities = more_activities
        else
          $scope.activities = $scope.activities.concat(more_activities)
        currently_loading = false
        $scope.spinner = false
      $scope.page+=1

  $scope.clear_and_load = ->
    $scope.activities = {}
    $scope.page = 1
    $scope.load_data()

  $scope.$watch 'filters.difficulty', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined")
      $scope.gallery_index_params['difficulty'] = newValue
      $scope.clear_and_load()

  $scope.$watch 'filters.by_published_at', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined")
      $scope.gallery_index_params['by_published_at'] = newValue
    $scope.clear_and_load()

  $scope.$watch 'filters.published_status', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined")
      $scope.gallery_index_params['published_status'] = newValue
      $scope.clear_and_load()

  $scope.$watch 'filters.clear', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined") && newValue
      $scope.gallery_index_params = {}
      $scope.filters.clear = false
      $scope.filters = {}
      $scope.clear_and_load()

  # $scope.fill_screen = ->
  #   if ($("body").height() < window.innerHeight)
  #     $scope.load_data()

  # $scope.fill_screen()
]

angular.module('ChefStepsApp').directive 'galleryscroll', ["$window", ($window) ->
  (scope, element, attr) ->
    window_element = angular.element($window)
    raw = element[0]
    window_element.scroll ->
      # console.log(element.height() - window.innerHeight)
      # console.log(window_element.scrollTop())
      if window_element.scrollTop() >= (element.height() - window.innerHeight)
        scope.$apply(attr.galleryscroll)
]