angular.module('ChefStepsApp').service 'urlService', ->
  # From http://stackoverflow.com/questions/5999118/add-or-update-query-string-parameter
  this.updateQueryStringParameter = (uri, key, value) ->
    re = new RegExp("([?|&])" + key + "=.*?(&|$)", "i")
    separator = (if uri.indexOf("?") != -1 then "&" else "?")
    if uri.match(re)
      uri.replace re, "$1" + key + "=" + value + "$2"
    else
      uri + separator + key + "=" + value

  this.fixAmazonLink = (i) ->
    url = i.product_url
    return unless url
    tag_value = "delvkitc-20"
    tag = "tag=" + tag_value
    if url.match(/^[\w\d]{10}$/)
      i.product_url = "http://www.amazon.com/gp/product/" + url + "/?" + tag
    else if url.indexOf('amazon.com') != -1
      if url.indexOf(tag) == -1
        i.product_url = this.updateQueryStringParameter(url, "tag", tag_value)

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
    na = urlAsNiceText(a)
    nb = urlAsNiceText(b)
    return 0 if na == nb
    return 1 if na > nb
    -1
