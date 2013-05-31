angular.module('ChefStepsApp').directive 'csstephovered', ->
  restrict: 'A',
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', ($rootScope, $scope, $element, $window) ->

    $scope.setMouseOverStep = (over) ->
      #if over
        #$rootScope.$broadcast("setMouseNotOver")
      $scope.mouseCurrentlyOverStep = over

    # Without this we are getting some cases where we don't get the mouseleave, maybe because of DOM changes?
    # so you end up with "mouse droppings" of pairs left in the edit state
    #$scope.$on "setMouseNotOver", ->
      #$scope.setMouseOver(false)

  ]
