angular.module('ChefStepsApp').directive 'csinputmonkey', ->
  restrict: 'A',
  link: (scope, element, attrs) ->

    elt = $(element)
    start_val = ""

    # Hack for the empty state we get when first creating
    elt.on 'focus', ->
      if elt.val() == "[object Object]"
        elt.val("")
      start_val = elt.val()

    # Throw out empties
    element.bind 'blur', ->
      item = scope.item
      if (_.isString(item.equipment) && (item.equipment == "")) || (item.equipment.title == "")
        scope.activity.equipment.splice(scope.activity.equipment.indexOf(item), 1)

    element.bind 'keydown', (event) ->
      item = scope.item

      # On return (in input, not the popup), commit this equipment and start a new one
      if event.which == 13 && elt.val().length > 0
        scope.$emit('end_active_edits_from_below')
        scope.addEquipment(scope.csoptional == "true")
        scope.$apply()

      # On escape, cancel this edit.
      # TODO: got this to work well for deleting ones that start blank, but not reverting changes to an existing equip
      # I had tried setting value back to start_val, and/or resetting model but always got overwritten.
      if event.which == 27
        if (start_val == "")
          scope.activity.equipment.splice(scope.activity.equipment.indexOf(item), 1)
        scope.$apply()


angular.module('ChefStepsApp').directive 'csequipmenteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    # Not sure if this is completely reliable, but the idea is to make sure that a newly added
    # piece of equipment starts out in edit mode. This seems to work, but do we know each new one will get
    # link called just once?
    if scope.editMode
      scope.$emit('end_active_edits_from_below')
      scope.active = true

    scope.csoptional = attrs.csoptional

  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.removeItem = ->
      $scope.activity.equipment.splice($scope.activity.equipment.indexOf($scope.item), 1)

    $scope.equipmentBulletStyle = ->
      "no-bullet" if $element.find('.edit-target').is(":visible")
  ]


  # TODO: Move this to a partial file
  # Note the &nbsp; below is to keep the whole thing from being empty so that you can't get an edit-target on it
  template: '<csEditPair>'+
              '<csEditPairShow>' +
                '<div ng-switch="" on="!!item.equipment.product_url">' +
                  '<span class="drag-handle" ng-show="editOffered"><i class="icon-sort"></i></span>' +
                  '<span ng-switch-when="true">' +
                    "<a ng-href='{{item.equipment.product_url}}' target='_blank'>{{item.equipment.title || item.equipment}}&nbsp;</a>" +
                  '</span>' +
                  '<span ng-switch-when="false">{{item.equipment.title || item.equipment}}&nbsp;</span>' +
                '</div>' +
              '</csEditPairShow>'+
              '<csEditPairEdit>' +
                '<input csinputmonkey="" type="text" placeholder="New equipment" typeahead-editable="true" autofocus="autofocus" autocomplete="off" class="equipment-typeahead" ng-model="item.equipment" typeahead="e as e.title for e in all_equipment($viewValue)"/>' +
                '<div class="remove-button" ng-click="removeItem()"><i class="icon-remove"></i></div>' +
              '</csEditPairEdit>' +
            '</csEditPair>'
