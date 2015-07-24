# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'ShoppingController', ["$scope", "$rootScope", "$http", "csAuthentication", "$window", "$q", ($scope, $rootScope, $http, csAuthentication, $window, $q) ->

  $scope.authentication = csAuthentication
  $scope.isAdmin = csAuthentication.isAdmin()

  $scope.loggedIn = false

  $scope.product = {}

  $scope.lineItem = {quantity: 1, id: null}

  $scope.loginThenAddToCart = (options) ->
    params = "?add_to_cart=true&product_id=#{options.product_id}&quantity=#{options.quantity}"
    $window.location = "/sign_in?returnTo=#{$window.encodeURIComponent($window.location+params)}"

  $scope.addToCart = (options) ->
    $http.post('/api/v0/shopping/multipass', {product_id: options.product_id, quantity: options.quantity})
      .success((data, status, headers) ->
        $window.location = data.redirect_to
        # $scope.product = data
      )
      .error((data, status, headers) ->
        # Error handling?
      )

  $scope.getProduct = (productID) ->
    $http.get("/api/v0/shopping/product/#{productID}")
      .success((data, status, headers) ->
        $scope.product = data
      )
      .error((data, status, headers) ->
        # Error handling?
      )



]
