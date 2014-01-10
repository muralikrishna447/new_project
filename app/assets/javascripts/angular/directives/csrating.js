// This is copied out of ui-bootstrap so I can support half stars

angular.module('ChefStepsApp')

.constant('ratingConfig', {
  max: 5
})

.directive('csrating', ['ratingConfig', '$parse', function(ratingConfig, $parse) {
  return {
    restrict: 'EA',
    scope: {
      value: '='
    },
    templateUrl: 'template/csrating/csrating.html',
    replace: true,
    link: function(scope, element, attrs) {

      var maxRange = angular.isDefined(attrs.max) ? scope.$eval(attrs.max) : ratingConfig.max;

      scope.range = [];
      for (var i = 1; i <= maxRange; i++) {
          scope.range.push(i);
      }

      scope.rate = function(value) {
          if ( ! scope.readonly ) {
              scope.value = value;
          }
      };

      scope.enter = function(value) {
          if ( ! scope.readonly ) {
              scope.val = value;
          }
      };

      scope.reset = function() {
          scope.val = angular.copy(scope.value);
      };
      scope.reset();

      scope.$watch('value', function(value) {
          scope.val = value;
      });

      scope.readonly = false;
      if (attrs.readonly) {
          scope.$parent.$watch($parse(attrs.readonly), function(value) {
              scope.readonly = !!value;
          });
      }

      scope.getIcon = function(number, val) {
        if (number <= val) {
          return 'icon-star';
        }
        if ((number - 0.5) <= val) {
          return 'icon-star-half-empty';
        }
        return 'icon-star-empty';
      }
    }
  };
}]);