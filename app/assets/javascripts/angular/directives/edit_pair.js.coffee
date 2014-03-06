angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', '$timeout', ($rootScope, $scope, $element, $window, $timeout) ->
    # Sometimes a useful place to set breakpoints
    setEditPending = (scope, val) ->
      scope.editPending = val

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

    $scope.setMouseOver = (over) ->
      if over
        $rootScope.$broadcast("setMouseNotOver")
      $scope.mouseCurrentlyOver = over

    $scope.$watch $scope.focusedInside, ((newValue, oldValue) ->
      $scope.addUndo() if oldValue && ! newValue
    )

    # Madness. On a click, wait for our edit half to show.
    # Then, try to focus the element the user clicked on, or if we can't figure that out,
    # the first input inside the edit pair.
    $element.on 'click', (event)->
      if $scope.editMode
        $rootScope.$broadcast("setEditNotPending")
        if (! $scope.focusedInside())
          setEditPending($scope, true)
          $scope.$apply() if ! $scope.$$phase
          $timeout (->
            elem = document.elementFromPoint(event.clientX, event.clientY)
            if (! elem) || (! $(elem).is('input,textarea,select'))
              elem =  $($element).find('input, textarea')[0]
              setEditPending($scope, false)

            if elem
              $scope.$apply(elem.focus())
          ), 100
      true

    # Without this we are getting some cases where we don't get the mouseleave, maybe because of DOM changes?
    # so you end up with "mouse droppings" of pairs left in the edit state
    $scope.$on "setMouseNotOver", ->
      $scope.setMouseOver(false)

    $scope.$on "setEditNotPending", ->
      setEditPending($scope, false)



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
  template: '<div ng-switch-default="" ng-transclude  class="edit-pair-show"></div>'