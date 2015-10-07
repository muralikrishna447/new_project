@app.controller 'NavController', ($scope, $window) ->
  @visibleNav = false
  @fixedNav = false
  @previousNavState = false
  previousScroll = 0

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


@app.controller 'NavbarController', ["$scope", "$rootScope", "$sce", "csDataLoading", "$timeout", ($scope, $rootScope, $sce, csDataLoading, $timeout) ->
  $scope.showDropdown = {}

  $scope.toggleSearch = ->
    $scope.showSearch = ! $scope.showSearch
    $timeout (->
      $('input').focus()
    ),300

  $scope.toggleMenu = ->
    $scope.showMenu = ! $scope.showMenu

  $scope.toggleDropdown = (dropdownName) ->
    if $scope.showDropdown == dropdownName
      $scope.showDropdown = {}
    else
      $scope.showDropdown = dropdownName
]

@app.controller 'SearchController', ["$scope", "$sce", "$location", ($scope, $sce, $location) ->

  $scope.getSearchQuery = ->
    hash = "?search_all=#{$scope.navbarSearchQuery}&sort=relevance"
    url = $sce.trustAsResourceUrl("/gallery" + hash)
    window.location = url
]
