@app.directive 'csCoverImage', ['$window', '$http', ($window, $http) ->
  restrict: 'A'
  scope: { csCoverImage: '='}

  # link: (scope, element, attrs) ->
  #   baseURL = null
  #   width = 0
  #   scope.coverImageStyle = {}
  #   placeHolderImageStyle = {}
  #   scope.imageLoaded = false
    
  #   getWidth = ->
  #     element[0].clientWidth

  #   getParentHeight = ->
  #     element.parent()[0].clientHeight

  #   updateSource = (apply) ->
  #     scope.imageLoaded = true
  #     apply ?= null
  #     width = getWidth()
  #     height = getParentHeight()
  #     if baseURL
  #       imageURL = window.cdnURL(baseURL) + "/convert?w=#{width}&cache=true"
  #       console.log imageURL
  #       scope.coverImageStyle = {
  #         "background": "url('" + imageURL + "/convert?w=#{width}&cache=true') no-repeat center center fixed"
  #         "height": height
  #       }
  #       if apply
  #         scope.$apply()

  #   insertPlaceholder = ->
  #     console.log 'Inserting Placeholder'
  #     height = getParentHeight()
  #     scope.placeHolderImageStyle = {
  #       "background" : "gray"
  #       "height" : height
  #     }

  #   scope.$watch 'csCoverImage', (newVal, oldVal) -> 
  #     if newVal
  #       baseURL = JSON.parse(newVal).url
  #       updateSource()
  #     else
  #       insertPlaceholder()

  #   angular.element($window).bind 'resize', ->
  #     _.throttle(updateSource(true))

  link: (scope, element, attrs) ->
    scope.baseURL = {}
    scope.coverImageStyle = {}
    scope.placeHolderImageStyle = {}
    scope.imageLoaded = true
    width = 0
    height = 0

    getBaseURL = (fpfile) ->
      scope.baseURL = JSON.parse(fpfile).url

    getParentDimensions = ->
      parent = element.parent()
      width = element[0].clientWidth
      height = parent[0].clientHeight

    getSourceImageDimensions = ->
      url = scope.baseURL + "/metadata?width=true&height=true"
      $http.get(url, {headers: {'X-Requested-With': undefined}}).then (response) ->
        console.log response.data
      # $http.get(url).then (response) ->
      #   console.log response.data

    loadImage = ->
      imageURL = window.cdnURL(scope.baseURL) + "/convert?w=#{width}&cache=true"
      scope.coverImageStyle = {
        "background": "url('" + imageURL + "') no-repeat center center fixed"
        "height": height
      }

    scope.$watch 'csCoverImage', (newValue, oldValue) ->
      if newValue
        getBaseURL(newValue)
        getParentDimensions()
        getSourceImageDimensions()
        loadImage()

  template: """
    <div ng-show="imageLoaded" ng-style="coverImageStyle">
    </div>
    <div ng-show="! imageLoaded" ng-style="placeHolderImageStyle">
    </div>
  """

]


## Run updateSource() only when resizing is done
# rtime = new Date
# timeout = false
# delta = 200

# resizeend = ->
#   if new Date() - rtime < delta
#     setTimeout resizeend, delta
#   else
#     timeout = false
#     updateSource()
#     scope.$apply()
#   return

# angular.element($window).bind 'resize', ->
#   rtime = new Date()
#   if timeout is false
#     timeout = true
#     setTimeout resizeend(), delta
#   return