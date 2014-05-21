angular.module('ChefStepsApp').directive 'csinputmonkeyequipment', ->
  restrict: 'A',
  link: (scope, element, attrs) ->

    elt = $(element)
    start_val = ""

    elt.on 'focus', ->
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

    if scope.editMode
      scope.active = true

    scope.csoptional = attrs.csoptional

  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.removeItem = ->
      $scope.activity.equipment.splice($scope.activity.equipment.indexOf($scope.item), 1)
  ]

  templateUrl: '_equipment_edit_pair.html'
