angular.module('ChefStepsApp').directive 'csradiobuttons', ->
  restrict: 'E',
  scope: { active: "=", ngModel: "="},
  templateUrl: '/client_views/_cs_radio_buttons'
