@components.directive 'madlibForm', [ ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->


  templateUrl: '/client_views/component_madlib_form.html'
]

@components.directive 'madlib', [ ->
  restrict: 'A'
  scope: {
    component: '='
  }
  link: (scope, $element, $attrs) ->

  templateUrl: '/client_views/component_madlib.html'
]
