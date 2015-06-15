@components.directive 'searchFeed', ['AlgoliaSearchService', 'Mapper', (AlgoliaSearchService, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
    search: '=?'
    columns: '=?'
    rows: '=?'
    itemTypeName: '=?'
  }

  link: (scope, element, attrs) ->

    mapper = [
      {
        componentKey: "title",
        sourceKey: "title",
        value: ""
      },
      {
        componentKey: "image",
        sourceKey: "image",
        value: ""
      },
      {
        componentKey: "buttonMessage",
        sourceKey: null,
        value: "See the recipe"
      },
      {
        componentKey: "description",
        sourceKey: "description",
        value: ""
      },
      {
        componentKey: "url",
        sourceKey: "url",
        value: ""
      }
    ]

    scope.doSearch = (searchQuery) ->
      params = {
        difficulty: 'any'
        generator: 'chefsteps'
        published_status: 'published'
        page: '1'
        search_all: searchQuery
      }

      AlgoliaSearchService.search(params).then (data) ->
        numItems = scope.rows * scope.columns
        dataToMap = data.slice(0, numItems)
        scope.items = Mapper.mapObject(dataToMap, mapper)

    scope.$watch 'component', (newValue, oldValue) ->
      if newValue
        scope.search = newValue.meta.searchQuery
        scope.columns = newValue.meta.columns
        scope.rows = newValue.meta.rows
        scope.itemTypeName = newValue.meta.itemTypeName

    scope.$watch 'columns', (newValue, oldValue) ->
      if newValue
        scope.doSearch(scope.search)

    scope.$watch 'rows', (newValue, oldValue) ->
      if newValue
        scope.doSearch(scope.search)

    scope.$watch 'search', (newValue, oldValue) ->
      if newValue
        scope.doSearch(newValue)

  templateUrl: '/client_views/component_feed.html'
]
