angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", ($scope, $resource, $location, $timeout) ->
  Activity = $resource(document.location.pathname + '/index_as_json')
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.filters = {}
  $scope.filters.search_all = $scope.url_params.search_all if $scope.url_params.search_all
  $scope.maybe_clear = false

  $scope.sortChoices = [
    {name: "Newest", value: "newest"},
    {name: "Oldest", value: "oldest"},
    {name: "Most Relevant", value: "relevance"}
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

  $scope.typeChoices = [
    {name: "Recipes", value: "Recipe"},
    {name: "Techniques", value: "Technique"},
    {name: "Science", value: "Science"}
  ]

  $scope.defaultFilters = {
    sort: $scope.sortChoices[0],
    published_status: $scope.publishedStatusChoices[0]
  }
  $scope.filters = angular.extend($scope.filters, $scope.defaultFilters)

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
    if $scope.page < $scope.gallery_count/12 + 1

      $scope.spinner = true
      gip = $scope.galleryIndexParams()

      more_activities = $resource($scope.gallery_index + '?' + $scope.serialize(gip)).query ->
        console.log $scope.gallery_index + '?' + $scope.serialize(gip)
        console.log "GOT BACK " + more_activities.length
        if more_activities
          save_activities = $scope.activities
          if $scope.maybe_clear || (Object.keys($scope.activities).length == 0)
            $scope.activities = more_activities
          else
            $scope.activities = $scope.activities.concat(more_activities)
          if save_activities
            for i in [0...$scope.activities.length]
              a = _.find(save_activities, (x) -> x.slug == $scope.activities[i].slug)
              $scope.activities[i] = a if a?
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

  $scope.$watch 'filters.sort', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.published_status', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.activity_type', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.search_all', (newValue) ->
    console.log newValue
    $scope.filters.sort = $scope.sortChoices[2] if newValue? && (newValue.length == 1)
    $scope.filters.sort = $scope.sortChoices[0] if (! newValue?)  || newValue.length == 0
    $timeout (->
      $scope.clear_and_load()
    ), 250

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clear_and_load()

  $scope.nonDefaultFilters = ->
    ! _.isEqual($scope.filters, $scope.defaultFilters)

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