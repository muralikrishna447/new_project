# This directive will place the correct image size into a div
# usage %div(cs-cover-image="FILEPICKER OBJECT")
# set reload-on-window-resize="true" if you want the reload the image when the window is resized.
# reloadOnWindowResize should probably be only used for once per page for performance reasons.  Ideal for large fullpage images

@app.directive 'csCoverImage', ['$window', '$http', 'csFilepickerMethods', ($window, $http, csFilepickerMethods) ->
  restrict: 'A'
  scope: { 
    csCoverImage: '='
    reloadOnWindowResize: '='
  }

  link: (scope, element, attrs) ->
    scope.baseURL = {}
    scope.coverImageStyle = {}
    scope.placeHolderImageStyle = {}
    scope.imageLoaded = true
    parent = {}
    source = {}
    urlWidth = 0
    parentHeightToWidth = 0
    sourceHeightToWidth = 0

    getParentDimensions = ->
      parent = element.parent()
      parent.width = element[0].clientWidth
      parent.height = parent[0].clientHeight
      console.log "Parent Width: ", parent.width
      console.log "Parent Height: ", parent.height

    getSourceImageDimensions = ->
      url = scope.baseURL + "/metadata?width=true&height=true"
      $http.get(url, {headers: {'X-Requested-With': undefined}}).then (response) ->
        console.log response.data
        source.width = response.data.width
        source.height = response.data.height
        if source.width && source.height
          compareDimensions()
          loadImage()

    # Determine if the parent dimensions are more landscape or more portrait compared to the source image dimensions
    compareDimensions = ->
      parentHeightToWidth = parent.height/parent.width
      sourceHeightToWidth = source.height/source.width
      console.log 'Parent ratio: ', parentHeightToWidth
      console.log 'Source ratio: ', sourceHeightToWidth
      if parentHeightToWidth <= sourceHeightToWidth
        urlWidth = parent.width
      else
        urlWidth = parent.height/sourceHeightToWidth
      console.log 'URL WIDTH: ', urlWidth


    loadImage = ->
      imageURL = window.cdnURL(scope.baseURL) + "/convert?w=#{urlWidth}&cache=true"
      scope.coverImageStyle = {
        "background-image": "url('" + imageURL + "')"
        "background-repeat": "no-repeat"
        "background-position": "center center"
        "background-size": "cover"
        "height": parent.height
      }

    scope.$watch 'csCoverImage', (newValue, oldValue) ->
      if newValue
        # csFilepickerMethods.convertTest(newValue, {w: 600, a: "16:9"})
        # csFilepickerMethods.convert(newValue, {w: 1600, h: 300})
        # csFilepickerMethods.convert(newValue, {w: 600, h: 500})
        # csFilepickerMethods.convert('https://d3awvtnmmsvyot.cloudfront.net/api/file/hello', {w: 600, h: 500})
        scope.baseURL = csFilepickerMethods.getBaseURL(newValue)
        getParentDimensions()
        getSourceImageDimensions()

    angular.element($window).bind 'resize', ->
      if scope.reloadOnWindowResize
        console.log 'WINDOW RESIZE RELOAD'
        _.throttle(
          getParentDimensions()
          compareDimensions()
          loadImage()
          scope.$apply()
        )

  template: """
    <div ng-show="imageLoaded" ng-style="coverImageStyle">
    </div>
    <div ng-show="! imageLoaded" ng-style="placeHolderImageStyle">
    </div>
  """

]

# Todo Make the default to the parent width and height but allows you to specify the width and height.

