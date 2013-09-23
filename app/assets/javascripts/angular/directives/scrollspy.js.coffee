angular.module('ChefStepsApp').directive 'scrollSpy', ($window) ->
  restrict: 'A'
  controller: ($scope) ->
    $scope.spies = []
    # a spyObj has an id, a function to call when it's section is in view,
    # and a function to call when it's out of sight.
    # This is created in the second directive
    @addSpy = (spyObj) ->
      $scope.spies.push spyObj
      console.log $scope.spies

  link: (scope, elem, attrs) ->
    scope.spyElems = []

    scope.$watch 'spies', (spies) ->
      scope.updateSpies()

    scope.updateSpies = ->
      return
      for spy in scope.spies
        unless scope.spyElems[spy.id]?
          scope.spyElems[spy.id] = elem.find('#'+spy.id)

    $($window).scroll ->
      highlightSpy = null
      for spy in scope.spies
        spy.out()
        scope.spyElems[spy.id] = elem.find('#'+spy.id) unless scope.spyElems[spy.id]?
        if (pos = scope.spyElems[spy.id].offset().top) - $window.scrollY <= (attrs.offset || 0)
          spy.pos = pos
          highlightSpy ?= spy
          if highlightSpy.pos < spy.pos
            highlightSpy = spy

      highlightSpy?.in()

angular.module('ChefStepsApp').directive 'spy', ->
  restrict: "A"
  require: "^scrollSpy"
  link: (scope, elem, attrs, affix) ->
    affix.addSpy
      id: attrs.spy
      in: -> elem.addClass 'active',
      out: -> elem.removeClass 'active'

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