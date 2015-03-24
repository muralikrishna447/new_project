@app.service 'csFlexDropdownManager', [->
  dropdowns = []

  this.addScope = (dropdown) ->
    dropdowns.push dropdown

  this.open = (scope) ->
    angular.forEach dropdowns, (dropdown) ->
      unless dropdown.$id == scope.$id
        dropdown.menuOpen = false

  return this
]

@app.directive 'csFlexDropdown', ['$document', 'csFlexDropdownManager', ($document, csFlexDropdownManager) ->
  scope: {}
  controller: ['$scope', ($scope) ->
    csFlexDropdownManager.addScope $scope

    $scope.menuOpen = false

    toggleMenu: ->
      $scope.menuOpen = ! $scope.menuOpen
      $scope.$apply()
  ]

  link: (scope, element, attrs) ->
    dropdown = element.find('.flex-dropdown-menu')
    scope.$watch 'menuOpen', (newValue, oldValue) ->
      if newValue == true
        element.addClass 'active'
        element.removeClass 'inactive'
        dropdown.addClass 'open'
        dropdown.removeClass 'closed'
        csFlexDropdownManager.open(scope)
      else
        element.removeClass 'active'
        element.addClass 'inactive'
        dropdown.removeClass 'open'
        dropdown.addClass 'closed'

    $document.on 'click', (e) =>
      scope.menuOpen = false
      scope.$apply()
]

@app.directive 'csFlexDropdownToggle', [ ->
  require: '^csFlexDropdown'
  link: (scope, element, attrs, csFlexDropdownController) ->
    element.bind 'click', (e) ->
      console.log 'clicked'
      csFlexDropdownController.toggleMenu()
      e.stopPropagation()
]