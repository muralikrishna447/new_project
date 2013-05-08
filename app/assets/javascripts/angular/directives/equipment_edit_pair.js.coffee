angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',
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
                  '--<b>{{item.equipment}}</b>' +
                '</div>' +
              '</csEditPairShow>'+
              '<csEditPairEdit>' +
                '<input type="text" placeholder="New equipment" typeahead-editable="true" autofocus="autofocus" autocomplete="off" class="equipment-typeahead" ng-model="item.equipment" typeahead="e as e.title for e in all_equipment | filter:{title: $viewValue}"/>' +
                '{{item.equipment}}' +
              '</csEditPairEdit>' +
            '</csEditPair>'
