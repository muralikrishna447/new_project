angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", ($scope, $resource) ->
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
      images = activity.steps.map (step) -> step.image_id
      image_url = images[images.length - 1]
      url = JSON.parse(image_url).url
      url + "/convert?fit=max&w=#{width}&cache=true"

  $scope.load_data = ->
    console.log('loaded')
    more_activities = $resource(document.location.pathname + '/index_as_json.json?page=2').query()
    $scope.activities.push(more_activities)
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