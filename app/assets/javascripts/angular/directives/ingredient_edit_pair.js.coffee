# TODO some of this can be dried up wrt ingredient_edit_pair
angular.module('ChefStepsApp').directive 'csinputmonkeyingredient', ->
  restrict: 'A',
  link: (scope, element, attrs) ->

    elt = $(element)
    start_val = ""

    elt.on 'focus', ->
      start_val = elt.val()

    # Throw out empties
    element.bind 'blur', ->
      ai = scope.ai
      if (_.isString(ai.ingredient) && (ai.ingredient == "")) || (ai.ingredient.title == "")
        scope.activity.ingredient.splice(scope.activity.ingredient.indexOf(ai), 1)

    element.bind 'keydown', (event) ->
      ai = scope.ai

      # On return (in input, not the popup), commit this ingredient and start a new one
      if event.which == 13 && elt.val().length > 0
        scope.$emit('end_active_edits_from_below')
        scope.addIngredient()
        scope.$apply()

      # On escape, cancel this edit.
      # TODO: got this to work well for deleting ones that start blank, but not reverting changes to an existing ingredient
      # I had tried setting value back to start_val, and/or resetting model but always got overwritten.
      if event.which == 27
        if (start_val == "")
          scope.activity.ingredients.splice(scope.activity.ingredients.indexOf(ai), 1)
        scope.$apply()


angular.module('ChefStepsApp').directive 'csingredienteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    if scope.editMode
      scope.active = true

  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.removeIngredient = ->
      $scope.activity.ingredients.splice($scope.activity.ingredients.indexOf($scope.ai), 1)
      $scope.addUndo()

  ]

  templateUrl: '/assets/angular/templates/_ingredient_edit_pair'
