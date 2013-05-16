angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', ($rootScope, $scope, $element, $window) ->

    # We should be active (edit view visible) if either the mouse is over us or
    # a child within us has focus.
    $scope.active = ->
      #$element.height($element.find('.edit-pair-show').height())
      if ! $scope.editMode
        return false
      $scope.mouseCurrentlyOver || ($(document.activeElement).closest('.edit-pair').scope() == $scope)

    $scope.setMouseOver = (over) ->
      if over
        $rootScope.$broadcast("setMouseNotOver")
      $scope.mouseCurrentlyOver = over

    # Without this we are getting some cases where we don't get the mouseleave, maybe because of DOM changes?
    # so you end up with "mouse droppings" of pairs left in the edit state
    $scope.$on "setMouseNotOver", ->
      $scope.setMouseOver(false)

  ]

  link:  (scope, element, attrs) ->

    # If we get freshly added while in edit mode, make us active by focusing first input. Like when a + button is hit.
    if scope.editMode
      scope.setMouseOver(true)
      # Can't give it focus until it has a chance to become visible
      setTimeout (-> scope.$apply($(element).find('input').focus())), 0

  template: '<div ng-switch="" on="active()" class="edit-pair" ng-mouseenter="setMouseOver(true)" ng-mouseleave="setMouseOver(false)">' +
              '<div ng-transclude class="edit-pair-transclude"></div>' +
            '</div>'

angular.module('ChefStepsApp').directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude class="edit-pair-edit"></div>'

angular.module('ChefStepsApp').directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-default="" ng-transclude class="edit-pair-show"></div>'