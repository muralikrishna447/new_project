# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'BuyAssemblyStripeController', ["$scope", "$http", "csAuthentication", "csAlertService", ($scope, $http, csAuthentication, csAlertService) ->

  $scope.isGift = false
  $scope.buyModalOpen = false
  $scope.giftInfo = {
    emailToRecipient: 1
  }

  $scope.modalOptions = {backdropFade: true, dialogFade:true, backdrop: 'static'}

  $scope.waitingForLogin = false
  $scope.waitingforRedemption = false
  $scope.waitingforFreeEnrollment = false

  $scope.authentication = csAuthentication
  $scope.alertService = csAlertService

  $scope.loginState = null
  $scope.freeTrialText = null
  $scope.freeTrialCode = false
  $scope.freeTrialHours = null
  $scope.trialNotificationSent = false

  $scope.$on "login", (event, data) ->
    $scope.logged_in = true
    $scope.enrolled = true if $scope.isEnrolled() #(data.user)
    # In the process of switching this over to a state rather than a boolean configuration.
    switch($scope.loginState)
      when "freeTrial"
        $scope.loginState = null
        $scope.freeTrial()
      else
        if $scope.waitingForFreeEnrollment
          $scope.waitingForFreeEnrollment = false
          $scope.free_enrollment()
        if $scope.waitingForRedemption
          $scope.waitingForRedemption = false
          $scope.redeemGift()
        if $scope.waitingForLogin
          $scope.waitingForLogin = false
          if $scope.isEnrolled(data.user) && $scope.isGift == false
            window.location = $scope.assemblyPath
          else
            $scope.openModal($scope.isGift)

  # A little hacky but it didn't like setting the variable directly from the view
  $scope.buyingGift = ->
    $scope.isGift = true

  $scope.waitForLogin = ->
    $scope.waitingForLogin = true

  $scope.waitForRedemption = ->
    $scope.waitingForRedemption = true

  $scope.waitForFreeEnrollment = ->
    $scope.waitingForFreeEnrollment = true

  $scope.setLoginState = (state) ->
    $scope.loginState = state

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
        $scope.enrolled = true unless $scope.isGift
        $scope.state = "thanks"
        mixpanel.people.track_charge($scope.discounted_price)
        mixpanel.track('Course Purchased', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug, 'discounted_price': $scope.discounted_price, 'payment_type': response.type, 'card_type': response.card.type, 'gift' : $scope.isGift, 'ambassador' : $scope.ambassador})
        mixpanel.people.append('Classes Purchased', $scope.assembly.title)
        mixpanel.people.append('Classes Enrolled', $scope.assembly.title)
        mixpanel.people.set('Paid Course Abandoned' : false)
        _gaq.push(['_trackEvent', 'Course', 'Purchased', $scope.assembly.title, $scope.discounted_price, true])
        $scope.shareASale($scope.discounted_price, response.id)
        $scope.adroll($scope.assembly.title)

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
    if !$scope.logged_in
      # window.location = '/sign_in?notice=' + encodeURIComponent("Please sign in or sign up before enrolling in a course.")
      return false
    true

  $scope.enrollment = ->
    user = $scope.authentication.currentUser()
    return null unless user && user.enrollments
    _.find(user.enrollments, (enrollment) -> enrollment.enrollable_id == $scope.assembly.id && enrollment.enrollable_type == "Assembly" )

  $scope.isEnrolled = ->
    !!$scope.enrollment()

  $scope.isFreeTrial = ->
    enrollment = $scope.enrollment()
    return false unless enrollment
    !!enrollment.trial_expires_at

  $scope.differenceInTime = ->
    enrollment = $scope.enrollment()
    return false unless enrollment
    trial_expiration = new Date(enrollment.trial_expires_at)
    current_time = new Date()
    difference = trial_expiration - current_time
    (difference/(1000*60))

  $scope.isExpired = ->
    enrollment = $scope.enrollment()
    return false if !enrollment || isNaN(Date.parse(enrollment.trial_expires_at))
    new Date(enrollment.trial_expires_at) < new Date()

  $scope.openModal = (gift) ->
    $scope.isGift = gift
    $scope.recipientMessage = ""
    $scope.state = if gift then "gift" else "charge"

    $http.get('/splitty/finished?experiment=' + $scope.split_name)
    mixpanel.track('Course Buy Button Clicked', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug})
    _gaq.push(['_trackEvent', 'Buy Button', 'Clicked', $scope.assembly.title, null, true])

    if $scope.check_signed_in()
      $scope.buyModalOpen = true

  $scope.closeModal = (abandon = true) ->
    $scope.buyModalOpen = false
    if abandon
      mixpanel.track('Modal Abandoned', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug})
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

  $scope.shareASale = (amount, tracking) ->
    $http(
      url: "/affiliates/share_a_sale"
      method: "GET"
      params:
        amount: amount
        tracking: tracking
      )

  $scope.adminSendGift = ->
    $http(
      method: 'POST'
      params:
        stripeToken: null
        assembly_id: $scope.assembly.id
        discounted_price: 0.0
        gift_info: $scope.giftInfo

      url: '/charges'

    ).success((data, status, headers, config) ->
      $scope.processing = false
      $scope.state = "thanks"
    ).error((data, status, headers, config) ->
      console.log "STRIPE CHARGE FAIL" + data
      $scope.errorText = data.errors[0].message || data.errors[0]
      $scope.processing = false
    )

  $scope.adroll = (title) ->
    if title
      if title == 'French Macarons'
        segmentName = 'fmpurchase'
      else
        segmentName = title.toLowerCase().replace(' ','-') + '-purchase'

      try
        __adroll.record_user "adroll_segments": segmentName

  $scope.freeTrial = ->
    $scope.processing = true
    $http(
      method: 'POST'
      params:
        assembly_id: $scope.assembly.id
        discounted_price: 0
        free_trial: $scope.freeTrialCode
      url: '/charges'
    ).success( (data, status, headers, config) ->
      $scope.processing = false
      $scope.state = "free_trial"
      $scope.buyModalOpen = true
    ).error( (data, status, headers, config) ->
      $scope.processing = false
      console.log "FAIL" + data
    )

  $scope.freeTrialExpiredNotice = ->
    if $scope.isExpired()
      $scope.alerts.addAlert({message: "Your free trial has expired, please buy the class to continue.<br/>Please contact info@chefsteps.com if there are any problems.", type: "success", class: "long-header"})

  $scope.freeTrialLogger = ->
    if $scope.freeTrialCode && (! $scope.isExpired()) && (! $scope.trialNotificationSent)
      mixpanel.track('Free Trial Offered', {context:'course', title: $scope.assembly.title, slug: $scope.assembly.slug, length: $scope.freeTrialHours})
      mixpanel.people.set('Free Trial Offered': $scope.assembly.title)
      $scope.trialNotificationSent = true

]