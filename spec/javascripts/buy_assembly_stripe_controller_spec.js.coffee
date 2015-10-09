describe "BuyAssemblyStripeController", ->
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
    $controller("BuyAssemblyStripeController", {$scope: scope})
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

  describe "#buyingGift", ->
    it "should set isGift to true", ->
      scope.isGift = false
      scope.buyingGift()
      expect(scope.isGift).toBe(true)

  describe "#waitForLogin", ->
    it "should set waitingForLogin to true", ->
      scope.waitingForLogin = false
      scope.waitForLogin()
      expect(scope.waitingForLogin).toBe(true)

  describe "#waitForRedemption", ->
    it "should set waitingForRedemption to true", ->
      scope.waitingForRedemption = false
      scope.waitForRedemption()
      expect(scope.waitingForRedemption).toBe(true)

  describe "#waitForFreeEnrollment", ->
    it "should set waitingForFreeEnrollment to true", ->
      scope.waitingForFreeEnrollment = false
      scope.waitForFreeEnrollment()
      expect(scope.waitingForFreeEnrollment).toBe(true)

  describe "#handleStripe", ->
    beforeEach ->
      spyOn(scope, 'shareASale')

    describe "response has an error", ->
      it "should set processing false", ->
        scope.handleStripe(200, {error: {message: "Error on processing"}})
        expect(scope.processing).toBe(false)

      it "should set the errorText to the response error", ->
        scope.handleStripe(200, {error: {message: "Error on processing"}})
        expect(scope.errorText).toEqual("Error on processing")

    describe "ajax is successful", ->
      beforeEach ->
        scope.assembly = {id:321}
        scope.discounted_price = 19.99
        scope.giftInfo = "None"
        scope.httpBackend.expect(
          'POST'
          '/charges?assembly_id=321&discounted_price=19.99&gift_info=None&stripeToken=123'
        ).respond(200, {'success': true})
        scope.handleStripe(200, {id:123, card: {type: "VISA"}})
        scope.httpBackend.flush()

      it "should set processing to be false", ->
        expect(scope.processing).toBe(false)

      describe "if gift", ->
        beforeEach ->
          scope.isGift = true
          scope.enrolled = false

        it "should not set enrolled", ->
          expect(scope.enrolled).toBe(false)

      describe "if not gift", ->
        it "should set enrolled to be true", ->
          expect(scope.enrolled).toBe(true)

      it "should state to be thanks", ->
        expect(scope.state).toEqual("thanks")

      it "should call shareASale", ->
        expect(scope.shareASale).toHaveBeenCalled()

    describe "ajax responds with an error", ->
      beforeEach ->
        scope.assembly = {id:321}
        scope.discounted_price = 19.99
        scope.giftInfo = "None"
        scope.httpBackend.expect(
          'POST'
          '/charges?assembly_id=321&discounted_price=19.99&gift_info=None&stripeToken=123'
        ).respond(500, {'success': false, errors: ["This broke"]})
        scope.handleStripe(200, {id:123, card: {type: "VISA"}})
        scope.httpBackend.flush()

      it "should set the errorText variable", ->
        expect(scope.errorText).toBe("This broke")

      it "should set processing to be false", ->
        expect(scope.processing).toBe(false)

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

  describe "#maybeMoveToCharge", ->
    describe "if valid", ->
      it "should set the scope state to charge", ->
        form = jasmine.createSpyObj('form', ['$valid'])
        scope.maybeMoveToCharge(form)
        expect(scope.state).toBe("charge")

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

      it "should set isGift to the passed in value", ->
        scope.isGift = false
        scope.openModal(true)
        expect(scope.isGift).toBe(true)

      it "should set the state to gift", ->
        scope.state = null
        scope.openModal(true)
        expect(scope.state).toBe("gift")

      it "it should set buyModalOpen to true if signed in", ->
        scope.logged_in = true
        scope.openModal(true)
        expect(scope.buyModalOpen).toBe(true)

  describe "#closeModal", ->
    beforeEach ->
      scope.assembly = {id: 1, title: "Testing Fun", slug:"Testing-Fun"}

    it "should set buyModalOpen to be false", ->
      scope.closeModal()
      expect(scope.buyModalOpen).toBe(false)

  describe "#enroll", ->
    beforeEach ->
      scope.assembly = {id: 321}
      scope.discounted_price = "19.99"
      scope.gift_certificate = 1
      scope.httpBackend.expect(
        'POST'
        '/charges?assembly_id=321&discounted_price=19.99&gift_certificate=1'
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

  describe "#redeemGift", ->
    beforeEach ->
      spyOn(scope, "enroll")
      scope.logged_in = true

    it "should set state to thanks_redeem", ->
      scope.redeemGift()
      expect(scope.state).toEqual("thanks_redeem")

    it "should set buyModalOpen to true", ->
      scope.redeemGift()
      expect(scope.buyModalOpen).toBe(true)

    it "should call enroll", ->
      scope.redeemGift()
      expect(scope.enroll()).toHaveBeenCalled

  describe "#free_enrollment", ->
    beforeEach ->
      scope.assembly = {id: 1, title: "Testing Fun", slug:"Testing-Fun"}
      spyOn(scope, "enroll")
      scope.logged_in = true

    it "should set state to free_enrollment", ->
      scope.free_enrollment()
      expect(scope.state).toEqual("free_enrollment")

    it "should set buyModalOpen to true", ->
      scope.free_enrollment()
      expect(scope.buyModalOpen).toBe(true)

    it "should call enroll", ->
      scope.free_enrollment()
      expect(scope.enroll()).toHaveBeenCalled

  describe "#shareASale", ->
    it "should make the http request", ->
      scope.httpBackend.expect(
        'GET'
        '/affiliates/share_a_sale?amount=19.99&tracking=321'
      ).respond(200)
      scope.shareASale("19.99", "321")
      scope.httpBackend.flush()

  describe "#adminSendGift", ->
    describe "success", ->
      beforeEach ->
        scope.assembly = {id:321}
        scope.discounted_price = 0.0
        scope.giftInfo = "None"
        scope.httpBackend.expect(
          'POST'
          '/charges?assembly_id=321&discounted_price=0&gift_info=None&stripeToken='
        ).respond(200, {'success': true})
        scope.handleStripe(200, {id:123, card: {type: "VISA"}})
        scope.httpBackend.flush()

        it "should set processing to false", ->
          scope.adminSendGift()
          expect(scope.processing).toBe(false)

        it "should set the state to thanks", ->
          scope.adminSendGift()
          expect(scope.state).toBe("thanks")
    describe "error", ->
      beforeEach ->
        scope.assembly = {id:321}
        scope.discounted_price = 19.99
        scope.giftInfo = "None"
        scope.httpBackend.expect(
          'POST'
          '/charges?assembly_id=321&discounted_price=19.99&gift_info=None&stripeToken=123'
        ).respond(500, {'success': false, errors: ["This broke"]})
        scope.handleStripe(200, {id:123, card: {type: "VISA"}})
        scope.httpBackend.flush()

      it "should set the errorText variable", ->
        expect(scope.errorText).toBe("This broke")

      it "should set processing to be false", ->
        expect(scope.processing).toBe(false)

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

