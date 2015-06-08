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
      if newValue
        scope.itemType = componentItemService.get(scope.itemTypeName)

    # scope.$watch 'item', ((newValue, oldValue) ->
    #
    #   if newValue && newValue != oldValue
    #     console.log 'new Item value: ', newValue
    #     scope.item.image = 'https://www.filepicker.io/api/file/S83UVkQFOnyVw5mZkVUA'
    # ), true

  template:
    """
      <div>
        {{item}}
      <div ng-include="itemType.templateUrl"></div>
      </div>
    """

]
