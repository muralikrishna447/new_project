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
      scope.activity.ingredients.splice(scope.activity.ingredients.indexOf(scope.ai ), 1) if ! scope.hasIngredientTitle()


angular.module('ChefStepsApp').directive 'csingredienteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    if scope.editMode
      scope.active = true

    scope.hasIngredientTitle = ->
      ai = scope.ai
      ! ((_.isString(ai.ingredient) && (ai.ingredient == "")) || (ai.ingredient.title == ""))

    element.bind 'keydown', (event) ->
      ai = scope.ai

      # On return (in input, not the popup), commit this ingredient and start a new one - iff
      # the ingredient is satisfactorily filled out
      if event.which == 13
        if scope.hasIngredientTitle() && ai.unit? && ((ai.display_quantity? ) || (ai.unit? == "a/n"))
          scope.addIngredient()
          scope.$apply()


  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.removeIngredient = ->
      $scope.activity.ingredients.splice($scope.activity.ingredients.indexOf($scope.ai), 1)
      $scope.addUndo()

  ]

  templateUrl: '/assets/angular/templates/_ingredient_edit_pair'
