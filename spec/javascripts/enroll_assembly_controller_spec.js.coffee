describe "EnrollAssemblyController", ->
  scope = null
  controller = null

  # you need to indicate your module in a test
  beforeEach(angular.mock.module('ChefStepsApp'))

  # IMPORTANT!
  # this is where we're setting up the $scope and
  # calling the controller function on it, injecting
  # all the important bits, like our mockService
  beforeEach(angular.mock.inject( ($controller, $rootScope, _$httpBackend_, $window) ->
    # create a scope object for us to use.
    scope = $rootScope.$new()
    # we're just declaring the httpBackend here, we're not setting up expectations or when's - they change on each test
    scope.httpBackend = _$httpBackend_
    $controller("EnrollAssemblyController", {$scope: scope})
    mixpanel = {
      people:
        track_charge: ((price)-> true)
        append: ((key, value) -> true)
        set: ((key, value) -> true)
      track: ((key, objects) -> true)
    }
    gaq = jasmine.createSpyObj('gaq', ['push'])
    $window.Intercom = (a, b, c) ->
      console.log "Called Intercom?(#{a}, #{b}, #{c})"

    $window.mixpanel = mixpanel
    $window._gaq = gaq
    # mixpanel = jasmine.createSpyObj 'mixpanel', ['people', "track"]
  ))

  afterEach ->
    scope.httpBackend.verifyNoOutstandingExpectation()
    scope.httpBackend.verifyNoOutstandingRequest()

  describe "#waitForLogin", ->
    it "should set waitingForLogin to true", ->
      scope.waitingForLogin = false
      scope.waitForLogin()
      expect(scope.waitingForLogin).toBe(true)

  describe "#waitForFreeEnrollment", ->
    it "should set waitingForFreeEnrollment to true", ->
      scope.waitingForFreeEnrollment = false
      scope.waitForFreeEnrollment()
      expect(scope.waitingForFreeEnrollment).toBe(true)


  describe "#maybeStartProcessing", ->
    describe "if valid", ->
      it "should set processing to true", ->
        form = jasmine.createSpyObj('form', ['$valid'])
        scope.maybeStartProcessing(form)
        expect(scope.processing).toBe(true)

      it "should set error text to false", ->
        form = jasmine.createSpyObj('form', ['$valid'])
        scope.maybeStartProcessing(form)
        expect(scope.errorText).toBe(false)

 describe "#check_signed_in", ->
    it "should return true if angular rails env is set", ->
      scope.rails_env = "angular"
      expect(scope.check_signed_in()).toBe(true)

    it "should return true if logged in", ->
      scope.logged_in = true
      expect(scope.check_signed_in()).toBe(true)

    it "should return false if not logged in", ->
      scope.logged_in = false
      expect(scope.check_signed_in()).toBe(false)

  describe "#isEnrolled", ->
    it "should return true if the user is enrolled in the activity", ->
      scope.assembly = {id: 1}
      user = {email:"me3@danahern.com",enrollments:[{enrollable_id:1,enrollable_type:"Assembly"}]}
      scope.authentication.setCurrentUser(user)
      expect(scope.isEnrolled()).toBe(true)

    it "should return false if the user is not enrolled in the activity", ->
      scope.assembly = {id: 1}
      user = {email:"me3@danahern.com",enrollments:[]}
      scope.authentication.setCurrentUser(user)
      expect(scope.isEnrolled()).toBe(false)

  describe "#enrollment", ->
    it "should return an enrollment for the user if they are enrolled", ->
      scope.assembly = {id: 1}
      user = {email:"me3@danahern.com",enrollments:[{enrollable_id:1,enrollable_type:"Assembly"}]}
      scope.authentication.setCurrentUser(user)
      expect(scope.enrollment()).toEqual({enrollable_id:1,enrollable_type:"Assembly"})

    it "should return null if not enrolled", ->
      scope.assembly = {id: 1}
      user = {email:"me3@danahern.com",enrollments:[]}
      scope.authentication.setCurrentUser(user)
      expect(scope.enrollment()).toEqual(null)

  describe "#openModal", ->
    describe "if it is a gift", ->
      beforeEach ->
        scope.assembly = {id: 1, title: "Testing Fun", slug:"Testing-Fun"}

      it "it should set assemblyWelcomeModalOpen to true if signed in", ->
        scope.logged_in = true
        scope.openModal(true)
        expect(scope.assemblyWelcomeModalOpen).toBe(true)

  describe "#closeModal", ->
    beforeEach ->
      scope.assembly = {id: 1, title: "Testing Fun", slug:"Testing-Fun"}

    it "should set assemblyWelcomeModalOpen to be false", ->
      scope.closeModal()
      expect(scope.assemblyWelcomeModalOpen).toBe(false)

  describe "#enroll", ->
    beforeEach ->
      scope.assembly = {id: 321}
      scope.httpBackend.expect(
        'POST'
        '/assemblies/321/enroll'
      ).respond(200, {'success': true})

    it "should set processing to false when completed", ->
      scope.enroll()
      scope.httpBackend.flush()
      expect(scope.processing).toBe(false)

    describe "success", ->
      it "should set enrolled to true", ->
        scope.enroll()
        scope.httpBackend.flush()
        expect(scope.enrolled).toBe(true)

  describe "#createEnrollment free", ->
    beforeEach ->
      scope.assembly = {id: 1, title: "Testing Fun", slug:"Testing-Fun"}
      spyOn(scope, "enroll")
      scope.logged_in = true

    it "should set assemblyWelcomeModalOpen to true", ->
      scope.free_enrollment()
      expect(scope.assemblyWelcomeModalOpen).toBe(true)

    it "should call enroll", ->
      scope.free_enrollment()
      expect(scope.enroll()).toHaveBeenCalled

  describe "$on", ->
    beforeEach ->
      scope.enrolled = false
      scope.assembly = {id: 123}
      spyOn(scope.authentication, "currentUser").andReturn({name: "Dan Ahern", enrollments: [{enrollable_id: 123, enrollable_type: "Assembly"}]})

    it "should set logged_in to true", ->
      scope.$broadcast("login", {user: {name: "Dan Ahern"}})
      expect(scope.logged_in).toBe(true)

    it "should set enrolled to true if in the class", ->
      scope.$broadcast("login", {user: {name: "Dan Ahern", enrollments: [{enrollable_id: 123, enrollable_type: "Assembly"}]}})
      expect(scope.enrolled).toBe(true)

