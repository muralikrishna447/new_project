angular.module('ChefStepsApp').controller 'IngredientsGalleryController', ["$scope", "$resource", "$location", "$timeout", ($scope, $resource, $location, $timeout) ->

  PAGINATION_COUNT = 12

  $scope.sortChoices = [
    {name: "NAME", value: "title"},
  ]

  $scope.imageChoices = [
    {name: "Any", value: "any"},
    {name: "Has Image", value: "true"}
  ]

  $scope.sortChoicesWhenNoSearch = _.reject($scope.sortChoices, (x) -> x.value == "relevance")

  $scope.defaultFilters = {
    sort: $scope.sortChoices[0],
    image: $scope.imageChoices[0]
  }

  $scope.placeHolderImage = "https://s3.amazonaws.com/chefsteps-production-assets/assets/img_placeholder.jpg"

  $scope.ingredientImageFpfile = (ingredient) ->
    JSON.parse(ingredient?.image_id || "")

  $scope.ingredientImageURL = (ingredient, width) ->
    fpfile = $scope.ingredientImageFpfile(ingredient)
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

  $scope.loadData = ->
    if ! $scope.all_loaded

      $scope.spinner += 1

      gip = $scope.galleryIndexParams()
      query_filters = angular.extend({}, $scope.filters)
      more_ingredients = $resource($scope.gallery_index + '?' + $scope.serialize(gip)).query ->

        console.log "GOT BACK " + more_ingredients.length + " FOR PAGE " + gip.page

        # Ignore any results that come back that don't match the current filters
        if _.isEqual(query_filters, $scope.filters)

          if more_ingredients
            # Copy over any old activitites that the repeater has already added properties to
            # and use them instead of the ones we just got back. Cuts down on flashing.
            for i in [0...more_ingredients.length]
              a = _.find($scope.ingredients, (x) -> x.slug == more_ingredients[i].slug)
              more_ingredients[i] = a if a?

            if (gip.page == 1) || (Object.keys($scope.ingredients).length == 0)
              $scope.ingredients = []

            base = (gip.page - 1) * PAGINATION_COUNT
            $scope.ingredients[base..base + PAGINATION_COUNT] = more_ingredients

          $scope.page = gip.page + 1
          $scope.all_loaded = true if (! more_ingredients) || (more_ingredients.length < PAGINATION_COUNT)

        else
          console.log ".... FROM OLD PARAMS, IGNORING "
          console.log "old: " + query_filters.search_all
          console.log "new: " + $scope.filters.search_all

        $scope.spinner -= 1


  $scope.load_no_results_data = ->
    $scope.no_results_ingredients = $resource($scope.gallery_index + '?page=3&sort=title').query ->
      console.log "loaded backups"

  $scope.clearAndLoad = ->
    $scope.page = 1
    $scope.all_loaded = false
    $scope.loadData()

  $scope.$watch 'filters.sort', (newValue) ->
    console.log newValue
    $scope.clearAndLoad() if newValue

  $scope.$watch 'filters.search_all', (newValue) ->
    console.log newValue
    #$scope.filters.sort = $scope.sortChoices[0] if newValue? && (newValue.length == 1)
    #$scope.filters.sort = $scope.sortChoices[1] if (! newValue?)  || newValue.length == 0
    $timeout (->
      $scope.clearAndLoad()
    ), 250

  $scope.clearFilters = ->
    $scope.filters = angular.extend({}, $scope.defaultFilters)
    $scope.clearAndLoad()

  $scope.getIngredients = ->
    return $scope.no_results_ingredients if (! $scope.ingredients?) || (! $scope.ingredients.length)
    $scope.ingredients

  $scope.$watch 'filters.image', (newValue) ->
    console.log newValue
    $scope.clearAndLoad() if newValue

  # Initialization
  $scope.collapse_filters = true
  $scope.gallery_index = document.location.pathname + '.json'
  $scope.page = 1
  $scope.spinner = 0
  $scope.url_params = {}
  $scope.url_params = JSON.parse('{"' + decodeURI(location.search.slice(1).replace(/&/g, "\",\"").replace(/\=/g,"\":\"")) + '"}') if location.search.length > 0
  $scope.filters = angular.extend({}, $scope.defaultFilters)
  if $scope.url_params.search_all
    $scope.filters.search_all = $scope.url_params.search_all
    $scope.filters.sort = $scope.sortChoices[0]
  $scope.clearAndLoad()

  # Load up some ingredients to use if we need to suggest alternatives for an empty result
  $timeout (->
    $scope.load_no_results_data()
  ), 1000

  $scope.getFooterRightContents = (ingredient) ->
    null

]

