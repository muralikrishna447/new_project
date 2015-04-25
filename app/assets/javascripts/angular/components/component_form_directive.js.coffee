@app.directive 'componentForm', [ ->
  restrict: 'A'
  scope: {
    component: '='
    formState: '='
  }
  link: (scope, element, attrs) ->
    # console.log 'formData: ', scope.formData
    # scope.container = {}
    # scope.container.form = scope.formData

    # scope.component = scope.formData

    scope.includePreview = (componentType) ->
      return "/client_views/container_#{componentType}.html"

    scope.includeForm = (componentType) ->
      return "/client_views/component_#{componentType}_form.html"

    scope.toggle = ->
      if scope.formState == 'edit'
        scope.formState = ''
      else if scope.formState == 'new'
        scope.formState = ''
      else
        scope.formState = 'edit'
  templateUrl: '/client_views/component_form.html'
]