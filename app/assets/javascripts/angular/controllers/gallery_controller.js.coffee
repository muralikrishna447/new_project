@app.controller 'GalleryController', ['$scope', 'api.activity', '$controller', "$timeout", "$q", ($scope, Activity, $controller, $timeout, $q) ->

  $scope.context                = "Activity"
  $scope.difficultyChoices      = ["Any", "Easy", "Medium", "Advanced"]
  $scope.publishedStatusChoices = ["Published", "Unpublished"]
  $scope.generatorChoices       = ["Chefsteps", "Community"]
  $scope.sortChoices            = ["Relevance", "Newest", "Oldest", "Popular"]
  $scope.suggestedTags          = ['Sous Vide', 'Beef', 'Chicken', 'Pork',
                                    'Fish', 'Egg', 'Pasta', 'Chocolate', 'Baking',
                                    'Salad', 'Dessert', 'Breakfast', 'Cocktail', 'Vegetarian']

  $scope.defaultFilters =
    generator: 'chefsteps'
    published_status : 'published'
    difficulty: 'any'
    sort: 'newest'

  $scope.noResultsQuery =
    published_status: 'published'
    generator: 'chefsteps'
    sort: 'popular'

  $scope.adjustParams = (params) ->
    params['difficulty'] = 'intermediate' if params['difficulty'] == 'medium'
    delete params['sort'] if params['sort'] == 'relevance'
    delete params['difficulty'] if params['difficulty'] && params['difficulty'] == 'undefined'

  # Search-only API key, safe to distribute
  algolia = algoliasearch('JGV2ODT81S', '890e558aa5ce0acb553f4d251add31cb')
  index = algolia.initIndex('ChefSteps_development')

  $scope.doQuery = (params) ->
    deferred = $q.defer()
    chefsteps_generated = if params['generator'] == 'chefsteps' then 1 else 0
    index.search(params['search_all'],
      {
        getRankingInfo: 1
        hitsPerPage: 12
        page: params['page'] - 1
        numericFilters: "chefsteps_generated=#{chefsteps_generated}"
        tagFilters: params['tag'] || ''
      },
      (success, hits) ->
        deferred.resolve(hits.hits)
    )
    { $promise: deferred.promise}

  $scope.focusSearch = ->
    $('.focusme').focus()
    true

  $controller('GalleryBaseController', {$scope: $scope});

  $timeout ( ->
    Intercom?('trackEvent', 'gallery-twenty-seconds')
  ), 20000
]


