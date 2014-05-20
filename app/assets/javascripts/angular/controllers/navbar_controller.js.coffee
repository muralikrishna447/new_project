@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", "$timeout", ($scope, $rootScope, $sce, csDataLoading, $timeout) ->
  $scope.dataLoading = csDataLoading

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")

  $scope.toggleSearch = ->
    $scope.showSearch = ! $scope.showSearch
    $timeout ->
      $('#nav-search-field').focus() if $scope.showSearch
]
