# NOTE WELL THIS ISN'T A FULLY GENERIC SCROLLSPY READY FOR REUSE
# It has been hacked upa bit to work in our specific use case for step dots - could easily be made
# generic though.

angular.module('ChefStepsApp').directive 'scrollSpy', ["$window", "$timeout", ($window, $timeout) ->
  restrict: 'A'
  controller: ['$scope', ($scope) ->
    $scope.spyOnElement = {}
    @getSpyOnElement = ->
      $scope.spyOnElement
    $scope.spies = []
    # a spyObj has an id, a function to call when it's section is in view,
    # and a function to call when it's out of sight.
    # This is created in the second directive
    @addSpy = (spyObj) ->
      $scope.spies.push spyObj

    @removeSpy = (spyScopeID) ->
      spyObj = _.find($scope.spies, (spyObj) -> spyObj.spyScopeID == spyScopeID)

      $scope.spies = _.filter($scope.spies, (spy) -> spy["spyScopeID"] != spyScopeID)

    $scope.$on 'loadActivityEvent',  ->
      # Clear cache
      $scope.spyElems = []
  ]

  link: (scope, elem, attrs) ->
    scope.spyElems = []

    if attrs.spyonelement
      scope.spyOnElement = angular.element(elem)[0]
    else
      scope.spyOnElement = window

    scope.$watch 'spies.length', (newValue, oldValue) ->
      if newValue != oldValue
        for spy in scope.spies
          unless scope.spyElems[spy.id]?
            scope.spyElems[spy.id] = elem.find('#'+spy.id)
            boundingRect = scope.spyElems[spy.id][0].getBoundingClientRect()

    scope.updateSpies = ->
      spy.out() for spy in scope.spies
      highlightSpy = scope.spies[0]
      offset = parseInt(attrs.offset || "0")
      
      for spy in scope.spies
        # Ignore any spies whose target isn't currently in the DOM - but it might come back
        if (scope.spyElems[spy.id]?.length > 0) && (scope.spyElems[spy.id].closest('html'))
          boundingRect = scope.spyElems[spy.id][0].getBoundingClientRect()
          spy.pos = boundingRect.bottom - scope.spyElems[spy.id][0].clientHeight
          if spy.pos <= offset
            if highlightSpy.pos < spy.pos
              highlightSpy = spy

      highlightSpy?.in()

    $(scope.spyOnElement).scroll ->
      scope.updateSpies()
]


angular.module('ChefStepsApp').directive 'spy', ['$window', ($window)->
  restrict: "A"
  require: "^scrollSpy"
  link: (scope, elem, attrs, affix) ->
    el = angular.element(elem)
    scope.$on "$destroy", ->
      affix.removeSpy(scope.$id)

    scope.spyScopeID =  scope.$id
    scope.id = attrs.spy

    scope.in = -> 
        elem.addClass('active')
        elem.parent().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().next().find('a').addClass('active-more')
        elem.parent().prev().find('a').addClass('active-more')
        elem.removeClass('basic')

    scope.out = -> 
        elem.removeClass 'active'
        elem.removeClass 'active-neighbor'
        elem.removeClass 'active-more'
        elem.addClass 'basic'

    affix.addSpy(scope)

    el.on 'click', (e) ->
      scrollElement = affix.getSpyOnElement()
      if scrollElement == window
        scrollPos = $(window).scrollTop() + scope.pos
        $(window).scrollTop(scrollPos)
      else
        angular.element(scrollElement)[0].scrollTop += scope.pos
      e.preventDefault()

]

angular.module('ChefStepsApp').directive "preventDefault", ->
  (scope, element, attrs) ->
    jQuery(element).click (event) ->
      event.preventDefault()


# angular.module('ChefStepsApp').directive "scrollTo", ["$window", ($window) ->
#   restrict: "AC"
#   compile: ->
#     scrollInto = (elementId) ->
#       $window.scrollTo 0, 0  unless elementId
      
#       #check if an element can be found with id attribute
#       el = document.getElementById(elementId)
#       #el.scrollIntoView() if el
#       $("html, body").animate
#         scrollTop: $(el).offset().top - 238
#       , 500
#     (scope, element, attr) ->
#       element.bind "click", (event) ->
#         scrollInto attr.scrollTo

# ]