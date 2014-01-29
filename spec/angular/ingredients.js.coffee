describe "IngredientIndexController", ->

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
    browser().navigateTo('/ingredients/manager')
    sleep 2

  afterEach ->
    browser().navigateTo('/sign_out.json')
    browser().navigateTo('/end_clean')

  it "should search from the search box", ->
    expect(browser().window().path()).toBe("/ingredients/manager")

    # Test refresher
    expect(element(".ngRow").count()).toBe(3)
    element("#refresh-button").click()
    sleep 0.25
    expect(element(".ngRow").count()).toBe(3)

    # Test searching
    expect(element("[ng-model='searchString']").count()).toBe(1)
    input("searchString").enter("salt")
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(3)

    # Do exact Match Searches
    element("#exact-match").click()
    input("searchString").enter("Salt, Kosher")
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(1)
    input("searchString").enter("salt")
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(0)
    element("#exact-match").click()
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(3)

    # Search includes recipes
    input("searchString").enter("")
    sleep 0.25
    expect(repeater(".ngRow").count()).toBe(3)
    element("[ng-model='includeRecipes']").click()
    sleep 0.50
    expect(repeater(".ngRow").count()).toBe(7)
    expect(element(".ngRow").html()).toContain("[RECIPE]")
    element("[ng-model='includeRecipes']").click()


  it "should bring up modals", ->
    #  when you click on uses and close when you click close
    el = ".ngRow:first"
    expect(element(el).html()).toContain("2")
    element(el + " a[ng-click='openUses(row.entity)']").click()
    expect(element(".modal").html()).toContain("Salt, Kosher")
    expect(element(".modal ul li").count()).toBe(1)
    element(".modal button.cancel").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

    # when you click on density
    el = ".ngRow:first"
    element(el + " a[ng-click='densityService.editDensity(row.entity)']").click()
    expect(element(".modal").html()).toContain("Salt, Kosher")
    expect(element(".modal cseditpairshow:first a").count()).toBe(1)
    element(".modal cseditpairshow:first a").click()
    expect(element(".modal cseditpairshow:first a").count()).toBe(0)
    expect(element(".modal cseditpairedit:first input").count()).toBe(1)
    input("newDensityValue").enter("1")
    element(".modal-footer button").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)
    expect(element(el + " a[ng-click='densityService.editDensity(row.entity)']").html()).toContain("68")



  it "should let you change the fields", ->
    # Change title
    el = ".ngRow:last"
    element(el + " .colt2").click()
    using(el + " .colt2").input("row.entity.title").enter("Salt, Seasalt Flakes")
    element(el + " .colt4").click()
    sleep 0.50
    expect(element(el + " .colt2").html()).toContain("Salt, Seasalt Flakes")
    element(el + " .colt2").click()
    using(el + " .colt2").input("row.entity.title").enter("Salt, Seasalt")
    element(el + " .colt4").click()

    # Change product URL
    el = ".ngRow:last"
    element(el + " .colt4").click()
    using(el + " .colt4").input("row.entity.product_url").enter("http://www.amazon.com/Maldon-Sea-Salt-Flakes-ounce/dp/B00017028M/ref=sr_1_3?s=grocery&ie=UTF8&qid=1381020739&sr=1-3")
    element(el + " .colt2").click()
    sleep 0.55
    expect(element(el + " .colt4").html()).toContain("amazon.com")

  it "should merge ingredients", ->
    input("allSelected").check()
    element("#merge-button").click()
    expect(element(".modal").count()).toBe(1)
    expect(element(".modal-header").html()).toContain("Merge Ingredients")
    expect(element(".modal-body ul li a.merge-link").count()).toBe(3)
    sleep 1
    element(".modal-body ul li a.merge-link:first").click()
    expect(element(".modal-body").html()).toContain("Will Be Kept")
    expect(element(".modal-body ul.to-keep li:visible").count()).toBe(1)
    expect(element(".modal-body").html()).toContain("Will Be Merged and Deleted")
    expect(element(".modal-body ul.to-delete li:visible").count()).toBe(2)
    sleep 1
    element(".modal-footer .warning").click()
    sleep 1
    expect(element(".modal").count()).toBe(0)

  it "should delete an ingredients", ->
    expect(element(".ngRow").count()).toBe(3)
    element(".ngRow:nth-child(2) .ngSelectionCheckbox").click()
    sleep 0.25
    element("#delete-button").click()
    sleep 0.25
    expect(element(".ngRow").count()).toBe(2)
    browser().reload()
