@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    styles: '='
    viewMode: '='
  }
  link: (scope, element, attrs) ->

    scope.$watch 'itemTypeName', (newValue, oldValue) ->
      if newValue && newValue != oldValue
        scope.itemType = componentItemService.get(scope.itemTypeName)

  template:
    """
      <div ng-include="itemType.templateUrl"></div>
    """

]
