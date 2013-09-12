angular.module('ChefStepsApp').controller 'StripeController', ["$scope", "$http", ($scope, $http) ->

  $scope.state = "charge"

  $scope.handleStripe = (status, response) ->
    console.log "STRIPE status: " + status + ", response: " + response

    if response.error
      console.log "STRIPE TOKEN FAIL: " + response.error
      $scope.errorText = response.error
      $scope.processing = false

    else    
      # got stripe token, now charge it or smt
      $http(
        method: 'POST'
        params: 
          stripeToken: response.id
          assembly_id: $scope.assembly.id

        url: '/charges'
      ).success((data, status, headers, config) ->
        $scope.processing = false
        $scope.enrolled = true
        $scope.state = "thanks"
        mixpanel.people.track_charge($scope.assembly.price)

      ).error((data, status, headers, config) ->
        console.log "STRIPE CHARGE FAIL" + data
        $scope.errorText = data.errors[0]
        $scope.processing = false
      )

  $scope.maybeStartProcessing = (form) ->
    if form?.$valid
      $scope.processing = true
      $scope.errorText = false


]