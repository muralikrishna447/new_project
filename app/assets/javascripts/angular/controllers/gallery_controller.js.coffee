angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$http", ($scope, $resource, $http) ->
  Activity = $resource(document.location.pathname + '/index_as_json')
  $scope.activities = Activity.query()

  $scope.activityImageURL = (activity, width) ->
    url = ""
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

  $scope.load_data = ->
    console.log('loaded')
    more_activities = Activity.query()
    console.log(more_activities)
    $scope.activities = more_activities
    # $http.get(document.location.pathname + '/index_as_json.json?page=3').success (data) ->
    #   $scope.activities = data
    #   console.log($scope.activities)
]

angular.module('ChefStepsApp').directive 'galleryscroll', ($window) ->
  (scope, element, attr) ->
    window_element = angular.element($window)
    raw = element[0]
    window_element.scroll ->
      # console.log(window_element.scrollTop())
      # console.log(element.height())
      # console.log(window.innerHeight)
      console.log(element.height() - window.innerHeight)
      console.log(window_element.scrollTop())
      if window_element.scrollTop() >= (element.height() - window.innerHeight)
        scope.$apply(attr.galleryscroll)