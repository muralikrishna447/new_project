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

@componentsManager.directive 'componentSizePicker', ['$http', ($http) ->
  restrict: 'A'
  scope: {
    componentModel: '='
  }

  link: (scope, element, attrs) ->
    # defaultSize = '0px'
    # scope.paddingOptions = ['0px', '20px', '40px']
    defaultSize = 'full'
    scope.sizeOptions = ['full', 'small', 'medium', 'large']
    scope.componentModel = {} unless scope.componentModel
    console.log 'componentModel: ', scope.componentModel
    scope.componentModel.size = defaultSize unless scope.componentModel.size
    scope.showOptions = false

    scope.setSize = (size) ->
      scope.componentModel.size = size
      scope.showOptions = false

    scope.toggleOptions = ->
      scope.showOptions = ! scope.showOptions

  templateUrl: '/client_views/component_size_picker.html'
]
