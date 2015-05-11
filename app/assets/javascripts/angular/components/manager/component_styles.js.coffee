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

@componentsManager.directive 'componentPaddingPicker', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    componentModel: '='
  }

  link: (scope, element, attrs) ->
    defaultPadding = '0px'
    scope.paddingOptions = ['0px', '20px', '40px']
    scope.componentModel = {} unless scope.componentModel
    scope.componentModel.padding = defaultPadding unless scope.componentModel.padding
    scope.showOptions = false

    scope.setPadding = (padding) ->
      scope.componentModel.padding = padding
      scope.showOptions = false

    scope.toggleOptions = ->
      scope.showOptions = ! scope.showOptions

  templateUrl: '/client_views/component_padding_picker.html'
]
