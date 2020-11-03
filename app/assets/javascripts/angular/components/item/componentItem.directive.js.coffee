@components.directive 'componentItem', ['componentItemService', (componentItemService) ->
  restrict: 'A'
  scope: {
    item: '='
    itemTypeName: '='
    theme: '='
    viewMode: '='
    charLimit: '=?'
    buttonMessage: '=?'
  }
  link: (scope, element, attrs) ->

    scope.$watch 'itemTypeName', (newValue, oldValue) ->
      if newValue
        scope.itemType = componentItemService.get(scope.itemTypeName)

    scope.getButtonMessage = ->
      scope.item.content.buttonMessage or scope.buttonMessage

    scope.track = ->
      console.log('Component Item Clicked')

  template:
    """
      <div class="item-container" ng-include="itemType.templateUrl"></div>
    """

]
