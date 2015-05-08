@app.directive 'slideshow', ['$http', ($http) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->
    urlBase = 'https://dpybg80nberao.cloudfront.net/assets/dinner/'
    images = []
    i = 1
    numImages = 55
    while i < numImages
      imageName = "14-Course-Dinner-#{i}.jpg"
      imageSource = urlBase + imageName
      images.push imageSource
      i++

    scope.viewer = {}
    scope.viewer.index = 0
    scope.viewer.prev = null
    scope.viewer.current = images[scope.viewer.index] unless scope.viewer.current
    scope.viewer.next = images[scope.viewer.index + 1]

    scope.prev = ->
      console.log 'clicked prev'
      scope.viewer.index -= 1
      scope.setViewer(scope.viewer.index)

    scope.next = ->
      console.log 'clicked next'
      scope.viewer.index += 1
      scope.setViewer(scope.viewer.index)

    scope.setViewer = (index) ->
      scope.viewer.prev = images[index - 1]
      scope.viewer.current = images[index]
      scope.viewer.next = images[index + 1]


  templateUrl: '/client_views/component_slideshow.html'
]
