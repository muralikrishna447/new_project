@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", "$timeout", ($scope, $rootScope, $sce, csDataLoading, $timeout) ->
  $scope.dataLoading = csDataLoading

  $scope.toggleSearch = ->
    $scope.showSearch = ! $scope.showSearch
    $timeout ->
      $('#nav-search-field').focus() if $scope.showSearch
]

@app.controller 'SearchController', ["$scope", "$sce", "$location", ($scope, $sce, $location) ->

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
    window.location = url
]