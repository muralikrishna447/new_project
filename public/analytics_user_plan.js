(function(){
  var analyticsUserPlan = window.analyticsUserPlan = window.analyticsUserPlan || {};

  analyticsUserPlan.load = function(is_studio, is_premium) {
    if (is_studio) {
      return ({chefstepsUserPlan: 'studio'});
    } else if (is_premium) {
      return ({chefstepsUserPlan: 'premium'});
    } else {
      return ({chefstepsUserPlan: 'free'});
    }
  }
})();
