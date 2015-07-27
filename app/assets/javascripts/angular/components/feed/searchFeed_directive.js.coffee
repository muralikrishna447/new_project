@components.directive 'searchFeed', ['AlgoliaSearchService', 'Mapper', 'componentItemService', (AlgoliaSearchService, Mapper, componentItemService) ->
  restrict: 'A'
  scope: {
    component: '='
    search: '=?'
    columns: '=?'
    rows: '=?'
    itemTypeName: '=?'
    charLimit: '=?'
    buttonMessage: '=?'
    theme: '=?'
  }

  link: (scope, element, attrs) ->
    itemTypeName = scope.itemTypeName ?= scope.component.meta.itemTypeName
    itemType = componentItemService.get(itemTypeName)
    mapper = Mapper.generate(itemType.attrs)
    Mapper.update(mapper, 'buttonMessage', {value: 'See the recipe'})

    scope.doSearch = (searchQuery) ->
      params = {
        difficulty: 'any'
        generator: 'chefsteps'
        published_status: 'published'
        page: '1'
        search_all: searchQuery
        attributesToRetrieve: 'title,url,image,likes_count,description'
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
        scope.theme = newValue.meta.theme

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
