angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', '$timeout', ($rootScope, $scope, $element, $window, $timeout) ->
 
    $scope.focusedInside = ->
      $(document.activeElement).closest('.edit-pair').scope() == $scope

    $scope.anyEditPairFocused = ->
      $(document.activeElement).closest('.edit-pair').length > 0

    $scope.hasErrors = ->
      $element.find('.ng-invalid').length > 0

    # We should be active (edit half showing) if we have focus,
    # or if we have an form fields with errors, or if someone is forcing us to take focus (used
    # for newly added fields)
    $scope.active = ->
      return false if ! $scope.editMode
      return true if $scope.focusedInside()
      return true if $scope.hasErrors()
      return true if $scope.editPending
      false

    $scope.$watch $scope.focusedInside, ((newValue, oldValue) ->
      $scope.addUndo() if oldValue && ! newValue
    )
  ]

  link:  (scope, element, attrs) ->

    # If we get freshly added while in edit mode, make us active by focusing first input. Like when a + button is hit.
    if scope.editMode  && ! scope.preventAutoFocus
      document.activeElement.blur() if document.activeElement
      scope.editPending = true
      # Can't give it focus until it has a chance to become visible
      setTimeout (
        ->
          e = $(element).find('input, textarea')[0]
          scope.$apply(e.focus()) if e
          scope.editPending = false
      ), 100

  template: '<div ng-switch="" on="active()" class="edit-pair">' +
              '<div ng-transclude class="edit-pair-transclude"></div>' +
            '</div>'

angular.module('ChefStepsApp').directive 'cseditpairedit', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-when="true" ng-transclude class="edit-pair-edit"></div>'

angular.module('ChefStepsApp').directive 'cseditpairshow', ->
  restrict: 'E',
  transclude: true,
  template: '<div ng-switch-default="" ng-transclude  class="edit-pair-show"></div>'