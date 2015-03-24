@app.directive 'csFlexDropdown', ['$document', ($document) ->
  controller: ($scope) ->
    $scope.menuOpen = false

    toggleMenu: ->
      $scope.menuOpen = ! $scope.menuOpen
      $scope.$broadcast 'menuToggled', $scope.menuOpen

  link: (scope, element, attrs) ->
    scope.$watch 'menuOpen', (newValue, oldValue) ->
      if newValue == true
        element.addClass 'active'
        element.removeClass 'inactive'
      else
        element.removeClass 'active'
        element.addClass 'inactive'

    angular.element($document[0].body).on 'click', (e) =>
      scope.menuOpen = false
      scope.$broadcast 'menuToggled', scope.menuOpen
]

@app.directive 'csFlexDropdownToggle', [ ->
  require: '^csFlexDropdown'
  link: (scope, element, attrs, csFlexDropdownController) ->
    element.bind 'click', (e) ->
      csFlexDropdownController.toggleMenu()
      e.stopPropagation()
]

@app.directive 'csFlexDropdownMenu', [ ->
  require: '^csFlexDropdown'
  link: (scope, element, attrs, csFlexDropdownController) ->
    scope.$on 'menuToggled', (event, menuOpen) ->
      if menuOpen
        element.addClass 'open'
        element.removeClass 'closed'
        element[0].focus()
      else
        element.removeClass 'open'
        element.addClass 'closed'
]