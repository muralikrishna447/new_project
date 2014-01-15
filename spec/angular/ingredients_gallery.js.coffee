describe "IngredientGalleryController", ->

  beforeEach ->
    browser().navigateTo('/end_clean')
    browser().navigateTo('/start_clean')
    browser().navigateTo('/')
    pause
    browser().navigateTo('/ingredients')
    sleep 2

  afterEach ->
    browser().navigateTo('/end_clean')

  it "should display no ingredients b/c of lack of images", ->
    expect(browser().window().path()).toBe("/ingredients")
    expect(element("csGalleryItem").count()).toBe(0)

  it "should display ingredients once image requirement is removed", ->
    element("csradiobuttons[active='filters.image'] button:first-child").click()
    sleep 1
    expect(element("csGalleryItem").count()).toBe(3)

  it "should search from the searchbox", ->
    element("csradiobuttons[active='filters.image'] button:first-child").click()
    input("filters.search_all").enter("kosher")
    sleep 1
    expect(element("csGalleryItem").count()).toBe(1)
