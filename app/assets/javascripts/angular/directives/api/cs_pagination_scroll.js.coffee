@app.directive 'csPaginationScroll', [ ->
  restrict: 'A'
  scope: {
    csPaginationScroll: '&'
  }

  link: (scope, element, attrs) ->
    console.log scope.csPaginationScroll
    console.log scope
    console.log attrs

]