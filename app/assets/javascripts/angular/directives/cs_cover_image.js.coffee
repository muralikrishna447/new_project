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

    getBaseURL = (fpfile) ->
      scope.baseURL = JSON.parse(fpfile).url

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
        csFilepickerMethods.fitURL(newValue)
        getBaseURL(newValue)
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