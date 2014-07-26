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

@app.directive 'csTest', ['$window', '$timeout', '$q', ($window, $timeout, $q) ->
  restrict: 'E'
  scope: { 
    imageSrc: '@'
  }

  link: (scope, element, attrs) ->

    getParentDimensions = ->
      parent = element.parent()
      parent.width = parent[0].clientWidth
      parent.height = parent[0].clientHeight
      console.log "Parent Width: ", parent.width
      console.log "Parent Height: ", parent.height
      console.log "Parent: ", parent

    getImageDimensions = ->
      scope.image = element.find('img')
      scope.image.width = scope.image[0].clientWidth
      scope.image.height = scope.image[0].clientHeight
      console.log "Image Width: ", scope.image.width
      console.log "Image Height: ", scope.image.height
      console.log "Image: ", scope.image

    loadImage = ->
      getParentDimensions()
      getImageDimensions()

    # scope.$watch 'imageSrc', (newValue, oldValue) ->
    #   if newValue
    #     loadImage()

    angular.element($window).bind 'resize', ->
        loadImage()

    scope.$on 'csTestLoaded', ->
      loadImage()

  template: """
    <img ng-src={{imageSrc}} cs-test-loaded>
  """

]

@app.directive 'csTestLoaded', ['$window', '$timeout', '$q', ($window, $timeout, $q) ->
  restrict: 'A'

  link: (scope, element, attrs) ->
    element.on 'load', ->
      scope.$emit 'csTestLoaded'

]
