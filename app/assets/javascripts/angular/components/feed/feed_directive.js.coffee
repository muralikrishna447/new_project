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

@components.directive 'feed', ['$http', 'Mapper', 'componentItem', ($http, Mapper, componentItem) ->
  restrict: 'A'
  scope: {
    source: '='
    mapper: '='
    columns: '='
    itemTypeName: '='
  }

  link: (scope, element, attrs) ->

    Mapper.do(scope.source, scope.mapper).then (items) ->
      scope.items = items

    scope.itemType = componentItem.get(scope.itemTypeName)

  templateUrl: '/client_views/component_feed.html'
]
