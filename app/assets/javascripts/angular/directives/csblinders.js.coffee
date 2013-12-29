angular.module('ChefStepsApp').directive 'csblinders', [ ->
  restrict: 'A'
  scope: true
  link: (scope, element, attrs) ->
    el = angular.element(element)
    scope.width = angular.element(element).width()
    # scope.height = scope.width*9/16
    el.css('height', scope.height)
    scope.objectCount = attrs.objectCount
    scope.blinderWidth = scope.width/scope.objectCount
    scope.inactiveWidth = 40
    scope.activeWidth = scope.width - scope.inactiveWidth*(scope.objectCount - 1)
    scope.height = scope.activeWidth*9/16
    scope.$broadcast('blinderDimensionsReady', scope.blinderWidth, scope.height)

    scope.$on 'expandThisBlinder', (e) ->
      index = e.targetScope.index
      blinders = el.find('.cs-blinder')

      angular.forEach blinders, (blinder, key) ->
        blinderElement = angular.element(blinder)
        image = blinderElement.find('img')
        if key == index
          blinderElement.addClass('active')
          blinderElement.width(scope.activeWidth)
          blinderElement.css('left', key*scope.inactiveWidth)
          image.css('margin-left', 0)
        else
          blinderElement.removeClass('active')
          blinderElement.width(scope.inactiveWidth)
          image.css('margin-left', -scope.width/2)
          if key < index
            blinderElement.css('left', key*scope.inactiveWidth)
          else
            blinderElement.css('left', (key - 1)*scope.inactiveWidth + scope.activeWidth)
]

angular.module('ChefStepsApp').directive 'csblinder', [ ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->
    el = angular.element(element)
    image = el.find('img')
    scope.index = parseInt(attrs.index)
    scope.setWidth = ->
      el.width(scope.blinderWidth)

    scope.setPosition = ->
      el.css('left', attrs.index*scope.blinderWidth)

    scope.setImage = ->
      image.css('width', scope.activeWidth)
      image.css('margin-left', -scope.activeWidth/2)

    scope.setHeight = ->
      el.css('height', scope.height)

    scope.$on 'blinderDimensionsReady', (w) ->
      scope.blinderWidth = w.targetScope.blinderWidth
      scope.height = w.targetScope.height
      scope.setWidth()
      scope.setHeight()
      scope.setPosition()
      scope.setImage()

    scope.expandBlinder = ->
      scope.$emit 'expandThisBlinder', attrs.index

]