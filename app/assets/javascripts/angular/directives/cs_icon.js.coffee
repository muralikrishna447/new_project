@app.directive 'csIcon', [ ->
  replace: true
  restrict: 'A'
  scope: {
    csIcon: '@'
  }
  link: (scope, element, attrs, csAbtest) ->
    scope.icon = {}

    scope.icon.id = scope.csIcon

  template:
    """
      <svg class="cs-icon-{{icon.id}}-dims">
        <use xlink:href="{{'#' + icon.id}}"></use>
      </svg>
    """
]