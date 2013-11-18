angular.module('ChefStepsApp').controller 'GalleryController', ["$scope", "$resource", "$location", "$timeout", ($scope, $resource, $location, $timeout) ->

  PAGINATION_COUNT = 12

  $scope.sortChoices = [
    {name: "RELEVANCE", value: "relevance"}
    {name: "NEWEST", value: "newest"},
    {name: "OLDEST", value: "oldest"},
  ]

  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x.value == "relevance")


  $scope.typeChoices = [
    {name: "Any", value: "any"}
    {name: "Recipes", value: "Recipe"},
    {name: "Techniques", value: "Technique"},
    {name: "Science", value: "Science"}
  ]

  $scope.difficultyChoices = [
    {name: "Any", value: "any"}
    {name: "Easy", value: "easy"},
    {name: "Intermediate", value: "intermediate"}
    {name: "Advanced", value: "advanced"}
  ]

  $scope.publishedStatusChoices = [
    {name: "Published", value: "Published"},
    {name: "Unpublished", value: "Unpublished"}
  ]

  $scope.generatorChoices = [
    {name: "ChefSteps", value: "chefsteps"},
    {name: "Community", value: "community"}
  ]

  $scope.defaultFilters = {
    sort: $scope.sortChoices[1],
    published_status: $scope.publishedStatusChoices[0]
    activity_type: $scope.typeChoices[0]
    difficulty: $scope.difficultyChoices[0]
    generator: $scope.generatorChoices[0]
  }

  $scope.placeHolderImage = "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

  # Must match logic in has_Activity#featurable_image !!
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
    height = width * 9.0 / 16.0
    return (window.cdnURL(fpfile.url) + "/convert?fit=crop&w=#{width}&h=#{height}&cache=true") if (fpfile? && fpfile.url?)
    $scope.placeHolderImage

  $scope.serialize = (obj) ->
    str = []
    for p of obj
      str.push encodeURIComponent(p) + "=" + encodeURIComponent(obj[p])
    str.join "&"

  $scope.galleryIndexParams = ->
    r = {page: $scope.page}
    for filter, x of $scope.filters
      if _.isObject(x)
        r[filter] = x.value if x.value != "any"
      else
        r[filter] = x

    # For unpublished, sort by updated date instead of published date
    if r.published_status == "Unpublished" && r.by_published_at?
      r.by_updated_at = r.by_published_at
      delete r.by_published_at
    r

  $scope.nonDefaultFilters = ->
    r = _.reduce(
      angular.extend({}, $scope.filters),
      (mem, value, key) ->
        if $scope.defaultFilters[key]?.value != value.value
          mem[key] = value
        mem
      {}
    )
    delete r.search_all
    delete r.sort
    r

  $scope.resetFilter = (key) ->
    $scope.filters[key] = $scope.defaultFilters[key]


  $scope.load_data = ->
    if ! $scope.all_loaded

      $scope.spinner += 1

      gip = $scope.galleryIndexParams()
      query_filters = angular.extend({}, $scope.filters)
      more_activities = $resource($scope.gallery_index + '?' + $scope.serialize(gip)).query ->

        console.log "GOT BACK " + more_activities.length + " FOR PAGE " + gip.page

        # Ignore any results that come back that don't match the current filters
        if _.isEqual(query_filters, $scope.filters)

          if more_activities
            # Copy over any old activitites that the repeater has already added properties to
            # and use them instead of the ones we just got back. Cuts down on flashing.
            for i in [0...more_activities.length]
              a = _.find($scope.activities, (x) -> x.slug == more_activities[i].slug)
              more_activities[i] = a if a?

            if (gip.page == 1) || (Object.keys($scope.activities).length == 0)
              $scope.activities = []
              
            base = (gip.page - 1) * PAGINATION_COUNT
            $scope.activities[base..base + PAGINATION_COUNT] = more_activities

          $scope.page = gip.page + 1
          $scope.all_loaded = true if (! more_activities) || (more_activities.length < PAGINATION_COUNT)

        else
          console.log ".... FROM OLD PARAMS, IGNORING "
          console.log "old: " + query_filters.search_all
          console.log "new: " + $scope.filters.search_all

        $scope.spinner -= 1


  $scope.load_no_results_data = ->
    $scope.no_results_activities = $resource($scope.gallery_index + '?activity_type=Recipe&page=3&sort=newest').query ->
      console.log "loaded backups"

  $scope.clear_and_load = ->
    $scope.page = 1
    $scope.all_loaded = false
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

  $scope.$watch 'filters.generator', (newValue) ->
    console.log newValue
    $scope.clear_and_load() if newValue

  $scope.$watch 'filters.search_all', (newValue) ->
    console.log newValue
    $scope.filters.sort = $scope.sortChoices[0] if newValue? && (newValue.length == 1)
    $scope.filters.sort = $scope.sortChoices[1] if (! newValue?)  || newValue.length == 0
    $timeout (->
      $scope.clear_and_load()
    ), 250

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clear_and_load()

  $scope.getActivities = ->
    return $scope.no_results_activities if (! $scope.activities?) || (! $scope.activities.length)
    $scope.activities

  # Initialization
  $scope.collapse_filters = true
  $scope.gallery_index = document.location.pathname + '/index_as_json.json'
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

  # $scope.fill_screen = ->
  #   if ($("body").height() < window.innerHeight)
  #     $scope.load_data()

  # $scope.fill_screen()
]



angular.module('ChefStepsApp').directive 'galleryscroll', ["$window", ($window) ->
  (scope, element, attr) ->
    window_element = angular.element($window)
    raw = element[0]
    maybe_call_cb = ->
      # console.log(element.height() - window.innerHeight)
      # console.log(window_element.scrollTop())
      if window_element.scrollTop() >= (element.height() - window.innerHeight)
        scope.$apply(attr.galleryscroll)
    throttled_cb = _.throttle(maybe_call_cb, 250, trailing: false)
    window_element.scroll(throttled_cb)
]

