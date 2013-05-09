angular.module('ChefStepsApp').directive 'csmonitorinputactivity', ->
  restrict: 'A',
  scope: true,

  controller: ['$rootScope', '$scope', '$element', ($rootScope, $scope, $element) ->

    $scope.inputCount = ->
      $element.find('input').length

    $scope.$watch $scope.inputCount, ((newValue, oldValue) ->
      console.log("INPUTS: " + newValue)
      $scope.hasActiveInputs = (newValue > 0)
    ), true

  ]

