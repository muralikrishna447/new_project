# NOTE WELL THIS ISN'T A FULLY GENERIC SCROLLSPY READY FOR REUSE
# It has been hacked upa bit to work in our specific use case for step dots - could easily be made
# generic though.

angular.module('ChefStepsApp').directive 'scrollSpy', ["$window", "$timeout", ($window, $timeout) ->
  restrict: 'A'
  controller: ['$scope', ($scope) ->
    $scope.spies = []
    # a spyObj has an id, a function to call when it's section is in view,
    # and a function to call when it's out of sight.
    # This is created in the second directive
    @addSpy = (spyObj) ->
      #console.log "Add spy " + spyObj.spyScopeID + " spying on: " + spyObj.id 
      $scope.spies.push spyObj

    @removeSpy = (spyScopeID) ->
      spyObj = _.find($scope.spies, (spyObj) -> spyObj.spyScopeID == spyScopeID)
      #console.log "Remove spy " + spyObj.spyScopeID + " spying on: " + spyObj.id 

      $scope.spies = _.filter($scope.spies, (spy) -> spy["spyScopeID"] != spyScopeID)
      #console.log "Spy count " + $scope.spies.length

    $scope.$on 'loadActivityEvent',  ->
      # Clear cache
      $scope.spyElems = []
  ]

  link: (scope, elem, attrs) ->
    scope.spyElems = []

    scope.updateSpies = ->
      spy.out() for spy in scope.spies
      highlightSpy = scope.spies[0]
      offset = parseInt(attrs.offset || "0")

      for spy in scope.spies
        # Find the targets and put them in the cache
        scope.spyElems[spy.id] = elem.find('#'+spy.id) unless (scope.spyElems[spy.id]?.length > 0)

      for spy in scope.spies
        # Ignore any spies whose target isn't currently in the DOM - but it might come back
        if (scope.spyElems[spy.id]?.length > 0) && (scope.spyElems[spy.id].closest('html'))
          #console.log "Spy " + spy.id + " Delta " + (scope.spyElems[spy.id].offset().top - ($window.scrollY + offset))
          if (pos = scope.spyElems[spy.id].offset().top) - $window.scrollY <= offset
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
    scope.$on "$destroy", ->
      affix.removeSpy(scope.$id)

    affix.addSpy
      spyScopeID: scope.$id
      id: attrs.spy

      in: -> 
        elem.addClass('active')
        elem.parent().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().find('a').addClass('active-neighbor')
        elem.parent().next().next().next().find('a').addClass('active-more')
        elem.parent().prev().find('a').addClass('active-more')
        elem.removeClass('basic')

      out: -> 
        elem.removeClass 'active'
        elem.removeClass 'active-neighbor'
        elem.removeClass 'active-more'
        elem.addClass 'basic'

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
        scrollTop: $(el).offset().top - 238
      , 500
    (scope, element, attr) ->
      element.bind "click", (event) ->
        scrollInto attr.scrollTo

]