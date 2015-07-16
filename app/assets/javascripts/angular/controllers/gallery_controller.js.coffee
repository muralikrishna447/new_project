@app.controller 'GalleryController', ['$scope', 'AlgoliaSearchService', '$controller', "$timeout", ($scope, AlgoliaSearchService, $controller, $timeout) ->

  $scope.context                = "Activity"
  $scope.difficultyChoices      = ["Any", "Easy", "Medium", "Advanced"]
  $scope.publishedStatusChoices = ["Published", "Unpublished"]
  $scope.generatorChoices       = ["Chefsteps", "Community"]
  $scope.sortChoices            = ["Relevance", "Newest", "Oldest", "Popular"]
  $scope.suggestedTags          = ['Sous Vide', 'Beef', 'Chicken', 'Pork',
                                    'Seafood', 'Pasta', 'Chocolate', 'Baking',
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
    difficulty: 'any'
    page: 1

  $scope.adjustParams = (params) ->
    params['difficulty'] = 'intermediate' if params['difficulty'] == 'medium'
    delete params['sort'] if params['sort'] == 'relevance'
    delete params['difficulty'] if params['difficulty'] && params['difficulty'] == 'undefined'

  $scope.doQuery = (params) ->
    { $promise: AlgoliaSearchService.search(params) }

  $scope.focusSearch = ->
    $('.focusme').focus()
    true

  $controller('GalleryBaseController', {$scope: $scope});

  $timeout ( ->
    Intercom?('trackEvent', 'gallery-twenty-seconds')
  ), 20000
]


