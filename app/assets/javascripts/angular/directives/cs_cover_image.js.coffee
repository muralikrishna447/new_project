@app.directive 'csCoverImage', ['$window', ($window) ->
  restrict: 'A'
  scope: { csCoverImage: '='}

  link: (scope, element, attrs) ->
    baseURL = null
    width = 0
    scope.coverImageStyle = {}
    
    getWidth = ->
      element[0].clientWidth

    getParentHeight = ->
      element.parent()[0].clientHeight

    updateSource = (apply) ->
      apply ?= null
      width = getWidth()
      height = getParentHeight()
      if baseURL
        imageURL = window.cdnURL(baseURL) + "/convert?w=#{width}&cache=true"
        console.log imageURL
        scope.coverImageStyle = {
          "background": "url('" + imageURL + "/convert?w=#{width}&cache=true') no-repeat center center fixed"
          "height": height
        }
        if apply
          scope.$apply()
      # width = getWidth()
      # if baseURL
      #   attrs.$set('src', window.cdnURL(baseURL) + "/convert?w=#{width}&cache=true")
      # else
      #   attrs.$set('src', null)

    # console.log getWidth()

    scope.$watch 'csCoverImage', (newVal, oldVal) -> 

      baseURL = if newVal then JSON.parse(newVal).url else null
      updateSource()

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

    angular.element($window).bind 'resize', ->
      _.throttle(updateSource(true))

  template: """
    <div ng-style="coverImageStyle">
    <div>
  """

]