@app.controller 'csDropdownController', ['$scope', '$window', '$rootScope', ($scope, $window, $rootScope) ->
  @showMenu = false

  @toggle = (e) =>
    currentShowMenu = @showMenu
    $rootScope.$broadcast 'closeAllDropdowns'
    if currentShowMenu
      @showMenu = false
    else
      @showMenu = true
    e.stopPropagation()

  $scope.$on 'closeAllDropdowns', =>
    console.log 'closing all'
    @showMenu = false

  angular.element($window).bind 'click', (e) =>
    if @showMenu
      @showMenu = false
      $scope.$apply()

  this
]
