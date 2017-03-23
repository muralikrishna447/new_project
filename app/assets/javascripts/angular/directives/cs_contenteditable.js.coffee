@app.directive 'csContenteditable', [ "$sce", "$filter", "$compile", "$sanitize", ($sce, $filter, $compile, $sanitize) ->
  restrict: 'A',
  require: "?ngModel"
  scope: {  placeholder: "=", ngModel: "=", editMode: "=csContenteditable"},
  templateUrl: '_cs_contenteditable.html'

  link: (scope, element, attrs) ->

    runFilters = ->
      # Don't run filters in edit mode; you can't see the output then anyhow and it just slows things down
      return if scope.editMode

      input = $filter('markdown')($filter('shortcode')(scope.ngModel))

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

    scope.$watch 'ngModel', -> runFilters()
    scope.$watch 'editMode', -> runFilters()

]
