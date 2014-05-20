angular.module('ChefStepsApp').directive "csenforceaspect", ["$window", ($window) ->
  scope: { aspectRatio: '='}
  link: (scope, element, attrs) ->

    scope.getWidth = ->
      $(element).find('iframe').width()

    scope.$watch scope.getWidth, ((newValue, oldValue) ->
      scope.width = newValue
      scope.setHeight = ->
        height: (newValue * (attrs.aspectRatio || (9.0 / 16.0))) + "px"
    ), true

    angular.element($window).bind "resize", ->
      scope.$apply()
]
