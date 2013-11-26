describe "PaidClasses", ->

  beforeEach ->
    browser().navigateTo('/classes/become-a-badass/landing')

  it "should be on the landing page", ->
    expect(browser().window().path()).toBe("/classes/become-a-badass/landing")

  it "should bring up a modal when you click the buy button", ->
    element('#buy-button').click()
    sleep .5
    expect(element('.buy-modal-body').count()).toBe(1) 
    input("number").enter("4242424242424242")
    input("name").enter("Nigel Klotkin")
    input("expMonth").enter("7")
    input("expYear").enter("15")
    input("cvc").enter("330")
    element('#complete-buy').click()
    sleep 5