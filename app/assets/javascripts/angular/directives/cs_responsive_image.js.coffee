# Works with ink filepicker to retrieve an image that is server-side resized to the same width
# as the div containing the img to minimize network usage. If the parent div gets larger, a new image is retrieved.
# If it gets smaller, no new image is retrieved b/c it can just be client-side resized.
#
# Usage: <img cs-responsive-image="someobj.filepicker_file" [other attributes]>
#

@app.directive 'csResponsiveImage', [() ->
  restrict: 'A'
  scope: { csResponsiveImage: '='}

  link: (scope, element, attrs) ->

    baseURL = null
    width = 0

    getWidth = ->
      $(element).parent().width()

    updateSource = ->
      width = getWidth()
      if window.devicePixelRatio >= 2
        width = 2*width
      if baseURL
        attrs.$set('src', window.cdnURL(baseURL) + "/convert?w=#{width}&quality=90&cache=true")
      else
        attrs.$set('src', null)
      # console.log("Loading: ", attrs['src'])

    scope.$watch 'csResponsiveImage', (newVal, oldVal) ->

      baseURL = if newVal then JSON.parse(newVal).url else null
      updateSource()

    # The max here is what keeps us from reloading if the parent div gets smaller
    scope.$watch (-> Math.max(width, getWidth())), _.throttle(updateSource, 250)
]
