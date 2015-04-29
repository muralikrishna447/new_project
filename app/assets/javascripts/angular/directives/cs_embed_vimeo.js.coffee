@app.directive 'csembedvimeo', ["$timeout", "$window", ($timeout, $window) ->
  restrict: 'E'
  scope: { autoplay: '=', videoId: "@" }
  link: (scope, element, attrs) ->

    mixpanelProperties =
      host: 'vimeo'
      videoId: attrs.videoId
      containerSlug: attrs.containerSlug

    mixpanel.track('Video Embed Loaded', mixpanelProperties)

  template: """
    <iframe cssrcreplacer="{{'//player.vimeo.com/video/' + videoId}}" width="1466" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>

  """
]