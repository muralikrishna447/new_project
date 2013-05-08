angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',

  controller: ['$scope', ($scope) ->
    # Workaround a bug or limitation of the angular typeahead adapter - when bound to a model
    # but allowing typeahead-editable, when entering a name that doesn't exist, it returns a naked string
    # instead of a model object
    $scope.$watch "item.equipment", ->
      if _.isString($scope.item.equipment)
        $scope.item.equipment = {title: $scope.item.equipment}
  ]


    # TODO: Move this to a partial file
  template: '<csEditPair>'+
              '<csEditPairShow>' +
                '<div ng-switch="" on="!!item.equipment.product_url">' +
                  '<span ng-switch-when="true">' +
                    "<a ng-href='{{item.equipment.product_url}}' target='_blank'>{{item.equipment.title}}</a>" +
                  '</span>' +
                  '<span ng-switch-when="false">{{item.equipment.title}}</span>' +
                  '&nbsp;' +
                '</div>' +
              '</csEditPairShow>'+
              '<csEditPairEdit>' +
                '<input type="text" placeholder="New equipment" typeahead-editable="true" autofocus="autofocus" autocomplete="off" class="equipment-typeahead" ng-model="item.equipment" typeahead="e as e.title for e in all_equipment | filter:{title: $viewValue}"/>' +
                '<p>{{item | json}}</p>' +
              '</csEditPairEdit>' +
            '</csEditPair>'
