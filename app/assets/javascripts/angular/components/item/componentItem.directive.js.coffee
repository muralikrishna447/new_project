@components.directive 'componentItem', [ ->
  restrict: 'A'
  scope: {
    item: '='
    templateUrl: '='
    mode: '='
    apiData: '='
  }
  link: (scope, element, attrs) ->

  template:
    """
      <div ng-include="templateUrl"></div>
    """

]
