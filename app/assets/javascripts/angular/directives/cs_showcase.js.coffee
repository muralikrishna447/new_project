@app.directive 'csShowcase', ['$window', ($window) ->
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
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Gyuto-all-2.jpg"
        }
        {
          id: 2
          title: 'Tadafusa Nashiji Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Tadafusa-Nashiji-Gyuto.jpg"
          price: "400.00"
        }
        {
          id: 3
          title: 'RyuSen Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/RyuSen-Gyuto.jpg"
          price: "300.00"
        }
        {
          id: 4
          title: 'Mutsumi Hinoura Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          imageUrl: "https://d92f495ogyf88.cloudfront.net/Knives-draft/Mutsumi-Hinoura-Gyuto-2.jpg"
          price: "600.00"
        }
      ]

      $scope.annotations = [
        {
          type: 'title'
          title: 'Gyuto Knives'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 1
        }
        {
          type: 'title'
          title: 'Tadafusa Nashiji Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 2
        }
        {
          type: 'right'
          title: 'Tadafusa Nashiji Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 2
          position: {
            x: 58
            y: 28
          }
        }
        {
          type: 'title'
          title: 'RyuSen Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 3
        }
        {
          type: 'right'
          title: 'RyuSen Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 3
          position: {
            x: 58
            y: 28
          }
        }
        {
          type: 'title'
          title: 'Mutsumi Hinoura Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 4
        }
        {
          type: 'right'
          title: 'Mutsumi Hinoura Gyuto'
          description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et quam rhoncus, ornare erat in, volutpat purus. Maecenas lobortis vehicula lacus, quis mollis augue consequat ac. Maecenas lobortis semper sem nec mollis. Aenean auctor varius est sed pellentesque."
          parentId: 4
          position: {
            x: 58
            y: 28
          }
        }
      ]

    $scope.currentItem = $scope.collection[0]
    $scope.currentAnnotation = null

    _.each $scope.annotations, (item) ->
      item.class = "cs-showcase-item-" + item.type

    $scope.setAnnotation = (collectionItem, annotation) ->
      collectionItem.currentAnnotationStyle = {
        top: annotation.position.y + '%'
        left: annotation.position.x + '%'
      }
      # console.log 'ANNOTATION: ', $scope.currentItem.currentAnnotationStyle

    updateCurrent: (annotation, progress) ->
      # console.log 'progress: ' + progress + '%'
      if $scope.currentAnnotation != annotation
        $scope.currentAnnotation = annotation

        # Set current collection item
        if annotation.parentId
          translateDistance = 0
          stop = false
          _.each $scope.collection, (item, index) ->
            if item.id == annotation.parentId
              $scope.currentItem = item
              if annotation.position
                $scope.showAnnotations = true
                $scope.setAnnotation(item, annotation)
              else
                $scope.showAnnotations = false
              stop = true
            else if stop != true
              translateDistance += item.imageHeight

          $scope.showcaseStyle = {
            transform: "translateY(-#{translateDistance}px)"
          }

        $scope.$apply()

  ]

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

    angular.element($window).on 'scroll', (e) ->
      el = angular.element(element)
      offset = 0.5*windowHeight
      height = el[0].offsetHeight

      start = el[0].offsetTop - offset
      end = start + height

      position = windowElement.scrollTop()
      
      # console.log 'position: ', position
      
      if start <= position < end
        
        completed = position - start
        progress = completed/height*100

        if 5 <= progress <= 95
          element.addClass('active')
        else
          element.removeClass('active')

        csShowcaseController.updateCurrent(scope.csShowcaseItem, progress)
      else
        element.removeClass('active')

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
      console.log 'LOADED: ', e
      console.log 'element: ', element
      height = element[0].height
      scope.csShowcaseImage.imageHeight = height

  template:
    """
      <img src="{{csShowcaseImage.imageUrl}}"/>
    """
]
