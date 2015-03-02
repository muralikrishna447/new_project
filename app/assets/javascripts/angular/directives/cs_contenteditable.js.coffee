@app.directive 'csContenteditable', [ "$sce", "$filter", "$compile", "$sanitize", ($sce, $filter, $compile, $sanitize) ->
  restrict: 'A',
  require: "?ngModel"
  scope: {  placeholder: "=", ngModel: "=", editMode: "=csContenteditable"},
  templateUrl: '_cs_contenteditable.html'

  link: (scope, element, attrs) ->

    scope.$watch 'ngModel', (input) ->
      input = $filter('markdown')($filter('shortcode')(input))

      # Sanitize by default unless a parent specially promises this is safe.
      # This lets us do things like embed mailchimp signup forms or random other
      # scripts we might want to test.
      input = $sanitize(input) unless scope.$parent.createdByAdmin?()

      outElement = $(element).find('.output')

      # Replace last space with &nbsp; for widow control, but not if it
      # appears to be inside an HTML tag.
      # input = input.replace(/(\s)[^\s>]*$/, "&nbsp;")
      outElement.html input
      $compile(outElement.contents()) scope

      return

]
