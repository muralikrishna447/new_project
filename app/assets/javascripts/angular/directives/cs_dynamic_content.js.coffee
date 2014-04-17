app.directive "csDynamicContent", ($compile) ->
  restrict: "A"
  replace: true
  link: (scope, ele, attrs) ->
    scope.$watch attrs.csDynamicContent, (html) ->
      ele.html html
      console.log html
      $compile(ele.contents()) scope
      return

    

    return