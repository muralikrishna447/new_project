describe "EquipmentController", ->

  beforeEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')
    browser().navigateTo('/start_clean')
    browser().navigateTo('/')
    element('#nav-sign-in-button').click()
    sleep 0.5
    expect(element('.login-modal-body').count()).toBe(1)
    input("login_user.email").enter("admin@chefsteps.com")
    input("login_user.password").enter("apassword")
    element("button.signin").click()
    sleep 2
    browser().navigateTo('/equipment')
    sleep 3

  afterEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')


  it "should search from the search box", ->
    expect(browser().window().path()).toBe("/equipment")

    # Test refresher
    expect(repeater(".ngRow").count()).toBe(3)
    element("#refresh-button").click()
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(3)

    # Test Searching
    expect(element("[ng-model='searchString']").count()).toBe(1)
    input("searchString").enter("knife")
    expect(repeater(".ngRow").count()).toBe(3)

    # Test Exact Match Search
    element("#exact-match").click()
    input("searchString").enter("Chef Knife, Shun Edo 6-1/2 Blade")
    expect(repeater(".ngRow").count()).toBe(1)
    input("searchString").enter("Knife")
    expect(repeater(".ngRow").count()).toBe(0)
    element("#exact-match").click()
    expect(repeater(".ngRow").count()).toBe(3)

  it "should bring up modals", ->
    # when you click on uses and close when you click close
    el = ".ngRow:first"
    expect(element(el).html()).toContain("2")
    element(el + " a[ng-click='openUses(row.entity)']").click()
    expect(element(".modal").html()).toContain("Chef Knife, Shun Edo 6-1/2 Blade")
    expect(element(".modal ul li").count()).toBe(2)
    element(".modal button.cancel").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

  it "should let you change the fields", ->
    # Change Title
    el = ".ngRow:last"
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Shun Edo Santoku 7-1/2 Blade")
    element(el + " .colt3").click()
    sleep 0.50
    expect(element(el + " .colt1").html()).toContain("Shun Edo Santoku 7-1/2 Blade")
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Shun Edo Santoku Knife")
    element(el + " .colt3").click()

    # Change product URL
    el = ".ngRow:first"
    element(el + " .colt3").click()
    using(el + " .colt3").input("row.entity.product_url").enter("http://www.amazon.com/Shun-BB1502-2-Inch-Chefs-Knife/dp/B00BIGCJCC/ref=sr_1_5?ie=UTF8&qid=1381284103&sr=8-5")
    element(el + " .colt1").click()
    sleep 0.55
    expect(element(el + " .colt3").html()).toContain("amazon.com")


  it "should merge equipment", ->
    element(".ngRow:nth-child(1) .ngSelectionCheckbox").click()
    element(".ngRow:nth-child(2) .ngSelectionCheckbox").click()
    element("#merge-button").click()
    expect(element(".modal").count()).toBe(1)
    expect(element(".modal-header").html()).toContain("Merge Equipment")
    expect(element(".modal-body ul li a.merge-link").count()).toBe(2)
    sleep 0.50
    element(".modal-body ul li a.merge-link:first").click()
    expect(element(".modal-body").html()).toContain("Will Be Kept")
    expect(element(".modal-body ul.to-keep li:visible").count()).toBe(1)
    expect(element(".modal-body").html()).toContain("Will Be Merged and Deleted")
    expect(element(".modal-body ul.to-delete li:visible").count()).toBe(1)
    sleep 0.50
    element(".modal-footer .warning").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

  it "should delete an equipment", ->
    expect(element(".ngRow").count()).toBe(3)
    element(".ngRow:nth-child(2) .ngSelectionCheckbox").click()
    sleep 0.25
    element("#delete-button").click()
    sleep 0.25
    expect(element(".ngRow").count()).toBe(2)
    browser().reload()

