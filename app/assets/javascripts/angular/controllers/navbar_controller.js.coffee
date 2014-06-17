@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", "$timeout", ($scope, $rootScope, $sce, csDataLoading, $timeout) ->

  $scope.toggleSearch = ->
    $scope.showSearch = ! $scope.showSearch
    $timeout ->
      $('#nav-search-field').focus() if $scope.showSearch

  $scope.toggleMenu = ->
    $scope.showMenu = ! $scope.showMenu
]

@app.controller 'SearchController', ["$scope", "$sce", "$location", ($scope, $sce, $location) ->

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
    window.location = url
]