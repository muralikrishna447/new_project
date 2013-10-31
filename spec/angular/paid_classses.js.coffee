describe "PaidClasses", ->

  beforeEach ->
    browser().navigateTo('/classes/become-a-badass/landing')

  it "should be on the landing page", ->
    expect(browser().window().path()).toBe("/classes/become-a-badass/landing")

  it "should bring up a modal when you click the buy button", ->
    element('.main-cta .btn').click()
    sleep 5
    expect(element('.buy-modal').count()).toBe(1) 
