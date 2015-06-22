@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    theme: '='
    viewMode: '='
    charLimit: '='
  }
  link: (scope, element, attrs) ->

    scope.$watch 'itemTypeName', (newValue, oldValue) ->
      if newValue
        scope.itemType = componentItemService.get(scope.itemTypeName)

  template:
    """
      <div class="item-container" ng-include="itemType.templateUrl"></div>
    """

]
