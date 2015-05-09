@app.directive 'slideshow', ['$animate', ($animate) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->

    # Images stored in S3.  Generate array containing the cdn url
    urlBase = 'https://dpybg80nberao.cloudfront.net/assets/dinner/'
    scope.images = []
    i = 0
    numImages = 47
    while i < numImages
      imageName = "Tasting-Menu-Spring-#{i+1}.jpg"
      imageSource = urlBase + imageName
      scope.images.push imageSource
      i++

    # Create an emtpy array to later store loaded image urls
    scope.loaded = new Array(numImages)

    scope.fullscreen = false
    scope.showOverlay = true
    scope.currentIndex = 0
    scope.preload = {}

    scope.imageLoaded = (preloaded) ->
      scope.loaded[preloaded.index] = preloaded.image

    scope.preload = (index) ->
      prevIndex = index - 1
      if prevIndex >= 0
        scope.preload.prev =
          index: prevIndex
          image: scope.images[prevIndex]
      else
        scope.preload.prev = false

      scope.preload.current =
        index: index
        image: scope.images[index]

      nextIndex = index + 1
      if nextIndex < numImages
        scope.preload.next =
          index: nextIndex
          image: scope.images[nextIndex]
      else
        scope.preload.next = false

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

    scope.closeOverlay = ->
      scope.showOverlay = false

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

# This directive loads a batch of images and sorts it by the image number
# Should be refactored to be more generalized
@app.directive 'slideshowLoader', [ ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->
    scope.pick = ->
      filepicker.pickMultiple (blobs) ->
        scope.filepicker = blobs.sort (a, b) ->
          lastIntegerPattern = /\d*$/
          aNumber = parseInt(lastIntegerPattern.exec(a.filename.split('.')[0]))
          bNumber = parseInt(lastIntegerPattern.exec(b.filename.split('.')[0]))
          if aNumber > bNumber
            return 1
          if aNumber < bNumber
            return -1
          0
        scope.images = scope.filepicker.map (filepicker) ->
          return filepicker.url

  template:
    """
      <div>
        <div class='btn btn-primary' ng-click='pick()'>Load Files</div>
        <pre>{{filepicker|json}}</pre>
        <pre>{{images|json}}</pre>
        <div class='btn btn-primary' ng-click='testSort()'>Test Sort</div>
      </div>
    """
]
