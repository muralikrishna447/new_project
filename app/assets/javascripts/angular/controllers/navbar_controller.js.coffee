@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", "$timeout", ($scope, $rootScope, $sce, csDataLoading, $timeout) ->
  $scope.showDropdown = {}

  $scope.toggleSearch = ->
    $scope.showSearch = ! $scope.showSearch
    $timeout (->
      $('input').focus()
    ),300

  $scope.toggleMenu = ->
    $scope.showMenu = ! $scope.showMenu

  $scope.toggleDropdown = (dropdownName) ->
    if $scope.showDropdown == dropdownName
      $scope.showDropdown = {}
    else
      $scope.showDropdown = dropdownName
]

@app.controller 'SearchController', ["$scope", "$sce", "$location", ($scope, $sce, $location) ->

  $scope.getSearchQuery = ->
    hash = "?search_all=#{$scope.navbarSearchQuery}&sort=relevance"
    url = $sce.trustAsResourceUrl("/gallery" + hash)
    window.location = url
]
