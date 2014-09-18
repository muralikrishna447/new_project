@app.directive 'csHasPermission', ['csPermissions', (csPermissions) ->
  restrict: 'A'

  link: (scope, element, attrs) ->
    value = attrs.csHasPermission
    csPermissions.check(value)
]