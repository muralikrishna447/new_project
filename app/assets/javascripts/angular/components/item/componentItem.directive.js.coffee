@components.directive 'componentItem', [ ->
  restrict: 'A'
  scope: {
    item: '='
    templateUrl: '='
    mode: '='
    styles: '='
  }
  link: (scope, element, attrs) ->

  template:
    """
      <div ng-include="templateUrl" ng-if='item'></div>
    """

]
