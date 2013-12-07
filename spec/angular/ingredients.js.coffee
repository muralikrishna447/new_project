describe "IngredientIndexController", ->

  beforeEach ->
    browser().navigateTo('/ingredients')

  it "should go to the ingredients page", ->
    expect(browser().window().path()).toBe("/ingredients")

  it "should search from the search box", ->
    expect(element("[ng-model='searchString']").count()).toBe(1)
    input("searchString").enter("salt")
    expect(element(".ngRow").count()).toBe(3)

  it "should perform an exact match", ->
    element("#exact-match").click()
    input("searchString").enter("Salt, Kosher")
    expect(element(".ngRow").count()).toBe(1)
    input("searchString").enter("salt")
    expect(element(".ngRow").count()).toBe(0)
    element("#exact-match").click()
    expect(element(".ngRow").count()).toBe(3)

  it "should bring up a modal when you click on uses and close when you click close", ->
    el = ".ngRow:first"
    expect(element(el).html()).toContain("2")
    element(el + " a[ng-click='openUses(row.entity)']").click()
    expect(element(".modal").html()).toContain("Salt, Kosher")
    expect(element(".modal ul li").count()).toBe(1)
    element(".modal button.cancel").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

  it "should bring up a modal when you click on density", ->
    el = ".ngRow:first"
    element(el + " a[ng-click='editDensity(row.entity)']").click()
    expect(element(".modal").html()).toContain("Salt, Kosher")
    expect(element(".modal cseditpairshow:first a").count()).toBe(1)
    element(".modal cseditpairshow:first a").click()
    expect(element(".modal cseditpairshow:first a").count()).toBe(0)
    expect(element(".modal cseditpairedit:first input").count()).toBe(1)
    input("newDensityValue").enter("1")
    element(".modal-footer button").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)
    expect(element(el + " a[ng-click='editDensity(row.entity)']").html()).toContain("68")

  it "should let you change the title by clicking on it", ->
    el = ".ngRow:last"
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Salt, Seasalt Flakes")
    element(el + " .colt3").click()
    sleep 0.50
    expect(element(el + " .colt1").html()).toContain("Salt, Seasalt Flakes")
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Salt, Seasalt")
    element(el + " .colt3").click()

  it "should should change the product url and display", ->
    el = ".ngRow:last"
    element(el + " .colt3").click()
    using(el + " .colt3").input("row.entity.product_url").enter("http://www.amazon.com/Maldon-Sea-Salt-Flakes-ounce/dp/B00017028M/ref=sr_1_3?s=grocery&ie=UTF8&qid=1381020739&sr=1-3")
    element(el + " .colt1").click()
    sleep 0.55
    expect(element(el + " .colt3").html()).toContain("amazon.com")

  it "should include recipies ", ->
    expect(element(".ngRow").count()).toBe(3)
    element("[ng-model='includeRecipes']").click()
    sleep 0.50
    expect(element(".ngRow").count()).toBe(7)
    expect(element(".ngRow").html()).toContain("[RECIPE]")
    element("[ng-model='includeRecipes']").click()

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

  it "should refresh the page", ->
    expect(element(".ngRow").count()).toBe(3)
    element("#refresh-button").click()
    sleep 0.25
    expect(element(".ngRow").count()).toBe(3)
