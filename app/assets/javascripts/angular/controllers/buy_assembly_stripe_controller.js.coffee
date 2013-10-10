# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'BuyAssemblyStripeController', ["$scope", "$http", ($scope, $http) ->

  $scope.buyModalOpen = false

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static'}

  $scope.handleStripe = (status, response) ->
    console.log "STRIPE status: " + status + ", response: " + response

    if response.error
      console.log "STRIPE TOKEN FAIL: " + response.error
      $scope.errorText = response.error.message || response.error
      $scope.processing = false

    else    
      # got stripe token, now charge it or smt
      $http(
        method: 'POST'
        params: 
          stripeToken: response.id
          assembly_id: $scope.assembly.id
          discounted_price: $scope.discounted_price

        url: '/charges'
      ).success((data, status, headers, config) ->
        $scope.processing = false
        $scope.enrolled = true
        $scope.state = "thanks"
        mixpanel.people.track_charge($scope.assembly.price)
        console.log response
        mixpanel.track('Course Purchased', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug, 'payment_type': response.type, 'card_type': response.card.type})

      ).error((data, status, headers, config) ->
        console.log "STRIPE CHARGE FAIL" + data
        $scope.errorText = data.errors[0].message || data.errors[0]
        $scope.processing = false
      ) 

  $scope.maybeStartProcessing = (form) ->
    if form?.$valid
      $scope.processing = true
      $scope.errorText = false

  $scope.openModal = ->
    $scope.state = "charge" 
    if ! $scope.logged_in
      window.location = '/sign_in?notice=' + encodeURIComponent("Please sign in or sign up before purchasing a course.")
    else
      $scope.buyModalOpen = true

  $scope.closeModal = ->
    $scope.buyModalOpen = false


]