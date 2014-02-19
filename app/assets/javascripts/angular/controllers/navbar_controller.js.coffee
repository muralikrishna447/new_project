@app.controller 'NavbarController', ["$scope", "$sce", ($scope, $sce, csDataLoading) ->
  $scope.dataLoading = csDataLoading
  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]