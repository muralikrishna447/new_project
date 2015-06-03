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
      console.log 'mode: ', scope.mode
      if newValue == 'custom'
        scope.templateUrl = scope.itemType.formTemplateUrl
      else
        scope.templateUrl = scope.itemType.templateUrl

    scope.$watch 'item', (newValue, oldValue) ->
      console.log 'new item: ', newValue
      console.log 'old item: ', oldValue

  template:
    """
      <div ng-include="templateUrl"></div>
    """

]
