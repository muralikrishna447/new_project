app.directive "csDynamicContent", ['$compile', '$sanitize', ($compile, $sanitize) ->
  restrict: "A"
  replace: false
  link: (scope, ele, attrs) ->
    scope.$watch attrs.csDynamicContent, (html) ->
      html = $sanitize(html) if scope.creator
      ele.html html
      $compile(ele.contents()) scope
      return

    return
]