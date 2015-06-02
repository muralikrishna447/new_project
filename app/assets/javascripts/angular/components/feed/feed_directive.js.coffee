# Directive to load a feed
# Example:
# .component.component-full(feed source="'http://www.chefsteps.com/api/v0/activities'" mapper='home.testComponent.metadata.api.mapper' columns='3' item-type-name="'Square A'")

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
