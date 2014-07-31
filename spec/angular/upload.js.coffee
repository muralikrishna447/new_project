describe "ActivityUploadController", ->
  beforeEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')
    browser().navigateTo('/start_clean')
    browser().navigateTo('/uploads/1')
    sleep 1

  describe "liking when not signed", ->
      it "should display the sign in alert", ->
        sleep 1
        element('#like-button').click()
        sleep 1
        expect(repeater('.cs-alert').count()).toBe(1)
        sleep 1
        element('.close-x').click()
        expect(repeater('.cs-alert').count()).toBe(0)
        sleep 1

  describe "liking when signed in", ->
      it "should respond to being liked", ->
        element('#nav-sign-in-button').click()
        sleep 1
        expect(element('.login-modal-body').count()).toBe(1)
        input("login_user.email").enter("admin@chefsteps.com")
        input("login_user.password").enter("apassword")
        element("button.signin").click()
        sleep 1
        browser().navigateTo('/uploads/1')
        sleep 1

        expect(repeater(".icon-heart-empty").count()).toBe(1)
        expect(repeater(".icon-heart").count()).toBe(0)

        element('#like-button').click()
        sleep 1
        expect(repeater(".icon-heart-empty").count()).toBe(0)
        expect(repeater(".icon-heart").count()).toBe(1)
        sleep 1

        element('#like-button').click()
        sleep 1
        expect(repeater(".icon-heart-empty").count()).toBe(1)
        expect(repeater(".icon-heart").count()).toBe(0)
        sleep 1
