describe "csUrlService", ->
  urlService = null

  amazonCode =
    product_url: "B002VECM6S"

  amazonURL =
    product_url: "http://www.amazon.com/gp/product/B00DHW4HXY/"

  bogusAmazonURL =
    product_url: "http://www.amazon.com/gp/product/B002VECM6S/?tag=xxxdesdfsadfc-20"

  mikuniURL =
    product_url: "http://mikuni.myshopify.com/products/applewood-smoked-ikura-caviar"

  preCodedMikuniURL =
    product_url: "http://mikuni.myshopify.com/products/applewood-smoked-ikura-caviar#oid=1003_1"

  beforeEach ->
    module('ChefStepsApp')
    inject (csUrlService) ->
      urlService = csUrlService

  describe "updateQueryStringParameter", ->
    it "should append a paremeter onto an existing param list", ->
      expect(urlService.updateQueryStringParameter("http://amazon.com?product=salt", "tag", "chefsteps02-20")).toBe("http://amazon.com?product=salt&tag=chefsteps02-20")

    it "should insert parameters into param list if there is none", ->
      expect(urlService.updateQueryStringParameter("http://amazon.com", "tag", "chefsteps02-20")).toBe("http://amazon.com?tag=chefsteps02-20")

    it "should update a parameter in the param list if there is one", ->
      expect(urlService.updateQueryStringParameter("http://amazon.com?tag=totally-fake", "tag", "chefsteps02-20")).toBe("http://amazon.com?tag=chefsteps02-20")

  describe "fixAffiliateLink", ->
    it "should normalize an amazon product id to an amazon link", ->
      expect(urlService.fixAffiliateLink(amazonCode)).toBe("http://www.amazon.com/gp/product/B002VECM6S/?tag=chefsteps02-20")

    it "should normalize an amazon product url and add affiliate code", ->
      expect(urlService.fixAffiliateLink(amazonURL)).toBe("http://www.amazon.com/gp/product/B00DHW4HXY/?tag=chefsteps02-20")

    it "should normalize a bogus amazon affilate code to be the correct one", ->
      expect(urlService.fixAffiliateLink(bogusAmazonURL)).toBe("http://www.amazon.com/gp/product/B002VECM6S/?tag=chefsteps02-20")

    it "should add an affiliate code to a Mikuni Wild Havest link", ->
      expect(urlService.fixAffiliateLink(mikuniURL)).toBe('http://mikuni.myshopify.com/products/applewood-smoked-ikura-caviar#oid=1003_1')

    it "should not damage a pre-coded Mikuni Wild Harvest Link", ->
      expect(urlService.fixAffiliateLink(preCodedMikuniURL)).toBe('http://mikuni.myshopify.com/products/applewood-smoked-ikura-caviar#oid=1003_1')



  describe "urlAsNiceText", ->
    it "should return amazon.com if url is amzn.com", ->
      expect(urlService.urlAsNiceText("http://amzn.com/B00DHW4HXY")).toBe("amazon.com")

    it "should return 'Link' if url is not valid", ->
      expect(urlService.urlAsNiceText("www.randomsite.com/B00DHW4HXY")).toBe("Link")

    it "should return domain if url is valid", ->
      expect(urlService.urlAsNiceText("http://google.com/this-should-be-ignored/B00DHW4HXY")).toBe("google.com")

    it "should return nonbreaking space if url is null", ->
      expect(urlService.urlAsNiceText(null)).toBe("&nbsp;")

  describe "sortByNiceURL", ->
    it "should return 0 if the urls are the same", ->
      expect(urlService.sortByNiceURL("http://google.com/", "http://google.com/")).toBe(0)

    it "should return 1 if the first url is greater than the second", ->
      expect(urlService.sortByNiceURL("http://google.com/", "http://amazon.com/")).toBe(1)

    it "should return -1 if the first url is less than the second", ->
      expect(urlService.sortByNiceURL("http://amazon.com/", "http://google.com/")).toBe(-1)

  describe "currentSiteAsHttps", ->
    it "should return the current site starting with https", ->
      expect(urlService.currentSiteAsHttps()).toContain("http://localhost")

  describe "currentSiteAsHttps", ->
    it "should return the current site starting with https", ->
      expect(urlService.currentSite()).toContain("http://localhost")