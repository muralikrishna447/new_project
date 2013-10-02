describe "IngredientIndexController", ->
  beforeEach ->
    browser().navigateTo('/ingredients')

  it "should go to the ingredients page", ->
    expect(browser().window().path()).toBe("/ingredients")

  it "should have the search box set", ->
    search_box = element("input.search-query").count()
    expect(search_box).toBe(1)