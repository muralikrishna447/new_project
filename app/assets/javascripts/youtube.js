
var player;
function onYouTubeIframeAPIReady() {
  player = new YT.Player('spherification-player', {
    events: {
      'onReady': onSpherificationPlayerReady,
      'onStateChange': onSpherificationPlayerStateChange
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
    $(document).ready(function(){
      $('.course-end-action').addClass('course-end-action-show');

      $('.course-end-action-close').click(function(){
        $(this).closest('.course-end-action').removeClass('course-end-action-show');
      });
    });
  }
}