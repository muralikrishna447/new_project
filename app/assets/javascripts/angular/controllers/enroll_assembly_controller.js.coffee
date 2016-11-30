# This mixes the concerns of managing a general purpose modal for charging stripe with
# the special case of buying an assembly. Would be better to separate.

angular.module('ChefStepsApp').controller 'EnrollAssemblyController', ["$scope", "$rootScope", "$http", "csAuthentication", "csAlertService","$timeout", ($scope, $rootScope, $http, csAuthentication, csAlertService, $timeout) ->

  $scope.authentication = csAuthentication
  $scope.alertService = csAlertService

  $scope.waitingforFreeEnrollment = false
  $scope.assemblyWelcomeModalOpen = false

  $scope.modalOptions = {dialogFade:true, backdrop: 'static'}
  $scope.isAdmin = csAuthentication.isAdmin()

  $scope.$on "login", (event, data) ->
    $scope.logged_in = true
    $scope.enrolled = true if $scope.isEnrolled()

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

  # Enroll in a free or premium class. The UI won't present the option of
  # enrolling in premium if the user isn't premium, but if someone tries, it
  # will be rejected from the server side.
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
]
