angular.module('ChefStepsApp').directive "csenforceaspect", ["$window", ($window) ->
  (scope, element) ->

    scope.getWidth = ->
      $(element).width()

    scope.$watch scope.getWidth, ((newValue, oldValue) ->
      scope.width = newValue
      scope.setHeight = ->
        height: (newValue * 9.0 / 16.0) + "px"
    ), true

    angular.element($window).bind "resize", ->
      scope.$apply()
]
