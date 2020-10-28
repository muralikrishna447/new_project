@app.filter 'slideshowSmall', ->
  (image) ->
    image + '/convert?fit=crop&w=600&quality=90&cache=true'

@app.directive 'slideshow', ['$window', ($window) ->
  restrict: 'A'
  scope: {}
  link: (scope, element, attrs) ->

    i = 0
    numImages = 47
    numViewed = 0

    scope.slides = [
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZbAi8CVdQg6Y769XAVxB"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/uU46PdEHQNWjdMPBC9aA"
        caption: "Ben churning ice cream with liquid nitrogen for Course 4"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/Bqkh1lTQnyWuozfr65Kt"
        caption: "We scrawl our prep list on the fridge door"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/tl7pvWhQiCtEflmAU4lG"
        caption: "Grant and Nick making sure we have everything we need"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fDZSegNsRJmYtFzRcHrW"
        caption: "The table is set!"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/9gOk2cuKQJ2lHg3nuulZ"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/tpC2tqzzTeto1xXogBuc"
        caption: "We're organized and ready for battle"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fsvoWLpRByNuPQdZRg8n"
        caption: "Nick prepping the chocolate cherries for Course 13"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/7GhZEVnoRP2fc0hWzJKZ"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0UbJ9gtSTn2iSA0phwPm"
        caption: "These \"cherries\" are not as they seem—can you guess what they're made of?"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/VyflDraQlC02jurogATM"
        caption: "Scooping sorbet for the first course"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/gHtg75EiS16sHl3azvyp"
        caption: "We store equipment and ingredients for hot courses next to the oven"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/eye5fhX8QOaYst0sPpOp"
        caption: "Prepping our mise en place for Course 9"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/J4VOgfBQnOZwUeq1PZiq"
        caption: "Ben slicing fresh mangoes for Course 12"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/qLqzY5OTmGV0b155sJMw"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/NMfCuV6OSD21tOJwVleB"
        caption: "Pre-portioning dessert hours in advance makes service easier"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/mbrrr9bT5mDanpGxeZwg"
        caption: "Our wines are opened, chilled if needed, and lined up ready to go"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/lEloTfwNRmqDQBN3n0zC"
        caption: "Keeping track of wine pairings and mise en place"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ihnoAj8XTH2iZhxQv9e8"
        caption: "Mise en place organized by course, ready for our server"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0zrE7jnXRjScVWHTyLRY"
        caption: "Pre-service meeting"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/jGA6vVtpT8tvNdYUYw7A"
        caption: "Here we go!"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/WVkwGLUJQSud8jUbx0Ah"
        caption: "Guests are just arriving, but Course 14 is already prepped"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/4yUgsgpuTWSe5haMb2Vz"
        caption: "Keeping egg foam warm for Course 11"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/CzkOWJ6QQ8GmUYdwDxBR"
        caption: "Grant presenting the first course to our guests"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/M8Kqt5baR2qTDg2VHuKg"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/JSUOVuBMTY4xxKpACV4g"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/fe3FnX0kRzyTL1uHil3w"
        caption: "Our homemade \"chandelier.\" Did we mention Ben was an engineer?"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/8F1lHEZLSeGC8mysL3Aq"
        caption: "Dinner in full-swing"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/yYteTjhDRsWpNmYvwTaK"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/uuHyJEEySUC4UGkJsVfe"
        caption: "Putting the finishing touches on Course 4"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/6WBsmJfqQMktLiVv8OSE"
        caption: "Prepping for Course 5"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/4QtKb9l7Q5O1Zkjqaa4L"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/IkmKcp9aSQqSAiWoYDlb"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/rUzgRRGXR4GccswzxWF5"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/9pr2g4rPSJubVlaC4T2G"
        caption: "Finishing oil for Course 8"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/L39W4ErNRki50yaXXWg2"
        caption: "We keep detailed plating notes always at hand"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/SmsPSte3Sc6r0DsQlyd2"
        caption: "Pre-portioned jus ready for Course 10"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/EDBn3qP8RamCIo8YJBbZ"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/0BWtHfTRcSlxHpuGLltb"
        caption: "We're not shy about seasoning, people"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/EHCSDLwaTKebZIyOEvAH"
        caption: "Finishing some micro-veggies for Course 10"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/rRPMPwwZSU6r0wxMz5lT"
        caption: "Happy guests"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/kr3iWHTdvDPMSQHd2wv0"
        caption: "Finishing touches for Course 13"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/t1tgBnnPSPaZEYMJoFc5"
        caption: "It takes an army"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/wPap44jAQFWx8ChQTApg"
        caption: "The grand finale"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/ZNjjMzZbTiOmp2qYVEfO"
        caption: "Ending the evening with a simple, soothing tea course"
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/o3wju3hjSg2N1B5YIgkr"
        caption: ""
      }
      {
        image: "https://d3awvtnmmsvyot.cloudfront.net/api/file/JZ7wmnKpRFmdxG6BxxZX"
        caption: "Success!"
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
        if (scope.currentIndex + 1) > numViewed
          numViewed = scope.currentIndex + 1
          scope.trackNumViewed(numViewed)

    numViewed2to5 = false
    numViewed5to10 = false
    numViewed10to15 = false
    numViewed15to20 = false
    numViewed20to25 = false
    numViewed25to30 = false
    numViewedAll = false
    scope.trackNumViewed = (num) ->
      console.log 'trackNumViewed: ', num
      if num < 2 <= 5 && !numViewed2to5
        numViewed2to5 = true
      if 5 < num <= 10 && !numViewed5to10
        numViewed5to10 = true
      if 10 < num <= 15 && !numViewed10to15
        numViewed10to15 = true
      if 15 < num <= 20 && !numViewed15to20
        numViewed15to20 = true
      if 20 < num <= 25 && !numViewed20to25
        numViewed20to25 = true
      if 25 < num <= 30 && !numViewed25to30
        numViewed25to30 = true
      if num == numImages && !numViewedAll
        numViewedAll = true

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

    # This simply doesn't work on iOS mobile safari
    # $window.addEventListener 'beforeunload', (event) ->
    #   mixpanel.track 'Slideshow Views', { count: numViewed }

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
      </div>
    """
]
