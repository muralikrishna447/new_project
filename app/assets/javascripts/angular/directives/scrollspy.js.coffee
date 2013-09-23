angular.module('ChefStepsApp').directive "scrollSpy", ($timeout) ->
  restrict: "A"
  link: (scope, elem, attr) ->
    offset = parseInt(attr.scrollOffset, 10)
    offset = 10  unless offset
    console.log "offset:  " + offset
    elem.scrollspy offset: offset
    scope.$watch attr.scrollSpy, ((value) ->
      $timeout (->
        elem.scrollspy "refresh",
          offset: offset

      ), 1
    ), true

angular.module('ChefStepsApp').directive "preventDefault", ->
  (scope, element, attrs) ->
    jQuery(element).click (event) ->
      event.preventDefault()


angular.module('ChefStepsApp').directive "scrollTo", ["$window", ($window) ->
  restrict: "AC"
  compile: ->
    scrollInto = (elementId) ->
      $window.scrollTo 0, 0  unless elementId
      
      #check if an element can be found with id attribute
      el = document.getElementById(elementId)
      #el.scrollIntoView() if el
      $("html, body").animate
        scrollTop: $(el).offset().top - 80
      , 500
    (scope, element, attr) ->
      element.bind "click", (event) ->
        scrollInto attr.scrollTo

]