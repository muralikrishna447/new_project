# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'EnrollAssemblyController', ["$scope", "$rootScope", "$http", "csAuthentication", "csAlertService", "csAdwords", "csFacebookConversion", "csStripe", "$timeout", ($scope, $rootScope, $http, csAuthentication, csAlertService, csAdwords, csFacebookConversion, csStripe, $timeout) ->

  $scope.assemblyWelcomeModalOpen = false
  $scope.modalOptions = {dialogFade:true, backdrop: 'static'}

  $scope.waitingforFreeEnrollment = false

  $scope.authentication = csAuthentication
  $scope.alertService = csAlertService
  $scope.isAdmin = csAuthentication.isAdmin()

  $scope.$on "login", (event, data) ->
    $scope.logged_in = true
    $scope.enrolled = true if $scope.isEnrolled() #(data.user)

    if $scope.waitingForFreeEnrollment
      $scope.waitingForFreeEnrollment = false
      $scope.createEnrollment()

  # No longer used, but needs to exist until callers are cleaned up
  $scope.loadFriends = ->
    return

  $scope.waitForLogin = ->
    $scope.waitingForLogin = true

  $scope.waitForFreeEnrollment = ->
    $scope.waitingForFreeEnrollment = true

  $scope.trackEnrollmentWorkaround = (eventData) ->
    # This is a workaround for the fact that intercom can't segment based on the eventData, so
    # also tracking the same data right in the event name.
    Intercom?('trackEvent', "class-enrolled-#{$scope.assembly.slug}", eventData)

  $scope.maybeStartProcessing = (form) ->
    $scope.processing = true
    $scope.errorText = false
    $timeout ( ->
      $scope.disableForm = true
    ), 0

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

  $scope.openModal = ->
    if $scope.check_signed_in()
      $scope.assemblyWelcomeModalOpen = true

  $scope.closeModal = (abandon = true) ->
    $scope.assemblyWelcomeModalOpen = false
    if abandon
      mixpanel.track('Modal Abandoned', {'context' : 'course', 'title' : $scope.assembly.title, 'slug' : $scope.assembly.slug})

  # Free enrollment, either for a free class or redeeming a gift
  $scope.enroll = ->
    $scope.processing = true
    $http(
      method: 'POST'
      url: "/assemblies/#{$scope.assembly.id}/enroll"
    ).success((data, status, headers, config) ->
      $scope.enrolled = true
    )
    $scope.processing = false

  $scope.createEnrollment = ->
    if $scope.check_signed_in()
      $scope.enroll()
      $scope.assemblyWelcomeModalOpen = true
      eventData = {'class' : $scope.assembly.title}
      mixpanel.track('Class Enrolled', eventData)
      Intercom?('trackEvent', 'class-enrolled', eventData)
      $scope.trackEnrollmentWorkaround(eventData)
      console.log 'Class Facebook Conversion: ', 6014798037826
      csFacebookConversion.track(6014798037826,0)
]
