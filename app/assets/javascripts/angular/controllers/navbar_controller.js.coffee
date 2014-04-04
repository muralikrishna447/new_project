@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", ($scope, $rootScope, $sce, csDataLoading) ->
  $scope.dataLoading = csDataLoading

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]