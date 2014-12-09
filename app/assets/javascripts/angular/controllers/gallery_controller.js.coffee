@app.controller 'GalleryController', ['$scope', 'api.activity', '$controller', ($scope, Activity, $controller) ->

  $scope.context                = "Activity"
  $scope.difficultyChoices      = ["any", "easy", "medium", "advanced"]
  $scope.publishedStatusChoices = ["published", "unpublished"]
  $scope.generatorChoices       = ["chefsteps", "community"]
  $scope.sortChoices            = ["relevance", "newest", "oldest", "popular"]
  $scope.suggestedSearches      = ['sous vide', 'beef', 'chicken', 'pork', 
                                    'fish', 'egg', 'pasta', 'chocolate', 'baking', 
                                    'salad', 'dessert', 'breakfast', 'cocktail', 'vegetarian']

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

  $scope.doQuery = (params) ->
    Activity.query(params)

  $controller('GalleryBaseController', {$scope: $scope});
]


