angular.module('ChefStepsApp').directive 'csblinders', [ ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    scope.width = angular.element(element).width()
    scope.objectCount = attrs.objectCount
    scope.blinderWidth = scope.width/scope.objectCount
    scope.$broadcast('blinderWidthReady', scope.blinderWidth)

]

angular.module('ChefStepsApp').directive 'csblinder', [ ->
  restrict: 'A'
  scope: true
  link: (scope, element, attrs) ->
    el = angular.element(element)
    scope.setWidth = ->
      el.width(scope.blinderWidth)

    scope.setPosition = ->
      el.css('left', attrs.index*scope.blinderWidth)

    scope.$on 'blinderWidthReady', (w) ->
      scope.blinderWidth = w.targetScope.blinderWidth
      scope.setWidth()
      scope.setPosition()
]