angular.module('ChefStepsApp').directive 'csblinders', [ ->
  restrict: 'A'
  scope: {
    blindercount: '='
    inactivewidth: '='
  }
  controller: [ '$scope', ($scope) ->
    $scope.blinders = []

    this.blinders = $scope.blinders
    this.inactivewidth = $scope.inactivewidth
    this.blinderWidth = $scope.blinderWidth

    this.addBlinder = (blinder) ->
      $scope.blinders.push(blinder)
      console.log $scope.blinders
    return this
  ]
  link: (scope, element, attrs) ->
    el = angular.element(element)
    scope.width = el.width()
    scope.blinderWidth = scope.width - (scope.blindercount - 1)*scope.inactivewidth
    scope.height = scope.blinderWidth*9/16
    scope.initialSpacing = scope.width/scope.blindercount
    el.css 'height', scope.height
    scope.$broadcast('blinderDimensionsReady', scope)

    scope.$on 'expandThisBlinder', (event, clickedBlinder) ->
      console.log 'got epaaan'
      active = clickedBlinder.index
      console.log 'Clicked Index', active
      angular.forEach scope.blinders, (blinder, index) ->
        blinderElement = angular.element(blinder)
        if index == active
          console.log 'activating: ' + index
          blinder.activate()
        if index < active
          console.log 'left: ' + index
          blinder.deactivate('left')
        if index > active
          console.log 'right: ' + index
          blinder.deactivate('right')

    scope.$on 'reset', ->
      console.log 'reset'
      angular.forEach scope.blinders, (blinder) ->
        blinder.initBlinderDimensions()
    return this
]

angular.module('ChefStepsApp').directive 'csblinder', [ ->
  restrict: 'A'
  require: '^csblinders'
  scope: {
    index: '='
  }
  link: (scope, element, attrs, csblinders) ->
    csblinders.addBlinder(scope)
    el = angular.element(element)

    scope.initBlinderDimensions = ->
      el.css 'width', scope.width
      el.css 'height', scope.height
      el.css 'left', scope.index*scope.initialSpacing
      # console.log 'WIdth', scope.width
      # console.log 'Height', scope.height
      # console.log 'Left', scope.index*scope.initialSpacing
      scope.active = false

    scope.activate = ->
      scope.active = true
      el.css 'left', scope.index*csblinders.inactivewidth

    scope.deactivate = (side) ->
      scope.active = false
      if side == 'left'
        el.css 'left', scope.index*csblinders.inactivewidth
      else
        el.css 'left', (scope.index - 1)*csblinders.inactivewidth + scope.width

    scope.$on 'blinderDimensionsReady', (event, blinders) ->
      scope.width = blinders.blinderWidth
      scope.height = blinders.height
      scope.initialSpacing = blinders.initialSpacing
      scope.initBlinderDimensions()

    scope.expandBlinder = ->
      console.log 'trying to expand'
      if scope.active
        scope.$emit 'reset'
      else
        scope.$emit 'expandThisBlinder', scope

    el.click ->
      scope.expandBlinder()

]