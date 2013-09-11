angular.module('ChefStepsApp').controller 'StripeController', ["$scope", "$http", ($scope, $http) ->

  $scope.handleStripe = (status, response) ->
    console.log "STRIPE status: " + status + ", response: " + response
    # there was an error. Fix it.
    if response.error
      alert("STRIPE TOKEN FAIL: ") + response.error
      $scope.errorMessage = response.error
    else    
      # got stripe token, now charge it or smt
      alert("STRIPE TOKEN WIN: ") + response.id
      $http(
        method: 'POST'
        params: {stripeToken: response.id}
        url: '/charges'
      ).success((data, status, headers, config) ->
        alert("STRIPE CHARGE WIN")
        $scope.buyModalOpen = false
      ).error((data, status, headers, config) ->
        alert(data)
      )

]