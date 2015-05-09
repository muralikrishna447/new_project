@app.filter 'slideshowSmall', ->
  (image) ->
    image + '/convert?fit=crop&w=600&quality=90&cache=true'

@app.directive 'slideshow', ['$animate', ($animate) ->
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
      "https://www.filepicker.io/api/file/ltsdgOiaR4G6eLwGZGIX",
      "https://www.filepicker.io/api/file/WFiIVN4jR26YhlTSC9Vz",
      "https://www.filepicker.io/api/file/FEdjre0ySZm763quJBTI",
      "https://www.filepicker.io/api/file/Ehh6HW6FSs6tdNvglQbG",
      "https://www.filepicker.io/api/file/f1ajQZPDScOqZQkOdOQ2",
      "https://www.filepicker.io/api/file/7xGmE0XZS9udzfXAWxNz",
      "https://www.filepicker.io/api/file/IxifNxQOmj5WnMvv7jDw",
      "https://www.filepicker.io/api/file/3B7E095hRrD6DnCZWcVh",
      "https://www.filepicker.io/api/file/d9XNiE7FTTmgvUxGMJOX",
      "https://www.filepicker.io/api/file/UIy0Y2B8T229eePgI62c",
      "https://www.filepicker.io/api/file/l0HHZLpASCYlyMSWAlHN",
      "https://www.filepicker.io/api/file/hu6bRJe7T9GmE2l6xHE9",
      "https://www.filepicker.io/api/file/GMBgLaCSs6CtIT3qcrW9",
      "https://www.filepicker.io/api/file/6SA443WSSDWoLBBisqLc",
      "https://www.filepicker.io/api/file/iSm5ZbiJSNWIn0N4nLYq",
      "https://www.filepicker.io/api/file/YYsV1TNOStqawAkGwGKd",
      "https://www.filepicker.io/api/file/xvUzx4PQcuv9dUf4iAsp",
      "https://www.filepicker.io/api/file/dKAC07MToShjMBfqKuRw",
      "https://www.filepicker.io/api/file/zIRxE8pZSLE9D2Q8QzsQ",
      "https://www.filepicker.io/api/file/g3ivLttRq8DnK9fwzNlQ",
      "https://www.filepicker.io/api/file/ry6iNGdeTuClWahAZ8WC",
      "https://www.filepicker.io/api/file/nGL3JrVOQmCFEfB2kh4X",
      "https://www.filepicker.io/api/file/ZvVw63OTdOGKrJb4a05m",
      "https://www.filepicker.io/api/file/ol4wZtX2TyaRTMt2qL17",
      "https://www.filepicker.io/api/file/Gwv0IYR1RZSOEv4JIgHv",
      "https://www.filepicker.io/api/file/C3EUQ4UQvKMJJ2DDCp7S",
      "https://www.filepicker.io/api/file/lAINj0aSlqzi5lIN99BI",
      "https://www.filepicker.io/api/file/YUR0TKgPToij0LteDcJG",
      "https://www.filepicker.io/api/file/YzYeeLGpSpGrgJRzkxwr",
      "https://www.filepicker.io/api/file/j4R8SJQxR6u9M7BCHK8e",
      "https://www.filepicker.io/api/file/ZnVrz9oTSWezSJkrXtRp",
      "https://www.filepicker.io/api/file/JckoCpvkSaORrsR1kBJc",
      "https://www.filepicker.io/api/file/xDAYTHZvQHKnxXePE7L2",
      "https://www.filepicker.io/api/file/pgYpOShnQCW0xKqp5Ubn",
      "https://www.filepicker.io/api/file/lgc8RkLiTGWlR1Rr26I8",
      "https://www.filepicker.io/api/file/6L5WdUsPQbqmZtV0YIXV",
      "https://www.filepicker.io/api/file/AGuDo2OtTQOLLyPpIoPJ",
      "https://www.filepicker.io/api/file/sMRcwrTzSJmx0MtXgwuh",
      "https://www.filepicker.io/api/file/CNgtP4SKSaRUN9ruhJe5",
      "https://www.filepicker.io/api/file/XzFneUxMT1ivOgthwVzs",
      "https://www.filepicker.io/api/file/Omvq4LtUTCmfxtOmJ0QD",
      "https://www.filepicker.io/api/file/sga0qnIQSCYeNSGMnLRT",
      "https://www.filepicker.io/api/file/CokQZw1jQuSqGszUiPuM",
      "https://www.filepicker.io/api/file/3bBi8VtcQHyhRlJ69ecV",
      "https://www.filepicker.io/api/file/dBs5wPNfRhq5k6OPsSM8",
      "https://www.filepicker.io/api/file/CjR8DJSYSwilW1I0cICo",
      "https://www.filepicker.io/api/file/v8osjN4LRFKICkkxL8cw"
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
      cropped = image + '/convert?fit=crop&w=600&quality=90&cache=true'
      { 'background-image' : "url('#{cropped}')" }

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
