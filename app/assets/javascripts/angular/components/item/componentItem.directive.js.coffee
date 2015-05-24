@components.directive 'componentItem', [ ->
  restrict: 'A'
  scope: {
    item: '='
    templateUrl: '='
    mode: '='
    apiData: '='
  }
  link: (scope, element, attrs) ->
    scope.$watch 'item', (newValue, oldValue) ->
      if newValue && newValue != oldValue
        console.log 'ITEM: ', newValue
        console.log 'componentItem scope: ', scope

  template:
    """
      <div ng-include="templateUrl" ng-if='item'></div>
    """

]
