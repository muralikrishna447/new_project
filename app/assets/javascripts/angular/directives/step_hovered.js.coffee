angular.module('ChefStepsApp').directive 'csstephovered', ->
  restrict: 'A',
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', ($rootScope, $scope, $element, $window) ->

    $scope.setMouseOverStep = (over) ->
      $scope.mouseCurrentlyOverStep = over

  ]
