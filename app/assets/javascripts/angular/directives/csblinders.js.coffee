@app.controller 'csBlindersController', ['$scope', ($scope) ->
  $scope.blinders = []

  this.inactiveWidth = $scope.inactiveWidth

  this.addBlinder = (blinder) ->
    console.log 'Blinders: ', $scope.blinders
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

  this.reset = ->
    angular.forEach $scope.blinders, (blinder, key) ->
      blinder.setInitialDimensions()
  return this
]

@app.directive 'csBlinders', ->
  restrict: 'E'
  scope: {
    inactiveWidth: '='
  }
  controller: 'csBlindersController'
  link: (scope, element, attrs) ->
    # Calculate Everything
    el = angular.element(element)
    scope.width = el.width()
    scope.blinderCount = scope.blinders.length
    scope.blinderWidth = scope.width - (scope.blinderCount - 1)*scope.inactiveWidth
    scope.height = scope.blinderWidth*9/16
    scope.initialSpacing = scope.width/scope.blinderCount
    # console.log 'Blinder Width', scope.width
    # console.log 'height', scope.height
    # console.log 'initialSpacing', scope.initialSpacing

    # Set height
    el.css 'height', scope.height
    scope.$parent.$broadcast 'blindersDimensionsSet', scope

@app.directive 'csBlinder', ->
  restrict: 'E'
  scope: {
    index: '='
  }
  require: '^csBlinders'
  link: (scope, element, attrs, csBlinders) ->
    csBlinders.addBlinder(scope)
    inactiveWidth = csBlinders.inactiveWidth
    el = angular.element(element)

    scope.getDimensions = (blinders) ->
      scope.width = blinders.blinderWidth
      scope.height = blinders.height
      scope.initialSpacing = blinders.initialSpacing

    scope.setInitialDimensions = () ->
      el.css 'width', scope.width
      el.css 'height', scope.height
      el.css 'left', scope.index*scope.initialSpacing
      console.log 'WIdth', scope.width
      console.log 'Height', scope.height
      console.log 'Left', scope.index*scope.initialSpacing
      el.removeClass('active')
      scope.active = false

    scope.$on 'blindersDimensionsSet', (event, blinders) ->
      scope.getDimensions(blinders)
      scope.setInitialDimensions()

    el.click ->
      if scope.active
        console.log 'active dag'
        csBlinders.reset()
      else
        csBlinders.expand(scope.index)

    scope.activate = ->
      el.css 'left', scope.index*inactiveWidth
      el.addClass('active')
      scope.active = true

    scope.deactivate = (side)->
      if side == 'left'
        el.css 'left', scope.index*inactiveWidth
      else
        el.css 'left', (scope.index - 1)*inactiveWidth + scope.width
      el.removeClass('active')
      scope.active = false