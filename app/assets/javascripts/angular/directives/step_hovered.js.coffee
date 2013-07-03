angular.module('ChefStepsApp').directive 'csstephovered', ->
  restrict: 'A',
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', ($rootScope, $scope, $element, $window) ->

    $scope.setMouseOverStep =  ->
      $rootScope.$broadcast("setMouseNotOverStep")
      $scope.mouseCurrentlyOverStep = true


    # Rather than clearing this on leave, we clear it when another step gets hovered. Makes it less flashy.
    $scope.$on 'setMouseNotOverStep', ->
      $scope.mouseCurrentlyOverStep = false

  ]
