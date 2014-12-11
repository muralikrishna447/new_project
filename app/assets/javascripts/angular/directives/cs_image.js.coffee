###
This directive will place the correct image size into a div
Usage examples:

Simply providing a url will set the width the the width of the parent.  The height will be the aspect ratio of the original image.
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'")

Set an image to a height of 200px.  The width will be the aspect ratio of the original image.
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" height="200")

Set an image to a height of 400px.  The height will be the aspect ratio of the original image.
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" width="400")

Setting both height and width will give you cropped image with the specified dimensions:
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" width="400" height="100")

Aspect ratio can also be passed in:
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" width="400" aspect="16:9")
%cs-image(url="'https://d3awvtnmmsvyot.cloudfront.net/api/file/REHPnf8WQZWhQzj4rCQj'" width="400" aspect="4:3")

Objects can also be passed in:
%cs-image(url="step.image_id" width="400" aspect="4:3")

Note: Objects can actually be a filepicker object or a URL

Note: The if the viewable area of the resulting image is less than the original, this directive will center the viewable area. For example, if the viewable is short and wide, the viewable area will be vertically centered.
###

@app.directive 'csImage', ['$window', '$timeout', 'csFilepickerMethods', ($window, $timeout, csFilepickerMethods) ->
  restrict: 'E'
  scope: { 
    url: '='
    height: '@'
    width: '@'
    aspect: '@'
  }

  link: (scope, element, attrs) ->
    parent = {}
    container = {}
    image = {}
    image.url = {}
    scope.finalImageClass = "cs-image hide"

    width = scope.width
    height = scope.height
    aspect = scope.aspect
    # console.log width, height, aspect

    setContainerDimensions = ->
      parent = element.parent()
      parent.width = $(parent[0]).width()
      parent.height = $(parent[0]).height()
      parent.heightToWidth = parent.height/parent.width

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
          container.height = if (height == 'parent') then parent.height else height
          container.width = container.height / image.heightToWidth
        if ! height && width
          container.width =  if (width == 'parent') then parent.width else width
          container.height = container.width * image.heightToWidth
        if ! height && ! width
          container.width = parent.width
          container.height = container.height = container.width * image.heightToWidth
        if height && width
          container.width =  if (width == 'parent') then parent.width else width
          container.height = if (height == 'parent') then parent.height else height

      container.heightToWidth = container.height / container.width
      # console.log "PARENT HEIGHT: ", parent.height
      # console.log "PARENT WIDTH: ", parent.width
      # console.log "CONTAINER HEIGHT: ", container.height
      # console.log "CONTAINER WIDTH: ", container.width

    calculateImageDimensions = ->
      # console.log "Calculating Image Dimensions"
      # console.log 'Parent ratio: ', parent.heightToWidth
      # console.log 'Image ratio: ', image.heightToWidth
      if container.heightToWidth <= image.heightToWidth
        # console.log 'short and wide'
        image.finalWidth = container.width
        image.finalHeight = image.finalWidth*image.heightToWidth
      else
        # console.log 'tall and skinny'
        image.finalHeight = container.height
        image.finalWidth = image.finalHeight / image.heightToWidth
        # console.log "IMAGE FINAL WIDTH: ", image.finalWidth
        # console.log "IMAGE FINAL HEIGHT: ", image.finalHeight

    # Once everything is calculated, we can load the image and set some styling to center the viewable area
    loadImage = ->
      scope.finalUrl = csFilepickerMethods.convert(image.url, {w: image.finalWidth})
      scope.containerStyle = {
        "overflow": "hidden"
        "height": container.height
        "width": container.width
      }
      scope.imageStyle = {
        "max-width": image.finalWidth + "px"
        "width": image.finalWidth + "px"
        "margin-left": "-" + (image.finalWidth - container.width)/2 + "px"
        "margin-top": "-" + (image.finalHeight - container.height)/2 + "px"
      }

    loadTinyImage = ->
      scope.tinyImageSrc = csFilepickerMethods.convert(image.url, {w: 100})

    # 1. When the url is available, load the tiny image.  
    # TODO: Eventually we may want to store the base URL serverside along with image dimensions so we don't have to do this.
    # This change should increase performance and reduce the number of http requests
    scope.$watch 'url', (newValue, oldValue) ->
      if ! newValue?
        newValue = "https://d3awvtnmmsvyot.cloudfront.net/api/file/I6i4voprQ7ypbPQZLxIC"
      image.url = newValue
      loadTinyImage()

    # 3. When tiny image is loaded, calculate the final image dimensions & original image aspect ratio
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

@app.directive 'csTinyImage', [ ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'load', ->
      width = element[0].clientWidth
      height = element[0].clientHeight
      scope.$emit 'csTinyImageLoaded', {width: width, height: height}

]

@app.directive 'csFinalImageLoad', [ ->
  restrict: 'A'

  link: (scope, element, attrs) ->

    element.on 'load', ->
      scope.$emit 'csFinalImageLoaded'

]
