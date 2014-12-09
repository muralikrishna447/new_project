@app.controller 'GalleryController', ['$scope', 'api.activity', '$controller', ($scope, Activity, $controller) ->

  $scope.context                = "Activity"
  $scope.difficultyChoices      = ["Any", "Easy", "Medium", "Advanced"]
  $scope.publishedStatusChoices = ["Published", "Unpublished"]
  $scope.generatorChoices       = ["Chefsteps", "Community"]
  $scope.sortChoices            = ["Relevance", "Newest", "Oldest", "Popular"]
  $scope.suggestedSearches      = ['Sous Vide', 'Beef', 'Chicken', 'Pork', 
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

  $scope.doQuery = (params) ->
    Activity.query(params)

  $controller('GalleryBaseController', {$scope: $scope});
]


