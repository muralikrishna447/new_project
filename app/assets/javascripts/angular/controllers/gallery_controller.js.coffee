angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", ($scope, $resource) ->
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

  # Total gallery items
  $scope.gallery_count = document.getElementById('gallery-count').getAttribute('gallery-count')

  # Number of gallery items as they're being added
  $scope.$watch 'activities', (newValue) ->
    if angular.isArray(newValue)
      $scope.activities_count = newValue.length

  page = 2
  currently_loading = false
  $scope.load_data = ->
    # console.log('loaded')
    # console.log($scope.activities)
    if $scope.activities_count < $scope.gallery_count && !currently_loading
      currently_loading = true
      more_activities = $resource(document.location.pathname + '/index_as_json.json?page=' + page).query ->
        console.log(more_activities)
        $scope.activities = $scope.activities.concat(more_activities)
        console.log($scope.activities)
        currently_loading = false
        # console.log(page)
      page+=1
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