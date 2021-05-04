(function(){
  var analyticsUserPlan = window.analyticsUserPlan = window.analyticsUserPlan || {};

  analyticsUserPlan.load = function(loggedIn, isStudio, isPremium) {
    if (loggedIn) {
      if (isStudio) {
        return ({chefstepsUserPlan: 'studio'});
      } else if (isPremium) {
        return ({chefstepsUserPlan: 'premium'});
      } else {
        return ({chefstepsUserPlan: 'free'});
      }
    }
  }
})();
