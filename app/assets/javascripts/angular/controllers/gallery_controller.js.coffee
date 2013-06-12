angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$location", ($scope, $resource, $location) ->
  Activity = $resource(document.location.pathname + '/index_as_json')
  $scope.activities = Activity.query()

  $scope.activityImageURL = (activity, width) ->
    url = ""
    if (typeof(activity) != "undefined")
      if activity.featured_image_id
        url = JSON.parse(activity.featured_image_id).url
        url + "/convert?fit=max&w=#{width}&cache=true"
      else if activity.image_id
        url = JSON.parse(activity.image_id).url
        url + "/convert?fit=max&w=#{width}&cache=true"
      else
        if (typeof(activity.steps) != "undefined")
          images = activity.steps.map (step) -> step.image_id
          image_url = images[images.length - 1]
          url = JSON.parse(image_url).url
          url + "/convert?fit=max&w=#{width}&cache=true"

  $scope.serialize = (obj) ->
    str = []
    for p of obj
      str.push encodeURIComponent(p) + "=" + encodeURIComponent(obj[p])
    str.join "&"

  # Total gallery items
  $scope.gallery_count = document.getElementById('gallery-count').getAttribute('gallery-count')

  # Number of gallery items as they're being added
  # $scope.$watch 'activities', (newValue) ->
  #   if angular.isArray(newValue)
  #     $scope.activities_count = newValue.length
  #     if $scope.activities_count < 9
  #       $scope.load_data()

  # $scope.$watch 'filtered', ((newValue) ->
  #   if angular.isArray(newValue)
  #     $scope.filtered_count = newValue.length
  #     console.log $scope.filtered_count
  #     if $scope.filtered_count < 10
  #       $scope.load_data()
  # ), true

  page = 2
  currently_loading = false
  $scope.gallery_index = document.location.pathname + '/index_as_json.json'
  $scope.gallery_index_params = {}
  $scope.load_data = ->
    # console.log($scope.activities)
    if !currently_loading
      currently_loading = true
      $scope.spinner = true
      $scope.gallery_index_params['page'] = page
      more_activities = $resource($scope.gallery_index + '?' + $scope.serialize($scope.gallery_index_params)).query ->
        console.log $scope.gallery_index + '?' + $scope.serialize($scope.gallery_index_params)
        if Object.keys($scope.activities).length == 0
          $scope.activities = more_activities
        else
          $scope.activities = $scope.activities.concat(more_activities)
        currently_loading = false
        $scope.spinner = false
      page+=1

  $scope.$watch 'filters.difficulty', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined")
      $scope.gallery_index_params['difficulty'] = newValue
      $scope.activities = {}
      $scope.load_data()
      page = 1

  $scope.$watch 'filters.by_published_at', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined")
      $scope.gallery_index_params['by_published_at'] = newValue
      $scope.activities = {}
      $scope.load_data()
      page = 1

  $scope.$watch 'filters.clear', (newValue) ->
    console.log newValue
    if (typeof(newValue) != "undefined") && newValue
      $scope.gallery_index_params = {}
      $scope.filters.clear = false
      $scope.filters = {}
      $scope.activities = {}
      $scope.load_data()
      page = 1
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