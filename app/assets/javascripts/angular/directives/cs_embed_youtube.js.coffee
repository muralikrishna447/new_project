# TODO:
# Track video title and maybe containing object (i.e. activity) title?
# Set width, height, maybe other params from attrs
# Set up two-way binding for scope and change videos when the id changes
# Maybe track more events beside load and play

@app.directive 'csembedyoutube', ["$timeout", ($timeout) ->
  restrict: 'E'
  scope: { autoplay: '=' }
  link: (scope, element, attrs) ->
    player = null
    playerId = "YT" + Date.now()
    $(element).find('.video-iframe').attr('id', playerId)

    mixpanelProperties =
      videoId: attrs.videoId
      containerSlug: attrs.containerSlug

    mixpanel.track('Video Embed Loaded', mixpanelProperties) 
 
    createPlayer = ->
      if window.youtubeAPIReady
        player = new YT.Player( 
          playerId,
          videoId: attrs.videoId
          playerVars: 
            'wmode': 'opaque'
            'modestbranding' : 1
            'autohide' : 1
            'rel': 0
            'showinfo': 0
            width: '1466'
            iv_load_policy: 3
            'autoplay': attrs.autoplay || 0

          events:
            # Youtube player is clever enough to default a playback quality based on size
            # but not to adjust it when going fullscreen.         
            'onReady' : (event) -> player.setPlaybackQuality?('hd1080') 
            'onStateChange': (event) ->
              if event.data == 1
                  mixpanel.track('Video Embed Played', mixpanelProperties) 
        )
      else
        # If the YT api isn't ready yet, try again a little later
        $timeout (-> createPlayer()), 500

    createPlayer() 

    scope.$on 'playVideo', (event, play) ->
      if play
        player?.playVideo()
      else
        player?.pauseVideo()

    attrs.$observe 'videoId', ->
      player?.loadVideoById?(attrs.videoId, 0, 'hd1080')

  template: """
    <div class='video-container' csenforceaspect>
      <div class='video-iframe'></div>
    </div>
  """
]