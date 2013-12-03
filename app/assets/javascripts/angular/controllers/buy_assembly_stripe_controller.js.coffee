# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'BuyAssemblyStripeController', ["$scope", "$http", ($scope, $http) ->

  $scope.isGift = false
  $scope.buyModalOpen = false
  $scope.giftInfo = {
    emailToRecipient: 1
  }

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static'}

  # A little hacky but it didn't like setting the variable directly from the view
  $scope.buyingGift = ->
    $scope.isGift = true

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
          gift_info: $scope.giftInfo

        url: '/charges'

      ).success((data, status, headers, config) ->
        $scope.processing = false
        $scope.enrolled = true
        $scope.state = "thanks"
        mixpanel.people.track_charge($scope.discounted_price)
        mixpanel.track('Course Purchased', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug, 'discounted_price': $scope.discounted_price, 'payment_type': response.type, 'card_type': response.card.type, 'gift' : $scope.isGift})
        mixpanel.people.append('Classes Purchased', $scope.assembly.title)
        mixpanel.people.append('Classes Enrolled', $scope.assembly.title)
        mixpanel.people.set('Paid Course Abandoned' : false)
        _gaq.push(['_trackEvent', 'Course', 'Purchased', $scope.assembly.title, $scope.discounted_price, true])
        try
          __adroll.record_user "adroll_segments": "fmpurchase"

      ).error((data, status, headers, config) ->
        console.log "STRIPE CHARGE FAIL" + data
        $scope.errorText = data.errors[0].message || data.errors[0]
        $scope.processing = false
      )

  $scope.maybeStartProcessing = (form) ->
    if form?.$valid
      $scope.processing = true
      $scope.errorText = false

  $scope.maybeMoveToCharge = (form) ->
    if form?.$valid
      $scope.state = "charge"

  $scope.check_signed_in = ->
    # For e2e tests, don't require login
    if $scope.rails_env? && $scope.rails_env == "angular"
      return true
    if ! $scope.logged_in
      window.location = '/sign_in?notice=' + encodeURIComponent("Please sign in or sign up before enrolling in a course.")
      false
    true

  $scope.$on "loginSuccessful", (event, data) ->
    $scope.logged_in = true
    if $scope.isEnrolled(data.user) && $scope.isGift == false
      window.location = $scope.assemblyPath
    else
      $scope.openModal($scope.isGift)

  $scope.isEnrolled = (user) ->
    !!_.find(user.enrollments, (enrollment) -> enrollment.enrollable_id == $scope.assembly.id && enrollment.enrollable_type == "Assembly" )

  $scope.openModal = (gift) ->
    $scope.isGift = gift
    $scope.recipientMessage = ""
    $scope.state = if gift then "gift" else "charge"

    $http.put('/splitty/finished?experiment=' + $scope.split_name)
    mixpanel.track('Course Buy Button Clicked', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug})
    _gaq.push(['_trackEvent', 'Buy Button', 'Clicked', $scope.assembly.title, null, true])

    if $scope.check_signed_in()
      $scope.buyModalOpen = true

  $scope.closeModal = (abandon = true) ->
    $scope.buyModalOpen = false
    if abandon
      mixpanel.track('Course Buy Box Abandoned', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug})
      mixpanel.people.set('Paid Course Abandoned' : $scope.assembly.title)

  # Free enrollment, either for a free class or redeeming a gift
  $scope.enroll = ->
    $scope.processing = true
    $http(
      method: 'POST'
      params:
        assembly_id: $scope.assembly.id
        discounted_price: $scope.discounted_price
        gift_certificate: $scope.gift_certificate
      url: '/charges'
    ).success((data, status, headers, config) ->
      $scope.enrolled = true
    )
    $scope.processing = false

  $scope.redeemGift = ->
    if $scope.check_signed_in()
      $scope.enroll()
      $scope.state = "thanks_redeem"
      $scope.buyModalOpen = true

  $scope.free_enrollment = ->
    if $scope.check_signed_in()
      $scope.enroll()
      $scope.state = "free_enrollment"
      $scope.buyModalOpen = true
      mixpanel.track('Class Enrolled', {'class' : $scope.assembly.title})

]