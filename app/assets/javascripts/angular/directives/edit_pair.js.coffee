angular.module('ChefStepsApp').directive 'cseditpair', ->
  restrict: 'E',
  transclude: true,
  replace: true,
  scope: true,

  controller: ['$rootScope', '$scope', '$element', '$window', ($rootScope, $scope, $element, $window) ->

    $scope.focusedInside = ->
      $(document.activeElement).closest('.edit-pair').scope() == $scope

    $scope.anyEditPairFocused = ->
      $(document.activeElement).closest('.edit-pair').length > 0

    $scope.hasErrors = ->
      $element.find('.ng-invalid').length > 0

    # We should be active (edit half showing) if we have focus, or if hovered and nothing else has focus
    # or if we have an form fields with errors
    $scope.active = ->
      return false if ! $scope.editMode
      return true if $scope.focusedInside()
      return true if $scope.hasErrors()
      ($scope.mouseCurrentlyOver && (! $scope.anyEditPairFocused()))

    $scope.setMouseOver = (over) ->
      if over
        $rootScope.$broadcast("setMouseNotOver")
      $scope.mouseCurrentlyOver = over

    $scope.$watch $scope.focusedInside, ((newValue, oldValue) ->
      $scope.addUndo() if ! newValue
    )

    # Madness. On a click, first fake focus so we become active and our inputs show.
    # Then, try to focus the element the user clicked on, or if we can't figure that out,
    # the first input inside the edit pair.
    $element.on 'click', (event)->
      if $scope.editMode
        if (! $scope.focusedInside())
          $scope.fakeFocus = true
          setTimeout (->
            elem = document.elementFromPoint(event.clientX, event.clientY)
            if (! elem) || (! $(elem).is('input,textarea,select'))
              elem =  $($element).find('input, textarea')[0]
            $scope.$apply(elem.focus())
            $scope.fakeFocus = false
          ), 0

    # Without this we are getting some cases where we don't get the mouseleave, maybe because of DOM changes?
    # so you end up with "mouse droppings" of pairs left in the edit state
    $scope.$on "setMouseNotOver", ->
      $scope.setMouseOver(false)

  ]

  link:  (scope, element, attrs) ->

    # If we get freshly added while in edit mode, make us active by focusing first input. Like when a + button is hit.
    if scope.editMode
      document.activeElement.blur() if document.activeElement
      scope.setMouseOver(true)
      # Can't give it focus until it has a chance to become visible
      setTimeout (-> scope.$apply($(element).find('input, textarea')[0].focus())), 0

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