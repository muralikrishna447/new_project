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

    scope.track = ->
      mixpanel.track('Component Item Clicked', {itemTypeName: scope.itemTypeName, buttonMessage: scope.item.content.buttonMessage, title: scope.item.content.title, url: scope.item.content.url})

    scope.getButtonMessage = ->
      scope.item.content.buttonMessage or scope.buttonMessage

  template:
    """
      <div class="item-container" ng-include="itemType.templateUrl"></div>
    """

]
