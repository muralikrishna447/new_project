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
    search: '@'
    columns: '='
    limitTo: '='
    itemTypeName: '='
  }

  link: (scope, element, attrs) ->
    scope.numLimit = scope.limitTo || 12

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

    scope.$watch 'search', (newValue, oldValue) ->
      if newValue
        AlgoliaSearchService.search(params).then (data) ->
          scope.items = Mapper.mapObject(data, mapper)

  templateUrl: '/client_views/component_feed.html'
]
