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
      # Replace last space with &nbsp; for widow control, but not if it 
      # appears to be inside an HTML tag.
      # input = input.replace(/(\s)[^\s>]*$/, "&nbsp;")
      outElement.html input
      $compile(outElement.contents()) scope
      return
    
]
