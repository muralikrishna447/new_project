@app.directive 'componentForm', [ ->
  restrict: 'A'
  scope: {
    formData: '='
    formState: '='
  }
  link: (scope, element, attrs) ->
    # console.log 'formData: ', scope.formData
    scope.container = {}
    scope.container.form = scope.formData

    scope.includePreview = (containerType) ->
      return "/client_views/container_#{containerType}.html"

    scope.includeForm = (containerType) ->
      return "/client_views/component_#{containerType}_form.html"

    scope.toggle = ->
      if scope.formState == 'edit'
        scope.formState = ''
      else if scope.formState == 'new'
        scope.formState = ''
      else
        scope.formState = 'edit'
  templateUrl: '/client_views/component_form.html'
]