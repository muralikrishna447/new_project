angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    # Not sure if this is completely reliable, but the idea is to make sure that a newly added
    # piece of equipment starts out in edit mode. This seems to work, but do we know each new one will get
    # link called just once?
    if scope.editMode
      scope.$emit('end_active_edits_from_below')
      scope.active = true


  # TODO: Move this to a partial file
  # Note the &nbsp; below is to keep the whole thing from being empty so that you can't get an edit-target on it
  template: '<csEditPair>'+
              '<csEditPairShow>' +
                '<div ng-switch="" on="!!item.equipment.product_url">' +
                  '<span ng-switch-when="true">' +
                    "<a ng-href='{{item.equipment.product_url}}' target='_blank'>{{item.equipment.title}}&nbsp;</a>" +
                  '</span>' +
                  '<span ng-switch-when="false">{{item.equipment.title}}&nbsp;</span>' +
                '</div>' +
              '</csEditPairShow>'+
              '<csEditPairEdit>' +
                '<input type="text" placeholder="New equipment" typeahead-editable="true" autofocus="autofocus" autocomplete="off" class="equipment-typeahead" ng-model="item.equipment" typeahead="e as e.title for e in all_equipment($viewValue)"/>' +
              '</csEditPairEdit>' +
            '</csEditPair>'
