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
    <div class="video-iframe-container">
      <div class='video-iframe embed-container'>
        <iframe cssrcreplacer="{{'//player.vimeo.com/video/' + videoId + '?autopause=true&badge=0&byline=0&color=e25f25&portrait=0&title=0'}}" width="1466" height="825" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </div>
    </div>
  """
]