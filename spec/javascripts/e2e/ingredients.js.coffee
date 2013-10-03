describe "IngredientIndexController", ->
  beforeEach ->
    browser().navigateTo('/ingredients')

  it "should go to the ingredients page", ->
    expect(browser().window().path()).toBe("/ingredients")

  it "should search from the search box", ->
    expect(element("[ng-model='searchString']").count()).toBe(1)
    input("searchString").enter("salt, seasalt")
    expect(element(".ngRow").count()).toBe(2)

  it "should bring up a modal when you click on uses and close when you click close", ->
    input("searchString").enter("Achiote paste")
    el = ".ngRow:first"
    expect(element(el).html()).toContain("4")
    element(el + " a[ng-click='openUses(row.entity)']").click()
    expect(element(".modal").html()).toContain("Achiote paste")
    expect(element(".modal ul li").count()).toBe(4)
    element(".modal button.cancel").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

  iit "should bring up a modal when you click on density", ->
    input("searchString").enter("Achiote paste")
    el = ".ngRow:first"
    element(el + " a[ng-click='editDensity(row.entity)']").click()
    expect(element(".modal").html()).toContain("Achiote paste")
    expect(element(".modal cseditpairshow:first a").count()).toBe(1)
    element(".modal cseditpairshow:first a").click()
    expect(element(".modal cseditpairshow:first a").count()).toBe(0)
    expect(element(".modal cseditpairedit:first input").count()).toBe(1)

