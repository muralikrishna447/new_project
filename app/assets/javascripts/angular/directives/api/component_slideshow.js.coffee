@app.directive 'slideshow', ['$http', ($http) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->
    urlBase = 'https://dpybg80nberao.cloudfront.net/assets/dinner/'
    scope.images = []
    i = 0
    numImages = 54
    while i < numImages
      imageName = "14-Course-Dinner-#{i+1}.jpg"
      imageSource = urlBase + imageName
      scope.images.push imageSource
      i++

    scope.loaded = new Array(numImages)

    scope.fullscreen = false
    scope.currentIndex = 0

    scope.imageLoaded = (preloaded) ->
      console.log 'image loaded: ', preloaded
      scope.loaded[preloaded.index] = preloaded.image


    scope.preload = (index) ->
      prevIndex = index - 1
      scope.preload.prev =
        index: prevIndex
        image: scope.images[prevIndex]

      scope.preload.current =
        index: index
        image: scope.images[index]

      nextIndex = index + 1
      scope.preload.next =
        index: nextIndex
        image: scope.images[nextIndex]

    scope.prev = ->
      console.log 'clicked prev'
      scope.currentIndex -= 1
      scope.preload(scope.currentIndex)

    scope.next = ->
      console.log 'clicked next'
      scope.currentIndex += 1
      scope.preload(scope.currentIndex)

    scope.toggleFullscreen = ->
      scope.fullscreen = ! scope.fullscreen

    scope.backgroundImage = (image) ->
      {
        'background-image' : "url('#{image}')",
        'background-size' :'contain',
        'background-repeat' : 'no-repeat',
        'background-position' : '50% 50%'
      }

    scope.preload(0)

  templateUrl: '/client_views/component_slideshow.html'
]
