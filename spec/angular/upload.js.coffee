describe "ActivityUploadController", ->


  describe "not signed in", ->
    describe "log in", ->
      it "should allow me to log in", ->
        browser().navigateTo('/sign_out.json')
        browser().navigateTo('/end_clean')
        browser().navigateTo('/start_clean')
        browser().navigateTo('/')

        browser().navigateTo('/uploads/1')
        sleep 1
        element('#like-button').click()
        sleep 1
        expect(repeater('.cs-alert').count()).toBe(1)
        sleep 1
        element('.close-x').click()
        expect(repeater('.cs-alert').count()).toBe(0)
        sleep 1

        element('#nav-sign-in-button').click()
        sleep 0.5 
        expect(element('.login-modal-body').count()).toBe(1)
        input("login_user.email").enter("admin@chefsteps.com")
        input("login_user.password").enter("apassword")
        element("button.signin").click()
        sleep 3
        browser().navigateTo('/uploads/1')
        sleep 3

        expect(repeater(".icon-heart-empty").count()).toBe(1)
        expect(repeater(".icon-heart").count()).toBe(0)

        element('#like-button').click()
        sleep 3
        expect(repeater(".icon-heart-empty").count()).toBe(0)
        expect(repeater(".icon-heart").count()).toBe(1)
        sleep 3

        element('#like-button').click()
        sleep 3
        expect(repeater(".icon-heart-empty").count()).toBe(1)
        expect(repeater(".icon-heart").count()).toBe(0)
        sleep 3