angular.module('ChefStepsApp').directive "csscalingeditable",  ->
  restrict: 'A',
  link: (scope, element, attrs) ->
    window.makeEditable(element)

