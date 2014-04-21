@app.directive 'csContenteditable', [ "$sce", "$filter", "$compile", "$sanitize", ($sce, $filter, $compile, $sanitize) ->
  restrict: 'A',
  require: "?ngModel"
  scope: {  placeholder: "=", ngModel: "=", editMode: "=csContenteditable", creator: "="},
  templateUrl: '_cs_contenteditable.html'

  link: (scope, element, attrs) ->

    scope.$watch 'ngModel', (input) ->
      input = $filter('markdown')($filter('shortcode')(input))
      input = $sanitize(input) if scope.creator
      outElement = $(element).find('.output')
      outElement.html input
      $compile(outElement.contents()) scope
      return
    
]
