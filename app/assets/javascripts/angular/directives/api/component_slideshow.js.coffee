@app.directive 'slideshow', ['$animate', ($animate) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->

    # Images stored in S3.  Generate array containing the cdn url
    urlBase = 'https://dpybg80nberao.cloudfront.net/assets/dinner/'
    scope.images = []
    i = 0
    numImages = 54
    while i < numImages
      imageName = "14-Course-Dinner-#{i+1}.jpg"
      imageSource = urlBase + imageName
      scope.images.push imageSource
      i++

    # Create an emtpy array to later store loaded image urls
    scope.loaded = new Array(numImages)

    scope.fullscreen = false
    scope.currentIndex = 0

    scope.imageLoaded = (preloaded) ->
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
      if scope.currentIndex > 0
        scope.currentIndex -= 1
        scope.preload(scope.currentIndex)

    scope.next = ->
      if scope.currentIndex < (numImages - 1)
        scope.currentIndex += 1
        scope.preload(scope.currentIndex)

    scope.toggleFullscreen = ->
      scope.fullscreen = ! scope.fullscreen

    # Using this method to set the slide background image because background-size: contain handles different sized images well
    scope.backgroundImage = (image) ->
      { 'background-image' : "url('#{image}')" }

    window.onkeydown = (event) ->
      switch event.keyCode
        when 37
          scope.prev()
          scope.$apply()
        when 39
          scope.next()
          scope.$apply()

    # Preload the first set of images
    scope.preload(0)

  templateUrl: '/client_views/component_slideshow.html'
]
