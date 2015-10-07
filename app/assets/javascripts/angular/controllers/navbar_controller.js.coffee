@app.controller 'NavController', ['$scope', '$window', 'csAuthentication', ($scope, $window, csAuthentication) ->
  @visibleNav = false
  @fixedNav = false
  @previousNavState = false
  previousScroll = 0

  @authentication = csAuthentication.currentUser()

  checkScrollPosition = (pageYOffset) =>
    if pageYOffset > 200
      @fixedNav = true
      @visibleNav = pageYOffset < previousScroll
      @hiddenNav = pageYOffset > previousScroll
      $scope.$apply() if @visibleNav != @previousNavState
      @previousNavState = @visibleNav
      previousScroll = pageYOffset

    if pageYOffset <= 0
      @visibleNav = false
      @fixedNav = false
      @hiddenNav = false
      $scope.$apply() if @visibleNav != @previousNavState

  angular.element($window).on 'scroll', _.throttle(->
    checkScrollPosition @pageYOffset
  ,200)

  this
]
