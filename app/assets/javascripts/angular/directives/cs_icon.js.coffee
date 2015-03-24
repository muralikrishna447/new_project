@app.directive 'csIcon', [ ->
  replace: true
  restrict: 'A'
  scope: {
    csIcon: '@'
  }
  link: (scope, element, attrs) ->
    scope.csIconId = '#' + scope.csIcon

  template:
    """
      <svg class="cs-icon-{{csIcon}}-dims">
        <use xlink:href={{csIconId}}></use>
      </svg>
    """
]