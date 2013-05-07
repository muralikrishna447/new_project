angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',
  scope: true,

  link: (scope, element, attrs, groupControl) ->
    scope.addPair(scope)

  controller: ['$scope', '$element', ($scope, $element) ->

  ]

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
