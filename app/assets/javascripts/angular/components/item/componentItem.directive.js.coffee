@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    styles: '='
  }
  link: (scope, element, attrs) ->
    scope.itemType = componentItemService.get(scope.itemTypeName)
    console.log 'itemType: ', scope.itemType
  template:
    """
      <div ng-include="itemType.templateUrl"></div>
    """

]
