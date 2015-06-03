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

@components.directive 'feed', ['$http', 'Mapper', 'componentItem', 'AlgoliaSearchService', ($http, Mapper, componentItem, AlgoliaSearchService) ->
  restrict: 'A'
  scope: {
    search: '='
    source: '='
    mapper: '='
    columns: '='
    itemTypeName: '='
  }

  link: (scope, element, attrs) ->

    if scope.search
      params = {
        difficulty: 'any'
        generator: 'chefsteps'
        published_status: 'published'
        page: '1'
        search_all: scope.search
      }
      mapper = [
        {
          componentKey: "title",
          sourceKey: "title",
          value: ""
        },
        {
          componentKey: "url",
          sourceKey: "url",
          value: ""
        }
      ]
      AlgoliaSearchService.search(params).then (data) ->
        scope.items = Mapper.mapObject(data, mapper)

    else
      Mapper.do(scope.source, scope.mapper).then (items) ->
        scope.items = items

    scope.itemType = componentItem.get(scope.itemTypeName)

  templateUrl: '/client_views/component_feed.html'
]

@components.directive 'searchFeed', ['AlgoliaSearchService', (AlgoliaSearchService) ->
  restrict: 'A'
  scope: {
    search: '@'
  }

  link: (scope, element, attrs) ->
    params = {
      difficulty: 'any'
      generator: 'chefsteps'
      published_status: 'published'
      page: '1'
      search_all: scope.search
    }
    console.log 'Params: ', params
    AlgoliaSearchService.search(params).then (data) ->
      scope.results = data
  template:
    """
      <div>{{results}}</div>
    """
]
