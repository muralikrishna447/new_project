angular.module('ChefStepsApp').service 'csUrlService', ["$window", ($window) ->
  # From http://stackoverflow.com/questions/5999118/add-or-update-query-string-parameter
  this.updateQueryStringParameter = (uri, key, value) ->
    re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i")
    separator = (if uri.indexOf("?") != -1 then "&" else "?")
    if uri.match(re)
      uri.replace re, "$1" + key + "=" + value + "$2"
    else
      uri + separator + key + "=" + value

  this.fixAffiliateLink = (i) ->
    url = i.product_url
    return unless url

    amzn_tag_value = "chefsteps02-20"
    amzn_tag = "tag=" + amzn_tag_value
    mikuni_tag = '#oid=1003_1'

    if url.match(/^[\w\d]{10}$/)
      i.product_url = "http://www.amazon.com/gp/product/" + url + "/?" + amzn_tag

    else if url.indexOf('amazon.com') != -1
      if url.indexOf(amzn_tag) == -1
        i.product_url = this.updateQueryStringParameter(url, "tag", amzn_tag_value)

    else if url.indexOf('mikuni.myshopify.com') != -1
      if url.indexOf(mikuni_tag) == -1
        i.product_url = url + mikuni_tag

    i.product_url

  this.urlAsNiceText = (url) ->
    if url
      result = "Link"
      return "amazon.com" if url.indexOf("amzn") != -1
      matches = url.match(/^https?\:\/\/([^\/?#]+)(?:[\/?#]|$)/i);
      if matches && matches[1]
        result = matches[1].replace('www.', '')
      result
    else
      "&nbsp;"

  this.sortByNiceURL = (a, b) ->
    na = this.urlAsNiceText(a)
    nb = this.urlAsNiceText(b)
    return 0 if na == nb
    return 1 if na > nb
    -1

  this.currentSiteAsHttps =  ->
    if /localhost/.test($window.location.host) || /\.dev/.test($window.location.host) || /example/.test($window.location.host)
      "http://#{$window.location.host}"
    else
      "https://#{$window.location.host}"

  this.currentSite = ->
    "#{$window.location.protocol}//#{$window.location.host}"

  this
]