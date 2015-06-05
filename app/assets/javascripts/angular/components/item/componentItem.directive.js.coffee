@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    styles: '='
    viewMode: '='
  }
  link: (scope, element, attrs) ->
    scope.itemType = componentItemService.get(scope.itemTypeName)

  template:
    """
      <div ng-include="itemType.templateUrl"></div>
    """

]
