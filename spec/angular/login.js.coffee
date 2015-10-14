describe "Login", ->

  beforeEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')
    browser().navigateTo('/start_clean')
    browser().navigateTo('/')

  afterEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')

  it "should be on the landing page", ->
    expect(browser().window().path()).toBe("/")

  describe "sign in", ->
    it "should sign me in with my email without showing me the first time user experience", ->
      element('#nav-sign-in-button').click()
      sleep 0.5
      expect(element('.login-modal-body').count()).toBe(1)
      input("login_user.email").enter("qwerty@example.com")
      input("login_user.password").enter("apassword")
      element("button.signin").click()
      sleep 2
      expect(element(".assembly-welcome-modal-body").count()).toBe(0)
      expect(element(".profile-link").count()).toBe(1)

  describe "sign up", ->
    it "should create an account and show me the first time user experience", ->
      element('#nav-sign-in-button').click()
      sleep 0.5
      expect(element('.login-modal-body').count()).toBe(1)
      element("a.switch-to-signup").click()
      input("register_user.email").enter("test#{Math.random(10000)}@example.com")
      input("register_user.name").enter("Test Signup")
      input("register_user.password").enter("apassword")
      element("button.signup").click()
      sleep 2
      expect(element('.login-modal-body').count()).toBe(0)
      expect(element('.invite-modal-body').count()).toBe(1)
      expect(element('.invite-modal-body').html()).toContain("Thanks for signing up")
      element(".next-button").click()
      sleep 2
      expect(element('.invite-modal-body').count()).toBe(0)
      expect(element('.welcome-modal-body').count()).toBe(1)
      expect(element('.welcome-modal-body').html()).toContain("Welcome to ChefSteps")
      element(".close-welcome").click()
      sleep 1
      expect(element('.login-modal-body').count()).toBe(0)
      expect(element('.invite-modal-body').count()).toBe(0)
      expect(element('.welcome-modal-body').count()).toBe(0)
