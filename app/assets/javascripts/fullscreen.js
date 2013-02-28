(function () {
  var viewFullScreen = document.getElementById("view-fullscreen");
  if (viewFullScreen) {
    viewFullScreen.addEventListener("click", function () {
      var docElm = document.documentElement;
      if (docElm.requestFullscreen) {
        docElm.requestFullscreen();
      }
      else if (docElm.mozRequestFullScreen) {
        docElm.mozRequestFullScreen();
      }
      else if (docElm.webkitRequestFullScreen) {
        docElm.webkitRequestFullScreen();
      }
    }, false);
  }
})();