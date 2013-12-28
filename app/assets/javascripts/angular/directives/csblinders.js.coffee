angular.module('ChefStepsApp').directive 'csblinders', [ ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    el = angular.element(element)
    scope.width = angular.element(element).width()
    scope.height = angular.element(element).height()
    console.log scope
    scope.objectCount = attrs.objectCount
    scope.blinderWidth = scope.width/scope.objectCount
    scope.$broadcast('blinderWidthReady', scope.blinderWidth)

    scope.$on 'blinderHeightChanged', (e) ->
      scope.blinderHeight = e.targetScope.height
      el.css('height', scope.blinderHeight)
]

angular.module('ChefStepsApp').directive 'csblinder', [ ->
  restrict: 'A'
  scope: true
  link: (scope, element, attrs) ->
    el = angular.element(element)
    image = el.find('img')
    scope.setWidth = ->
      el.width(scope.blinderWidth)

    scope.setPosition = ->
      el.css('left', attrs.index*scope.blinderWidth)

    scope.setImage = ->
      image.css('width', scope.width)
      image.css('margin-left', -scope.width/2)

    scope.setHeight = ->
      scope.height = image.height()
      el.css('height', scope.height)
      scope.$emit('blinderHeightChanged', scope.height)

    scope.$on 'blinderWidthReady', (w) ->
      scope.blinderWidth = w.targetScope.blinderWidth
      scope.setWidth()
      scope.setPosition()
      scope.setImage()

    image.on 'load', ->
      scope.setHeight()
]