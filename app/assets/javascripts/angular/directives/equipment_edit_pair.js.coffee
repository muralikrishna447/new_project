angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',
  scope: true,
  require: '^cseditrecord',

  link: (scope, element, attrs, recordControl) ->
    scope.addPair(scope)

  # TODO: Move this to a partial file
  template: '<csEditPair>'+
              '<csEditPairShow>' +
                '<div ng-switch="" on="!!item.equipment.product_url">' +
                  '<span ng-switch-when="true">' +
                    "<a ng-href='{{item.equipment.product_url}}' target='_blank'>{{item.equipment.title}}</a>" +
                  '</span>' +
                  '<span ng-switch-when="false">{{item.equipment.title}}</span>' +
                '</div>' +
              '</csEditPairShow>'+
              '<csEditPairEdit>' +
                'Coming Soon' +
              '</csEditPairEdit>' +
            '</csEditPair>'
