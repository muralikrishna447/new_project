describe "PaidClasses", ->

  beforeEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')
    browser().navigateTo('/start_clean')
    browser().navigateTo('/classes/become-a-badass/landing')

  afterEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')

  it "should be on the landing page", ->
    expect(browser().window().path()).toBe("/classes/become-a-badass/landing")

  describe "not signed in", ->
    describe "login", ->
      describe "purchase for myself", ->
        it "should redirect me away if I am already enrolled", ->
          element('#sign-in-and-buy-button').click()
          sleep 1
          expect(element('.login-modal-body').count()).toBe(1)
          input("login_user.email").enter("qwerty@example.com")
          input("login_user.password").enter("apassword")
          element("button.signin").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body").count()).toBe(0)

        it "should purchase the class for me if I am not enrolled", ->
          element('#sign-in-and-buy-button').click()
          sleep .5
          expect(element('.login-modal-body').count()).toBe(1)
          input("login_user.email").enter("ytrewq@example.com")
          input("login_user.password").enter("apassword")
          element("button.signin").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body").count()).toBe(1)
          input("number").enter("4242424242424242")
          input("name").enter("Nigel Klotkin")
          input("expMonth").enter("7")
          input("expYear").enter("22")
          input("cvc").enter("330")
          element('#complete-buy').click()
          sleep 3
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for your purchase")

      describe "gift purchase", ->
        it "should allow me to purchase as a gift", ->
          element('#sign-in-and-gift-button').click()
          sleep .5
          expect(element('.login-modal-body').count()).toBe(1)
          input("login_user.email").enter("ytrewq@example.com")
          input("login_user.password").enter("apassword")
          element("button.signin").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body").count()).toBe(1)
          input("giftInfo.recipientName").enter("Gift Person")
          input("giftInfo.recipientEmail").enter("gift@example.com")
          input("giftInfo.recipientMessage").enter("This is only a test")
          element("#next-button").click()
          input("number").enter("4242424242424242")
          input("name").enter("Nigel Klotkin")
          input("expMonth").enter("7")
          input("expYear").enter("22")
          input("cvc").enter("330")
          input("giftInfo.emailToRecipient").select(false)
          element('#complete-buy').click()
          sleep 3
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for giving our")

      describe "gift redeem", ->
        it "should allow me to redeem", ->
          browser().navigateTo('/classes/become-a-badass/landing?gift_token=test')
          element("#sign-in-and-redeem-gift-button").click()
          sleep .5
          element(".switch-to-signin").click()
          expect(element('.login-modal-body').count()).toBe(1)
          input("login_user.email").enter("ytrewq@example.com")
          input("login_user.password").enter("apassword")
          element("button.signin").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

      describe "free course", ->
        it "should allow me to sign up for free", ->
          browser().navigateTo('/classes/become-a-badass-for-free/landing')
          element('#sign-in-and-enroll-free-button').click()
          sleep .5
          expect(element('.login-modal-body').count()).toBe(1)
          input("login_user.email").enter("ytrewq@example.com")
          input("login_user.password").enter("apassword")
          element("button.signin").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

    describe "sign up", ->
      describe "purchase for myself", ->
        it "should purchase the class for me", ->
          element('#sign-in-and-buy-button').click()
          sleep .5
          expect(element('.login-modal-body').count()).toBe(1)
          element("a.switch-to-signup").click()
          input("register_user.email").enter("test#{Math.random(10000)}@example.com")
          input("register_user.name").enter("Test Signup")
          input("register_user.password").enter("apassword")
          element("button.signup").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body").count()).toBe(1)
          input("number").enter("4242424242424242")
          input("name").enter("Nigel Klotkin")
          input("expMonth").enter("7")
          input("expYear").enter("22")
          input("cvc").enter("330")
          element('#complete-buy').click()
          sleep 3
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for your purchase")

      describe "gift purchase", ->
        it "should allow me to purchase as a gift", ->
          element('#sign-in-and-gift-button').click()
          sleep .5
          expect(element('.login-modal-body').count()).toBe(1)
          element("a.switch-to-signup").click()
          input("register_user.email").enter("test#{Math.random(10000)}@example.com")
          input("register_user.name").enter("Test Signup")
          input("register_user.password").enter("apassword")
          element("button.signup").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body").count()).toBe(1)
          input("giftInfo.recipientName").enter("Gift Person")
          input("giftInfo.recipientEmail").enter("gift@example.com")
          input("giftInfo.recipientMessage").enter("This is only a test")
          element("#next-button").click()
          input("number").enter("4242424242424242")
          input("name").enter("Nigel Klotkin")
          input("expMonth").enter("7")
          input("expYear").enter("22")
          input("cvc").enter("330")
          input("giftInfo.emailToRecipient").select(false)
          element('#complete-buy').click()
          sleep 3
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for giving our")

      describe "gift redeem", ->
        it "should allow me to redeem", ->
          browser().navigateTo('/classes/become-a-badass/landing?gift_token=test')
          element("#sign-in-and-redeem-gift-button").click()
          sleep .5
          element(".switch-to-signin").click()
          expect(element('.login-modal-body').count()).toBe(1)
          element("a.switch-to-signup").click()
          input("register_user.email").enter("test#{Math.random(10000)}@example.com")
          input("register_user.name").enter("Test Signup")
          input("register_user.password").enter("apassword")
          element("button.signup").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

      describe "free course", ->
        it "should allow me to sign up for free", ->
          browser().navigateTo('/classes/become-a-badass-for-free/landing')
          element('#sign-in-and-enroll-free-button').click()
          expect(element('.login-modal-body').count()).toBe(1)
          element("a.switch-to-signup").click()
          input("register_user.email").enter("test#{Math.random(10000)}@example.com")
          input("register_user.name").enter("Test Signup")
          input("register_user.password").enter("apassword")
          element("button.signup").click()
          sleep 2
          expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

  describe "signed in", ->
    beforeEach ->
      element('#sign-in-and-buy-button').click()
      sleep .5
      expect(element('.login-modal-body').count()).toBe(1)
      input("login_user.email").enter("ytrewq@example.com")
      input("login_user.password").enter("apassword")
      element("button.signin").click()
      sleep 2
      browser().navigateTo('/classes/become-a-badass/landing')

    describe "purchase for myself", ->
      it "should allow me to purchase for myself", ->
        element("#buy-button").click()
        sleep 2
        expect(element('.assembly-welcome-modal-body').count()).toBe(1)
        input("number").enter("4242424242424242")
        input("name").enter("Nigel Klotkin")
        input("expMonth").enter("7")
        input("expYear").enter("15")
        input("cvc").enter("330")
        element('#complete-buy').click()
        sleep 3
        expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for your purchase")

    describe "gift purchase", ->
      it "should allow me to purchase as a gift", ->
        element("#gift-button").click()
        expect(element(".assembly-welcome-modal-body").count()).toBe(1)
        input("giftInfo.recipientName").enter("Gift Person")
        input("giftInfo.recipientEmail").enter("gift@example.com")
        input("giftInfo.recipientMessage").enter("This is only a test")
        element("#next-button").click()
        input("number").enter("4242424242424242")
        input("name").enter("Nigel Klotkin")
        input("expMonth").enter("7")
        input("expYear").enter("22")
        input("cvc").enter("330")
        input("giftInfo.emailToRecipient").select(false)
        element('#complete-buy').click()
        sleep 3
        expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for giving our")

    describe "gift redeem", ->
      it "should allow me to redeem", ->
        browser().navigateTo('/classes/become-a-badass/landing?gift_token=test')
        element("#redeem-gift-button").click()
        sleep 2
        expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

    describe "free course", ->
      it "should allow me to sign up for free", ->
        browser().navigateTo('/classes/become-a-badass-for-free/landing')
        element("#enroll-free-button").click()
        sleep 2
        expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Welcome to the ChefSteps'")

  describe "admin account", ->
    beforeEach ->
      element('#sign-in-and-buy-button').click()
      sleep .5
      expect(element('.login-modal-body').count()).toBe(1)
      input("login_user.email").enter("admin@chefsteps.com")
      input("login_user.password").enter("apassword")
      element("button.signin").click()
      sleep 2
      browser().navigateTo('/classes/become-a-badass/landing')

    it "should send a free course", ->
      element("#gift-button").click()
      expect(element(".assembly-welcome-modal-body").count()).toBe(1)
      input("giftInfo.recipientName").enter("Gift Person")
      input("giftInfo.recipientEmail").enter("gift@example.com")
      input("giftInfo.recipientMessage").enter("This is only a test")
      sleep 2
      element("#admin-next-button").click()
      sleep 2
      expect(element(".assembly-welcome-modal-body .ng-binding").text()).toMatch("Thank you for giving our")

