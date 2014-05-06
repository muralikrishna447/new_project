var InternalConfig;

InternalConfig = window.parent['BloomInternalConfiguration'];
this.app = angular.module('frame', ['bloom.comments']);

this.app.constant('BloomAPIUrl', 'http://production-bloom.herokuapp.com');

this.app.constant('BloomAPIKey', 'xchefsteps');

this.app.constant('BloomData', InternalConfig.bloomData);

this.app.service('BloomSettings', function($q) {
  this.id = window.location.hash.split('id=')[1];
  this.loggedIn = !(InternalConfig.user === null);
  this.user = InternalConfig.user;
  this.apiKey = InternalConfig.apiKey;
  this.getUser = (function(_this) {
    return function(id) {
      var def;
      def = $q.defer();
      window.parent["BloomComments" + _this.id].getUsers([id]).then(function(users) {
        return def.resolve(users[0]);
      });
      return def.promise;
    };
  })(this);
  return this;
});

this.app.controller('MainCtrl', function($rootScope) {
  this.id = window.location.hash.split('id=')[1];
  $rootScope.$on('bloomClientLogin', function() {
    return InternalConfig.on.login();
  });
  return this;
});
