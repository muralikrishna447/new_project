@app.directive 'csShowcase', ['$window', '$timeout', ($window, $timeout) ->
  restrict: 'A'
  scope: {
    collectionName: '@'
  }
  controller: ['$scope', ($scope) ->
    if $scope.collectionName == 'knives'
      $scope.collection = [
        {
          id: 1
          title: 'Gyuto Knives'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Knives-boxes-7.jpg"
        }
        {
          id: 2
          title: 'Tadafusa Nashiji Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-Gyuto.jpg"
          images: [
            "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-close.jpg"
          ]
          price: "400.00"
          annotations: [
            {
              type: 'right'
              title: 'Tadafusa Nashiji Gyuto'
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
              parentId: 2
              position: {
                x: 58
                y: 38
              }
            }
          ]
        }
        {
          id: 3
          title: 'RyuSen Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/RyuSen-Gyuto.jpg"
          price: "300.00"
          annotations: [
            {
              type: 'right'
              title: 'RyuSen Gyuto'
              description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
              parentId: 3
              position: {
                x: 58
                y: 42
              }
            }
          ]
        }
        {
          id: 4
          title: 'Mutsumi Hinoura Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Mutsumi-Hinoura-Gyuto-2.jpg"
          price: "600.00"
        }
      ]

    $scope.annotationLineStyle = (annotation) ->
      lineHeight = 20 # Percent
      annotationWidth = 30
      {
        top: lineHeight + '%'
        left: annotation.position.x + '%'
        height: annotation.position.y - lineHeight + '%'
        width: 100 - annotationWidth - annotation.position.x + '%'
      }

    $scope.annotationDotStyle = (annotation) ->
      {
        top: annotation.position.y + '%'
        left: annotation.position.x + '%'
      }

    $scope.currentItem = $scope.collection[0]

    updateCurrent: (item, progress) ->
      if $scope.currentItem != item
        $scope.showcaseCurrentClass = 'direction-' + $scope.direction
        $scope.$apply()
        $timeout ( ->
          $scope.currentItem = item
          console.log 'currentItem is: ', $scope.currentItem
          console.log 'updating Current with: ', $scope.direction
          $scope.showcaseCurrentClass = ''
          $scope.$apply()
        ), 300

  ]

  link: (scope, element, attrs) ->
    oldPosition = 0
    windowElement = angular.element($window)
    windowElement.on 'scroll', (e) ->
      position = windowElement.scrollTop()
      # console.log 'WINDOW POSITION: ', position
      if oldPosition
        diff = oldPosition - position
        if diff > 0
          # console.log 'SCROLLING UP'
          scope.direction = 'up'
        else
          # console.log 'SCROLLING DOWN'
          scope.direction = 'down'
      # console.log 'oldPosition: ', oldPosition
      oldPosition = position



  templateUrl: '/client_views/cs_showcase.html'
]

@app.directive 'csShowcaseItem', ['$window', '$timeout', ($window, $timeout) ->
  require: '^csShowcase'
  restrict: 'A'
  scope: {
    csShowcaseItem: '='
  }

  link: (scope, element, attrs, csShowcaseController) ->
    windowElement = angular.element($window)
    windowHeight = windowElement.height()
    # imageElement = element.find('img')
    # console.log 'image: ', imageElement

    windowElement.on 'scroll', (e) ->
      el = angular.element(element)
      offset = 0.5*windowHeight
      height = el[0].offsetHeight

      start = el[0].offsetTop - offset
      end = start + height

      position = windowElement.scrollTop()
      
      # console.log 'position: ', position
      
      if start <= position < end
        # console.log 'start', start
        # console.log 'end', end
        completed = position - start
        progress = completed/height*100
        csShowcaseController.updateCurrent(scope.csShowcaseItem, progress)

]

@app.directive 'csShowcaseImage', [ ->
  restrict: 'A'
  replace: true
  scope: {
    csShowcaseImage: '='
  }

  link: (scope, element, attrs) ->
    # console.log 'scope: ', scope
    # console.log 'image element: ', element[0].clientHeight

    element.on 'load', (e) ->
      # console.log 'LOADED: ', e
      # console.log 'element: ', element
      height = element[0].height
      scope.csShowcaseImage.imageHeight = height

  template:
    """
      <img src="{{csShowcaseImage.imageUrl}}"/>
    """
]