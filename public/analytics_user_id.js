(function(){
  var analyticsUserId = window.analyticsUserId = window.analyticsUserId || {};

  analyticsUserId.load = function(user_id) {
    if (user_id) {
      return ({chefstepsUserId: user_id});
    }
  }
})();
