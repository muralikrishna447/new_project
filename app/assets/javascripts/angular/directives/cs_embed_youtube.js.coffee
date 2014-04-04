# TODO:
# Track video title and maybe containing object (i.e. activity) title?
# Set width, height, maybe other params from attrs
# Set up two-way binding for scope and change videos when the id changes
# Maybe track more events beside load and play

@app.directive 'csembedyoutube', [() ->
  restrict: 'E'
  scope: { }
  link: (scope, element, attrs) ->

    playerId = "YT" + Date.now()
    $(element).find('div').attr('id', playerId)

    mixpanelProperties =
      videoId: attrs.videoId
      containerSlug: attrs.containerSlug

    mixpanel.track('Video Embed Loaded', mixpanelProperties) 
 
    player = new YT.Player( 
      playerId,
      videoId: attrs.videoId
      width: '466'
      height: '263'
      playerVars: 
        'wmode': 'opaque'
        'modestbranding' : 1
        'autohide' : 1
        'rel': 0
        'showinfo': 0
        'autoplay': 0
      events:
        'onStateChange': (event) ->
          if event.data == 1
              mixpanel.track('Video Embed Played', mixpanelProperties) 
    )   

  template: '<div></div>'
]