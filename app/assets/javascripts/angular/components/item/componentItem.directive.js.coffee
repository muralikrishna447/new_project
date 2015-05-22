@components.directive 'componentItem', [ ->
  restrict: 'A'
  scope: {
    item: '='
    templateUrl: '='
    mode: '='
  }
  link: (scope, element, attrs) ->
    console.log 'templateUrl is: ', scope.templateUrl

  template:
    """
      <div ng-include="templateUrl"></div>
    """

]
