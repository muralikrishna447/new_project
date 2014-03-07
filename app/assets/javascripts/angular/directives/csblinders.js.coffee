@app.controller 'csBlindersController', ['$scope', ($scope) ->
  $scope.blinders = []

  this.inactiveWidth = $scope.inactiveWidth

  this.addBlinder = (blinder) ->
    $scope.blinders.push(blinder)

  this.expand = (clickedIndex) ->
    angular.forEach $scope.blinders, (blinder, key) ->
      if blinder.index == clickedIndex
        blinder.activate()
      else
        if blinder.index < clickedIndex
          blinder.deactivate('left')
        else
          blinder.deactivate('right')

  return this
]

@app.directive 'csBlinders',[ '$window', ($window) ->
  restrict: 'E'
  scope: {  }
  controller: 'csBlindersController'
  link: (scope, element, attrs) ->
    scope.calculateDimensions = ->
      # Calculate Everything
      el = angular.element(element)
      scope.width = el.width()
      if scope.width >= 420
        scope.inactiveWidth = 30
      else
        scope.inactiveWidth = 15
      scope.blinderCount = scope.blinders.length
      scope.blinderWidth = scope.width - (scope.blinderCount - 1)*scope.inactiveWidth
      scope.height = scope.blinderWidth*9/16
      scope.initialSpacing = scope.width/scope.blinderCount

      # Set height
      el.css 'height', scope.height
      scope.$parent.$broadcast 'blindersDimensionsSet', scope

    scope.calculateDimensions()

    angular.element($window).bind 'resize', ->
      scope.calculateDimensions()
]

@app.directive 'csBlinder', ->
  restrict: 'E'
  scope: {
    index: '='
  }
  require: '^csBlinders'
  link: (scope, element, attrs, csBlinders) ->
    csBlinders.addBlinder(scope)
    el = angular.element(element)

    scope.getDimensions = (blinders) ->
      scope.width = blinders.blinderWidth
      scope.height = blinders.height
      scope.initialSpacing = blinders.initialSpacing

    scope.setInitialDimensions = () ->
      el.css 'width', scope.width
      el.css 'height', scope.height
      el.css 'left', scope.index*scope.initialSpacing
      el.removeClass('active')
      if scope.index == 0
        scope.activate()
      else
        scope.deactivate()
        scope.active = false

    scope.$on 'blindersDimensionsSet', (event, blinders) ->
      scope.inactiveWidth = blinders.inactiveWidth
      console.log scope.inactiveWidth
      scope.getDimensions(blinders)
      scope.setInitialDimensions()

    el.click ->
      unless scope.active
        csBlinders.expand(scope.index)

    scope.activate = ->
      el.css 'left', scope.index*scope.inactiveWidth
      el.addClass('active')
      scope.active = true

    scope.deactivate = (side)->
      if side == 'left'
        el.css 'left', scope.index*scope.inactiveWidth
      else
        el.css 'left', (scope.index - 1)*scope.inactiveWidth + scope.width
      el.removeClass('active')
      scope.active = false