@app.directive 'csCoverImage', ['$window', '$http', ($window, $http) ->
  restrict: 'A'
  scope: { csCoverImage: '='}

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
        "background-position": "top center"
        "background-size": "cover"
        "height": parent.height
      }

    scope.$watch 'csCoverImage', (newValue, oldValue) ->
      if newValue
        getBaseURL(newValue)
        getParentDimensions()
        getSourceImageDimensions()

    angular.element($window).bind 'resize', ->
      _.throttle(
        console.log 'throttleeedd'
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