@components.directive 'componentItem', [ ->
  restrict: 'A'
  scope: {
    item: '='
    templateUrl: '='
    mode: '='
  }
  link: (scope, element, attrs) ->

  template:
    """
      <div ng-include="templateUrl"></div>
    """

]
