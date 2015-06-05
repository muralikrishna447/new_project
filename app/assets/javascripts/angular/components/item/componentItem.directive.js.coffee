@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    styles: '='
    mode: '='
  }
  link: (scope, element, attrs) ->
    scope.itemType = componentItemService.get(scope.itemTypeName)

    scope.$watch 'mode', (newValue, oldValue) ->
      if scope.itemType
        if newValue == 'custom'
          scope.templateUrl = scope.itemType.formTemplateUrl
        else
          scope.templateUrl = scope.itemType.templateUrl

  template:
    """
      <div ng-include="templateUrl"></div>
    """

]
