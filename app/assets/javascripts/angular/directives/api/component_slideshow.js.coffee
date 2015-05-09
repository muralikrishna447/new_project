@app.filter 'slideshowSmall', ->
  (image) ->
    image + '/convert?fit=crop&w=600&quality=90&cache=true'

@app.directive 'slideshow', ['$window', ($window) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->

    # Images stored in S3.  Generate array containing the cdn url
    # urlBase = 'https://dpybg80nberao.cloudfront.net/assets/dinner/'
    # scope.images = []
    i = 0
    numImages = 47
    # while i < numImages
    #   imageName = "Tasting-Menu-Spring-#{i+1}.jpg"
    #   imageSource = urlBase + imageName
    #   scope.images.push imageSource
    #   i++

    scope.images = [
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZbAi8CVdQg6Y769XAVxB",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/uU46PdEHQNWjdMPBC9aA",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/Bqkh1lTQnyWuozfr65Kt",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/tl7pvWhQiCtEflmAU4lG",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/fDZSegNsRJmYtFzRcHrW",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/9gOk2cuKQJ2lHg3nuulZ",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/tpC2tqzzTeto1xXogBuc",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/fsvoWLpRByNuPQdZRg8n",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/7GhZEVnoRP2fc0hWzJKZ",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/0UbJ9gtSTn2iSA0phwPm",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/VyflDraQlC02jurogATM",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/gHtg75EiS16sHl3azvyp",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/eye5fhX8QOaYst0sPpOp",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/J4VOgfBQnOZwUeq1PZiq",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/qLqzY5OTmGV0b155sJMw",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/NMfCuV6OSD21tOJwVleB",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/mbrrr9bT5mDanpGxeZwg",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/lEloTfwNRmqDQBN3n0zC",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/ihnoAj8XTH2iZhxQv9e8",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/0zrE7jnXRjScVWHTyLRY",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/jGA6vVtpT8tvNdYUYw7A",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/WVkwGLUJQSud8jUbx0Ah",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/4yUgsgpuTWSe5haMb2Vz",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/CzkOWJ6QQ8GmUYdwDxBR",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/M8Kqt5baR2qTDg2VHuKg",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/JSUOVuBMTY4xxKpACV4g",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/fe3FnX0kRzyTL1uHil3w",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/8F1lHEZLSeGC8mysL3Aq",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/yYteTjhDRsWpNmYvwTaK",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/uuHyJEEySUC4UGkJsVfe",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/6WBsmJfqQMktLiVv8OSE",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/4QtKb9l7Q5O1Zkjqaa4L",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/IkmKcp9aSQqSAiWoYDlb",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/rUzgRRGXR4GccswzxWF5",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/9pr2g4rPSJubVlaC4T2G",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/L39W4ErNRki50yaXXWg2",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/SmsPSte3Sc6r0DsQlyd2",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/EDBn3qP8RamCIo8YJBbZ",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/0BWtHfTRcSlxHpuGLltb",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/EHCSDLwaTKebZIyOEvAH",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/rRPMPwwZSU6r0wxMz5lT",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/kr3iWHTdvDPMSQHd2wv0",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/t1tgBnnPSPaZEYMJoFc5",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/wPap44jAQFWx8ChQTApg",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZNjjMzZbTiOmp2qYVEfO",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/JZ7wmnKpRFmdxG6BxxZX",
      "https://d3awvtnmmsvyot.cloudfront.net/api/file/o3wju3hjSg2N1B5YIgkr"
    ]

    # Create an emtpy array to later store loaded image urls
    scope.loaded = new Array(numImages)

    scope.fullscreen = false
    scope.showOverlay = true
    scope.currentIndex = 0
    scope.preload = {}

    scope.imageLoaded = (preloaded) ->
      scope.loaded[preloaded.index] = preloaded.image

    scope.preload = (index) ->
      componentWidth = scope.componentWidth()
      imageWidth = scope.determineImageWidth(componentWidth)
      console.log 'imageWidth: ', imageWidth
      prevIndex = index - 1
      if prevIndex >= 0
        scope.preload.prev =
          index: prevIndex
          image: scope.images[prevIndex] + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"
      else
        scope.preload.prev = false

      scope.preload.current =
        index: index
        image: scope.images[index] + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"

      nextIndex = index + 1
      if nextIndex < numImages
        scope.preload.next =
          index: nextIndex
          image: scope.images[nextIndex] + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"
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

    scope.componentWidth = ->
      if scope.fullscreen
        $window.innerWidth
      else
        element[0].clientWidth

    scope.determineImageWidth = (componentWidth) ->
      console.log 'componentWidth: ', componentWidth
      if componentWidth > 1600
        return 2000
      else if 1000 < componentWidth <= 1600
        return 1600
      else if 600 < componentWidth <= 1000
        return 1000
      else if 400 < componentWidth <= 600
        return 600
      else
        return 400

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
