@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", ($scope, $rootScope, $sce, csDataLoading) ->
  $scope.dataLoading = csDataLoading

  $rootScope.getTotalUsers = ->
    $scope.totalUsers

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]