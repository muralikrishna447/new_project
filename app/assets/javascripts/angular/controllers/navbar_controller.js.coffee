@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", ($scope, $rootScope, $sce) ->

  $rootScope.getTotalUsers = ->
    $scope.totalUsers

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]