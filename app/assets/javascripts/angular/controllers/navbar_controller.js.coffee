@app.controller 'NavbarController', ["$scope", "$sce", ($scope, $sce) ->
  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]