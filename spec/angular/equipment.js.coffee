describe "EquipmentController", ->
  beforeEach ->
    browser().navigateTo('/equipment')

  it "should go to the equipment page", ->
    expect(browser().window().path()).toBe("/equipment")

  it "should search from the search box", ->
    expect(element("[ng-model='searchString']").count()).toBe(1)
    input("searchString").enter("knife")
    expect(element(".ngRow").count()).toBe(3)

  it "should bring up a modal when you click on uses and close when you click close", ->
    el = ".ngRow:first"
    expect(element(el).html()).toContain("2")
    element(el + " a[ng-click='openUses(row.entity)']").click()
    expect(element(".modal").html()).toContain("Chef Knife, Shun Edo 6-1/2 Blade")
    expect(element(".modal ul li").count()).toBe(2)
    element(".modal button.cancel").click()
    sleep 0.25
    expect(element(".modal").count()).toBe(0)

  it "should let you change the title by clicking on it", ->
    el = ".ngRow:last"
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Shun Edo Santoku 7-1/2 Blade")
    element(el + " .colt3").click()
    sleep 0.50
    expect(element(el + " .colt1").html()).toContain("Shun Edo Santoku 7-1/2 Blade")
    element(el + " .colt1").click()
    using(el + " .colt1").input("row.entity.title").enter("Shun Edo Santoku Knife")
    element(el + " .colt3").click()

  it "should should change the product url and display", ->
    el = ".ngRow:first"
    element(el + " .colt3").click()
    using(el + " .colt3").input("row.entity.product_url").enter("http://www.amazon.com/Shun-BB1502-2-Inch-Chefs-Knife/dp/B00BIGCJCC/ref=sr_1_5?ie=UTF8&qid=1381284103&sr=8-5")
    element(el + " .colt1").click()
    sleep 0.55
    expect(element(el + " .colt3").html()).toContain("amazon.com")

  it "should merge equipment", ->
    input("allSelected").check()
    element("#merge-button").click()
    expect(element(".modal").count()).toBe(1)
    expect(element(".modal-header").html()).toContain("Merge Equipment")
    expect(element(".modal-body ul li a.merge-link").count()).toBe(3)
    sleep 0.50
    element(".modal-body ul li a.merge-link:first").click()
    expect(element(".modal-body").html()).toContain("Will Be Kept")
    expect(element(".modal-body ul.to-keep li:visible").count()).toBe(1)
    expect(element(".modal-body").html()).toContain("Will Be Merged and Deleted")
    expect(element(".modal-body ul.to-delete li:visible").count()).toBe(2)
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

  it "should refresh the page", ->
    expect(element(".ngRow").count()).toBe(3)
    element("#refresh-button").click()
    sleep 0.25
    expect(element(".ngRow").count()).toBe(3)