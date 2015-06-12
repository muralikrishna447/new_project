# Directive to load a feed
# Example:
#
# .component.component-full(feed source="'http://www.chefsteps.com/api/v0/activities'" mapper='mapper' columns='3' item-type-name="'Square A'")
#
# Where mapper is:
# mapper = [
#   {
#     componentKey: "title",
#     sourceKey: "title",
#     value: ""
#   },
#   {
#     componentKey: "image",
#     sourceKey: "image",
#     value: ""
#   },
#   {
#     componentKey: "buttonMessage",
#     sourceKey: null,
#     value: "See the recipe"
#   },
#   {
#     componentKey: "url",
#     sourceKey: "url",
#     value: ""
#   }
# ]

@components.directive 'feed', ['$http', 'Mapper', ($http, Mapper) ->
  restrict: 'A'
  scope: {
    source: '='
    mapper: '='
    columns: '='
    limitTo: '='
    itemTypeName: '='
  }

  link: (scope, element, attrs) ->
    scope.numLimit = scope.limitTo || scope.columns

    Mapper.do(scope.source, scope.mapper).then (items) ->
      scope.items = items

  templateUrl: '/client_views/component_feed.html'
]

@components.directive 'searchFeed', ['AlgoliaSearchService', 'Mapper', (AlgoliaSearchService, Mapper) ->
  restrict: 'A'
  scope: {
    component: '='
    search: '=?'
    columns: '=?'
    rows: '=?'
    limitTo: '='
    itemTypeName: '=?'
  }

  link: (scope, element, attrs) ->
    scope.numLimit = scope.limitTo || 12

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
    # Search.query(params).then (data) ->
    #   scope.items = Mapper.mapObject(data, mapper)

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
        console.log 'numItems: ', numItems
        dataToMap = data.slice(0, numItems)
        console.log 'dataToMap: ', dataToMap
        scope.items = Mapper.mapObject(dataToMap, mapper)
        console.log 'scope.items: ', scope.items

    scope.$watch 'component', (newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if newValue
        # scope.doSearch(newValue.meta.searchQuery)
        console.log 'newValue.meta.columns: ', newValue.meta.columns
        scope.search = newValue.meta.searchQuery
        scope.columns = newValue.meta.columns
        scope.rows = newValue.meta.rows
        scope.itemTypeName = newValue.meta.itemTypeName

    scope.$watch 'columns', (newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue

    scope.$watch 'search', (newValue, oldValue) ->
      console.log 'newValue: ', newValue
      console.log 'oldValue: ', oldValue
      if newValue
        scope.doSearch(newValue)

  templateUrl: '/client_views/component_feed.html'
]