@app.directive 'csImage', ['$window', '$timeout', 'csFilepickerMethods', ($window, $timeout, csFilepickerMethods) ->
  restrict: 'E'
  scope: { 
    url: '@'
    height: '@'
    width: '@'
    aspect: '@'
  }

  link: (scope, element, attrs) ->
    parent = {}
    container = {}
    image = {}
    image.url = scope.url
    scope.finalImageClass = "cs-image hide"

    width = scope.width
    height = scope.height
    aspect = scope.aspect
    console.log width, height, aspect

    setContainerDimensions = ->
      parent = element.parent()
      console.log 'WIDTH: ', $(parent[0]).width()
      parent.width = $(parent[0]).width()
      parent.height = $(parent[0]).height()
      parent.heightToWidth = parent.height/parent.width
      console.log "Parent Width: ", parent.width
      # console.log "Parent Height: ", parent.height
      # console.log "Parent: ", parent

      # if width
      #   console.log 'Width Set'
      #   container.width =  if (width == 'parent') then parent.width else width

      # if height
      #   console.log 'Height Set'
      #   container.height = if (height == 'parent') then parent.height else height

      if aspect
        aspectArray = scope.aspect.split(':')
        aspectWidth = aspectArray[0]
        aspectHeight = aspectArray[1]

        if height && ! width
          container.height = if (height == 'parent') then parent.height else height
          container.width = container.height * aspectWidth / aspectHeight
        if ! height && width
          container.width =  if (width == 'parent') then parent.width else width
          container.height = container.width * aspectHeight / aspectWidth
        if ! height && ! width
          container.width = parent.width
          container.height = container.width * aspectHeight /aspectWidth
        if height && width
          container.width =  if (width == 'parent') then parent.width else width
          container.height = container.width * aspectHeight / aspectWidth

      else

        if height && ! width
          console.log "Only Height", width
          container.height = if (height == 'parent') then parent.height else height
          container.width = container.height / image.heightToWidth
        if ! height && width
          container.width =  if (width == 'parent') then parent.width else width
          container.height = container.width * image.heightToWidth
        if ! height && ! width
          container.width = parent.width
          container.height = container.height = container.width * image.heightToWidth
        if height && width
          console.log 'HEIGHT AND WIDTH'
          container.width =  if (width == 'parent') then parent.width else width
          container.height = if (height == 'parent') then parent.height else height

      container.heightToWidth = container.height / container.width
      console.log "PARENT HEIGHT: ", parent.height
      console.log "PARENT WIDTH: ", parent.width
      console.log "CONTAINER HEIGHT: ", container.height
      console.log "CONTAINER WIDTH: ", container.width


      # # Only width is provided
      # if scope.width && ! scope.height
      #   if scope.width == 'parent'
      #     container.width = parent.width
      #   else
      #     container.width = scope.width

      #   if scope.aspect
      #     container.height = container.width * aspectHeight / aspectWidth

      # # Only height is provided
      # if ! scope.width && scope.height
      #   if scope.height == 'parent'
      #     container.height = parent.height
      #   else
      #     container.height = scope.height
      #   if scope.aspect
      #     container.width = container.height * aspectWidth / aspectHeight
      #   else
      #     container.width = parent.width

      # # Nothing is provided
      # if ! scope.width && ! scope.height
      #   container.height = parent.height
      #   container.width = parent.width

      # # Both width and height provided
      # if scope.width && scope.height
      #   container.height = scope.height
      #   container.width = scope.width

      # container.heightToWidth = container.height / container.width

    calculateImageDimensions = ->
      console.log "Calculating Image Dimensions"
      console.log 'Parent ratio: ', parent.heightToWidth
      console.log 'Image ratio: ', image.heightToWidth
      if container.heightToWidth <= image.heightToWidth
        console.log 'short and wide'
        image.finalWidth = container.width
        image.finalHeight = image.finalWidth*image.heightToWidth
      else
        console.log 'tall and skinny'
        image.finalHeight = container.height
        image.finalWidth = image.finalHeight / image.heightToWidth
        # image.finalWidth = container.height/container.heightToWidth
        # image.finalHeight = image.finalWidth*image.heightToWidth
        console.log "IMAGE FINAL WIDTH: ", image.finalWidth
        console.log "IMAGE FINAL HEIGHT: ", image.finalHeight

    loadImage = ->
      scope.finalUrl = csFilepickerMethods.convert(image.url, {w: image.finalWidth})

      scope.containerStyle = {
        "overflow": "hidden"
        "height": container.height
        "width": container.width
      }
      scope.imageStyle = {
        "max-width": "inherit"
        "margin-left": "-" + (image.finalWidth - container.width)/2 + "px"
        "margin-top": "-" + (image.finalHeight - container.height)/2 + "px"
      }
      console.log '*****'

    loadTinyImage = ->
      scope.tinyImageSrc = csFilepickerMethods.convert(image.url, {w: 100})

    # 1. Get Parent dimensions
    # setContainerDimensions()

    # 2. When the url is available, load the tiny image
    scope.$watch 'url', (newValue, oldValue) ->
      if newValue
        loadTinyImage()

    # 3. When tiny image is loaded, calculate the final image dimensions
    scope.$on 'csTinyImageLoaded', (e, args) ->
      image.heightToWidth = args.height/args.width
      setContainerDimensions()
      calculateImageDimensions()
      loadImage()
      scope.$apply()

    scope.$on 'csFinalImageLoaded', (e, args) ->
      scope.containerStyle["opacity"] = "1"
      scope.$apply()

    angular.element($window).bind 'resize', _.throttle( ->
        console.log 'actually TROTTLED'
        setContainerDimensions()
        calculateImageDimensions()
        loadImage()
        scope.containerStyle["opacity"] = "1"
        scope.$apply()
      , 1000)

  template: """
    <div ng-if="!finalUrl" style="opacity:0;">
      <img ng-src="{{tinyImageSrc}}" cs-tiny-image>
    </div>
    <div ng-style="containerStyle" class="cs-image">
      <img ng-src="{{finalUrl}}" ng-style="imageStyle" cs-final-image-load>
    </div>
  """

]

@app.directive 'csTinyImage', ['$window', '$timeout', '$q', ($window, $timeout, $q) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'load', ->
      width = element[0].clientWidth
      height = element[0].clientHeight
      scope.$emit 'csTinyImageLoaded', {width: width, height: height}

]

@app.directive 'csFinalImageLoad', ['$window', '$timeout', '$q', ($window, $timeout, $q) ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'load', ->
      scope.$emit 'csFinalImageLoaded'

]
