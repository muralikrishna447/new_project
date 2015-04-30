@app.directive 'csembedvimeo', ["$timeout", ($timeout) ->
  restrict: 'E'
  scope: { autoplay: '=', videoId: "@" }
  link: (scope, element, attrs) ->

    scope.playerId = "VIMEO" + Date.now()
    iframe = $(element).find('.video-iframe iframe')[0]
    $(iframe).attr('id', scope.playerId)
    player = $f(iframe)

    mixpanelProperties =
      host: 'vimeo'
      videoId: attrs.videoId
      containerSlug: attrs.containerSlug

    mixpanel.track('Video Embed Loaded', mixpanelProperties)

    scope.$on 'playVideo', (event, play) ->
      console.log("playVideo: #{play}")
      player.api(if play then 'play' else 'pause')

    player.addEvent 'ready', ->
      player.addEvent 'play', ->
        mixpanel.track('Video Embed Played', mixpanelProperties)

  template: """
    <div class="video-iframe-container">
      <div class='video-iframe embed-container'>
        <iframe cssrcreplacer="{{'//player.vimeo.com/video/' + videoId + '?api=1&autopause=true&badge=0&byline=0&color=e25f25&portrait=0&title=0&player_id=' + playerId}}" width="1466" height="825" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
      </div>
    </div>
  """
]