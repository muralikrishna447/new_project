@componentsManager.directive 'componentColorPicker', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    componentModel: '='
  }

  link: (scope, element, attrs) ->
    defaultColor = 'black'
    scope.colorOptions = ['white', 'black']
    scope.componentModel = {} unless scope.componentModel
    scope.componentModel.color = defaultColor unless scope.componentModel.color
    scope.showOptions = false

    scope.setColor = (color) ->
      scope.componentModel.color = color
      scope.showOptions = false

    scope.toggleOptions = ->
      scope.showOptions = ! scope.showOptions

  templateUrl: '/client_views/component_color_picker.html'
]
