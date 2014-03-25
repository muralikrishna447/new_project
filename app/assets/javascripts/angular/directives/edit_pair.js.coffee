angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', '$timeout', ($rootScope, $scope, $element, $window, $timeout) ->
 
    $scope.hasErrors = ->
      $element.find('.ng-invalid').length > 0

    $scope.$on 'childFocused', (event, newValue) ->
      $scope.addUndo() if $scope.childFocused && ! newValue
 
    # We should be active (edit half showing) if we have focus,
    # or if we have an form fields with errors, or if someone is forcing us to take focus (used
    # for newly added fields)
    $scope.active = ->
      return false if ! $scope.editMode
      return true if $scope.childFocused
      return true if $scope.hasErrors()
      return true if $scope.editPending
      false

    $scope.setEditPending = ->
      if $scope.editMode
        document.activeElement.blur() if document.activeElement
        $scope.editPending = true
        # Can't give it focus until it has a chance to become visible
        setTimeout (
          ->
            e = $($element).find('input, textarea')[0]
            $scope.$apply(e.focus()) if e && ! $scope.$$phase
            $scope.editPending = false
        ), 100
  ]

  link:  (scope, element, attrs) ->
    # If we get freshly added while in edit mode, make us active by focusing first input. Like when a + button is hit.
    if scope.editMode  && ! scope.preventAutoFocus
      scope.setEditPending()

  template: '<div ng-switch="" on="active()" class="edit-pair" cs-watch-focus="">' +
              '<div ng-transclude class="edit-pair-transclude"></div>' +
            '</div>'

angular.module('ChefStepsApp').directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude class="edit-pair-edit"></div>'

angular.module('ChefStepsApp').directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-default="" ng-transclude  class="edit-pair-show" ng-click="setEditPending()"></div>'
