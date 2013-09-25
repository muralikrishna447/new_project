angular.module('ChefStepsApp').directive 'scrollSpy', ["$window", "$timeout", ($window, $timeout) ->
  restrict: 'A'
  controller: ($scope) ->
    $scope.spies = []
    # a spyObj has an id, a function to call when it's section is in view,
    # and a function to call when it's out of sight.
    # This is created in the second directive
    @addSpy = (spyObj) ->
      $scope.spies.push spyObj

    $scope.$on 'loadActivityEvent',  ->
      $scope.spyElems = []
 
  link: (scope, elem, attrs) ->
    scope.spyElems = []

    scope.updateSpies = ->
      highlightSpy = scope.spies[0]
      for spy in scope.spies
        scope.spyElems[spy.id] = elem.find('#'+spy.id) unless (scope.spyElems[spy.id]?.length > 0)
        spy.out()
      for spy in scope.spies
        if (scope.spyElems[spy.id]?.length > 0) && (scope.spyElems[spy.id].closest('html'))
          if (pos = scope.spyElems[spy.id].offset().top) - $window.scrollY <= (attrs.offset || 0)
            spy.pos = pos
            if highlightSpy.pos < spy.pos
              highlightSpy = spy

      highlightSpy?.in()

    scope.$watch 'spies', ->
      $timeout (-> 
       scope.updateSpies()
      ), 1000

    $($window).scroll ->
      scope.updateSpies()
]


angular.module('ChefStepsApp').directive 'spy', ->
  restrict: "A"
  require: "^scrollSpy"
  link: (scope, elem, attrs, affix) ->
    affix.addSpy
      id: attrs.spy

      in: -> 
        elem.addClass('active')
        elem.parent().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().next().find('a').addClass('active-more')
        elem.parent().prev().find('a').addClass('active-more')

      out: -> 
        elem.removeClass 'active'
        elem.removeClass 'active-neighbor'
        elem.removeClass 'active-more'

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