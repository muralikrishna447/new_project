
var player, activityPlayer;
function onYouTubeIframeAPIReady() {
  player = new YT.Player('spherification-player', {
    events: {
      'onReady': onSpherificationPlayerReady,
      'onStateChange': onSpherificationPlayerStateChange,
    }
  });

  activityPlayer = new YT.Player('activityPlayer', {
    events: {
      'onStateChange': onActivityPlayerStateChange,
    }
  });
}

// The API will call this function when the video player is ready.
function onSpherificationPlayerReady(event) {
  event.target.playVideo();
}

// The API calls this function when the player's state changes.
function onSpherificationPlayerStateChange(event) {
  if (event.data == YT.PlayerState.ENDED) {
    console.log('ended');
    var timeNow = new Date().getTime();
    mixpanel.track("Video Ended", {"id": "spherification", "timeNow": timeNow});

    $(document).ready(function(){
      $('.course-end-action').addClass('course-end-action-show');

      $('.course-end-action-close').click(function(){
        $(this).closest('.course-end-action').removeClass('course-end-action-show');
      });
    });
  }
}

// For all activities
// The API calls this function when the player's state changes.
function onActivityPlayerStateChange(event) {
  if (event.data == YT.PlayerState.PLAYING) {
    mixpanel.track("Video Played", {"url": document.URL, "user": currentUserName});
    console.log('playing');
  }
}
