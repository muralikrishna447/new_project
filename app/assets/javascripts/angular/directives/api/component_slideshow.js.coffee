@app.filter 'slideshowSmall', ->
  (image) ->
    image + '/convert?fit=crop&w=600&quality=90&cache=true'

@app.directive 'slideshow', ['$window', ($window) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->

    i = 0
    numImages = 47

    scope.slides = [
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZbAi8CVdQg6Y769XAVxB"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/uU46PdEHQNWjdMPBC9aA"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Bqkh1lTQnyWuozfr65Kt"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/tl7pvWhQiCtEflmAU4lG"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fDZSegNsRJmYtFzRcHrW"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/9gOk2cuKQJ2lHg3nuulZ"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/tpC2tqzzTeto1xXogBuc"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fsvoWLpRByNuPQdZRg8n"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/7GhZEVnoRP2fc0hWzJKZ"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0UbJ9gtSTn2iSA0phwPm"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/VyflDraQlC02jurogATM"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/gHtg75EiS16sHl3azvyp"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/eye5fhX8QOaYst0sPpOp"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/J4VOgfBQnOZwUeq1PZiq"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/qLqzY5OTmGV0b155sJMw"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/NMfCuV6OSD21tOJwVleB"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/mbrrr9bT5mDanpGxeZwg"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/lEloTfwNRmqDQBN3n0zC"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ihnoAj8XTH2iZhxQv9e8"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0zrE7jnXRjScVWHTyLRY"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/jGA6vVtpT8tvNdYUYw7A"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/WVkwGLUJQSud8jUbx0Ah"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/4yUgsgpuTWSe5haMb2Vz"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/CzkOWJ6QQ8GmUYdwDxBR"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/M8Kqt5baR2qTDg2VHuKg"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/JSUOVuBMTY4xxKpACV4g"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fe3FnX0kRzyTL1uHil3w"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/8F1lHEZLSeGC8mysL3Aq"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/yYteTjhDRsWpNmYvwTaK"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/uuHyJEEySUC4UGkJsVfe"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6WBsmJfqQMktLiVv8OSE"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/4QtKb9l7Q5O1Zkjqaa4L"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/IkmKcp9aSQqSAiWoYDlb"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/rUzgRRGXR4GccswzxWF5"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/9pr2g4rPSJubVlaC4T2G"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/L39W4ErNRki50yaXXWg2"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SmsPSte3Sc6r0DsQlyd2"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/EDBn3qP8RamCIo8YJBbZ"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0BWtHfTRcSlxHpuGLltb"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/EHCSDLwaTKebZIyOEvAH"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/rRPMPwwZSU6r0wxMz5lT"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/kr3iWHTdvDPMSQHd2wv0"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/t1tgBnnPSPaZEYMJoFc5"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/wPap44jAQFWx8ChQTApg"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZNjjMzZbTiOmp2qYVEfO"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/JZ7wmnKpRFmdxG6BxxZX"
        caption: ""
      },
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/o3wju3hjSg2N1B5YIgkr"
        caption: ""
      }
    ]

    # Create an emtpy array to later store loaded image urls
    scope.loaded = new Array(numImages)

    scope.fullscreen = false
    scope.showOverlay = true
    scope.currentIndex = 0
    scope.preload = {}

    scope.imageLoaded = (preloaded) ->
      # scope.loaded[preloaded.index] = preloaded.image
      preloadedWidth = preloaded.imageWidth
      loadedWidth = scope.slides[preloaded.index].loadedWidth

      if loadedWidth
        if preloadedWidth > loadedWidth
          scope.slides[preloaded.index].loadedWidth = preloadedWidth
      else
        scope.slides[preloaded.index].loadedWidth = preloadedWidth

    scope.preload = (index) ->
      componentWidth = scope.componentWidth()
      imageWidth = scope.determineImageWidth(componentWidth)
      console.log 'imageWidth: ', imageWidth
      prevIndex = index - 1
      if prevIndex >= 0
        scope.preload.prev =
          index: prevIndex
          image: scope.slides[prevIndex].image + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"
          imageWidth: imageWidth
      else
        scope.preload.prev = false

      scope.preload.current =
        index: index
        image: scope.slides[index].image + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"
        imageWidth: imageWidth

      nextIndex = index + 1
      if nextIndex < numImages
        scope.preload.next =
          index: nextIndex
          image: scope.slides[nextIndex].image + "/convert?fit=crop&w=#{imageWidth}&quality=90&cache=true"
          imageWidth: imageWidth
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
    scope.backgroundImage = (slide) ->
      if slide && slide.loadedWidth
        imageUrl = slide.image + "/convert?fit=crop&w=#{slide.loadedWidth}&quality=90&cache=true"
        { 'background-image' : "url('#{imageUrl}')" }

    scope.componentWidth = ->
      if scope.fullscreen
        $window.innerWidth
      else
        element[0].clientWidth

    scope.determineImageWidth = (componentWidth) ->
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
