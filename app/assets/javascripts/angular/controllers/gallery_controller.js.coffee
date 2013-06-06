angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", ($scope, $resource) ->
  Activity = $resource('/recipe-gallery/index_as_json')
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
]

angular.module('ChefStepsApp').controller 'TechniquesController', ["$scope", "$resource", ($scope, $resource) ->
  Activity = $resource('/techniques/index_as_json')
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
]

angular.module('ChefStepsApp').controller 'SciencesController', ["$scope", "$resource", ($scope, $resource) ->
  Activity = $resource('/sciences/index_as_json')
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
]