@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", ($scope, $rootScope, $sce) ->

  $scope.getSearchQuery = ->
    url = $sce.trustAsResourceUrl("/gallery#/?search_all=#{$scope.navbarSearchQuery}")
]