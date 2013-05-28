angular.module('ChefStepsApp').directive 'csmonitorinputactivity', ->
  restrict: 'C',
  scope: true,

  controller: ['$rootScope', '$scope', '$element', ($rootScope, $scope, $element) ->

    $scope.hasFocus = ->
      ($(document.activeElement).closest('.csmonitorinputactivity').scope() == $scope)

    $scope.$watch $scope.hasFocus, ((newValue, oldValue) ->
      $scope.hasActiveInputs = (newValue > 0)
    ), true

  ]

