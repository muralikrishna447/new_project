# TODO:
# Track video title and maybe containing object (i.e. activity) title?
# Set width, height, maybe other params from attrs
# Set up two-way binding for scope and change videos when the id changes
# Maybe track more events beside load and play

@app.directive 'csembedyoutube', ["$timeout", ($timeout) ->
  restrict: 'E'
  scope: { autoplay: '=' }
  link: (scope, element, attrs) ->

    playerId = "YT" + Date.now()
    $(element).find('.video-iframe').attr('id', playerId)

    mixpanelProperties =
      videoId: attrs.videoId
      containerSlug: attrs.containerSlug

    mixpanel.track('Video Embed Loaded', mixpanelProperties) 
 
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
        'onStateChange': (event) ->
          if event.data == 1
              mixpanel.track('Video Embed Played', mixpanelProperties) 
    )   
    # Youtube player is clever enough to default a playback quality based on size
    # but not to adjust it when going fullscreen. So wait a little while for
    # csenforceaspect to do its thing, then bump it up.
    $timeout ( -> player.setPlaybackQuality?('hd1080')), 2000

    # # Dumb experimental workaround to having the correct onplayerready
    # loadVideo = (id) ->
    #   if player?.loadVideoById
    #     player.loadVideoById(id) if id.length > 0
    #   else $timeout (->
    #     loadVideo(id)
    #   ), 500

    # attrs.$observe 'videoId', (newVal) ->  
    #   loadVideo(newVal)

  template: """
    <div class='video-container' csenforceaspect>
      <div class='video-iframe'></div>
    </div>
  """
]