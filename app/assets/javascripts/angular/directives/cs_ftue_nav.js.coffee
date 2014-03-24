angular.module('ChefStepsApp').directive 'csFtueNav', ['csIntent', 'csFtue', (csIntent, csFtue) ->
  restrict: 'E'
  link: (scope, element, attrs) ->
    scope.ftue = csFtue
    scope.$on 'intentChanged', (intent) ->
      if csIntent.intent == 'ftue'
        scope.showFtue = true
      else
        scope.showFtue = false

    scope.prev = ->
      csFtue.prev()

    scope.next = ->
      csFtue.next()

    scope.currentNumber = ->
      scope.ftue.currentIndex + 1

    scope.ftueLength = ->
      scope.ftue.items.length

    scope.showPrev = ->
      true if scope.ftue.currentIndex > 0

    scope.showNext = ->
      true if scope.currentNumber() < scope.ftueLength()

  templateUrl: '/client_views/_ftue.html'
]