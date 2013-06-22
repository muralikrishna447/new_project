angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", ($scope, $resource, $location, $timeout) ->
  Activity = $resource(document.location.pathname + '/index_as_json')
  $scope.activities = Activity.query()
  $scope.maybe_clear = false

  $scope.publishedAtChoices = [
    {name: "Newest", value: "desc"},
    {name: "Oldest", value: "asc"}
  ]

  $scope.difficultyChoices = [
    {name: "Easy", value: "easy"},
    {name: "Intermediate", value: "intermediate"}
    {name: "Advanced", value: "advanced"}
  ]

  $scope.publishedStatusChoices = [
    {name: "Published", value: "Published"},
    {name: "Unpublished", value: "Unpublished"}
  ]

  $scope.defaultFilters = {
    by_published_at: $scope.publishedAtChoices[0],
    published_status: $scope.publishedStatusChoices[0]
  }
  $scope.filters = angular.extend({}, $scope.defaultFilters)

  $scope.placeHolderImage = "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

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
          return JSON.parse(image_fpfile) if (image_fpfile? && (image_fpfile != ""))
    ""

  $scope.activityImageURL = (activity, width) ->
    fpfile = $scope.activityImageFpfile(activity)
    return (fpfile.url + "/convert?fit=max&w=#{width}&cache=true") if (fpfile? && fpfile.url?)
    $scope.placeHolderImage

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

  $scope.galleryIndexParams = ->
    r = {page: $scope.page}
    for filter, x of $scope.filters
      if _.isObject(x)
        r[filter] = x.value
      else
        r[filter] = x

    # For unpublished, sort by updated date instead of published date
    if r.published_status == "Unpublished" && r.by_published_at?
      r.by_updated_at = r.by_published_at
      delete r.by_published_at
    r

  $scope.load_data = ->
    # $scope.page < $scope.gallery_count/12 + 1 stops attempting to load more pages when all the activities are loaded
    if !currently_loading && $scope.page < $scope.gallery_count/12 + 1

      currently_loading = true
      $scope.spinner = true
      gip = $scope.galleryIndexParams()

      more_activities = $resource($scope.gallery_index + '?' + $scope.serialize(gip)).query ->
        console.log $scope.gallery_index + '?' + $scope.serialize(gip)
        if more_activities
          if $scope.maybe_clear
            if ! _.isEqual(_.pluck($scope.activities, 'slug'), _.pluck(more_activities, 'slug'))
              $scope.activities = more_activities
          else if Object.keys($scope.activities).length == 0
            $scope.activities = more_activities
          else
            $scope.activities = $scope.activities.concat(more_activities)
        currently_loading = false
        $scope.maybe_clear = false
        $scope.spinner = false

      $scope.page+=1

  $scope.clear_and_load = ->
    $scope.maybe_clear = true
    $scope.page = 1
    $scope.load_data()

  $scope.$watch 'filters.difficulty', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.by_published_at', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.published_status', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.search_all', (newValue) ->
    console.log newValue
    $timeout (->
      $scope.clear_and_load()
    ), 250

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clear_and_load()

  $scope.nonDefaultFilters = ->
    ! _.isEqual($scope.filters, $scope.defaultFilters)

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