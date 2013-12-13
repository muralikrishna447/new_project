angular.module('ChefStepsApp').directive 'csradiobuttons', ->
  restrict: 'E',
  require: "^ngModel"
  scope: { choices: '=', output: '=ngModel'},
  templateUrl: '/client_views/_cs_radio_buttons'
