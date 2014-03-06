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

  template: '
    <div class="ftue-nav" ng-show="showFtue">
      <btn class="btn btn-circle-large btn-left pull-left" ng-click="prev()" ng-show="showPrev()">
        <i class="icon-angle-left"></i>
      </btn>
      <div class="ftue-nav-middle">
        <div class="ftue-nav-title">
          <h4>{{ftue.current.title}}</h4>
          <div>Step {{currentNumber()}} of {{ftueLength()}}</div>
        </div>
      </div>
      <btn class="btn btn-circle-large btn-right pull-right" ng-click="next()" ng-show="showNext()">
        <i class="icon-angle-right"></i>
      </btn>
      <btn class="btn btn-large btn-primary btn-done pull-right" ng-click="next()" ng-show="!showNext()">
        Done!
      </btn>
    </div>
  '
]