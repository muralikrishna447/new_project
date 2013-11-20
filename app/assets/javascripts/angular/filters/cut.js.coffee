# http://stackoverflow.com/questions/18095727/how-can-i-limit-the-length-of-a-string-that-displays-with-when-using-angularj

angular.module('ChefStepsApp').filter "cut", ->
  (value, wordwise, max, tail) ->
    return ""  unless value
    max = parseInt(max, 10)
    return value  unless max
    return value  if value.length <= max
    value = value.substr(0, max)
    if wordwise
      lastspace = value.lastIndexOf(" ")
      value = value.substr(0, lastspace)  unless lastspace is -1
    value + (tail or " …")
