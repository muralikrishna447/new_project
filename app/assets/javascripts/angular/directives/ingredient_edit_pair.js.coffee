# TODO some of this can be dried up wrt equipment_edit_pair
angular.module('ChefStepsApp').directive 'csinputmonkeyingredient', ->
  restrict: 'A',

  link: (scope, element, attrs) ->

    elt = $(element)
    start_val = ""

    elt.on 'focus', ->
      scope.normalizeModel()
      start_val = elt.val()

    # Throw out empties
    element.bind 'blur', ->
      scope.normalizeModel()
      if ! scope.hasIngredientTitle()
        scope.removeIngredient(scope.$parent.$index)
      else
        # any final cleanup if they typed too fast, or if [RECIPE] is left
        s = window.ChefSteps.splitIngredient(scope.ai.ingredient.title)
        scope.ai.ingredient.title = s.ingredient

    element.bind 'keyup', (event) ->
      s = window.ChefSteps.splitIngredient($(event.target).val())
      scope.ai.unit = s.unit if s.unit?
      # Holdover from sharing code with the old admin method
      s.quantity = 1 if s.quantity == -1
      scope.ai.display_quantity = s.quantity if s.quantity?
      scope.ai.unit = "recipe" if scope.ai.ingredient? && scope.ai.ingredient.sub_activity_id?
      return true

angular.module('ChefStepsApp').directive 'cslimitquantity', ->
  restrict: 'A',
  link: (scope, element, attrs) ->

    element.bind 'blur', (event) ->
      if scope.editMode
        scope.ai.display_quantity = window.roundSensible(scope.ai.display_quantity)
      return true

angular.module('ChefStepsApp').directive 'csingredienteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    if scope.editMode
      scope.active = true

    scope.hasIngredientTitle = ->
      scope.ai.ingredient? && scope.ai.ingredient.title? && (scope.ai.ingredient.title.length > 0)

    element.bind 'keydown', (event) ->
      if scope.editMode

        # On return (in input, not the popup), commit this ingredient and start a new one - iff
        # the ingredient is satisfactorily filled out
        if event.which == 13
          scope.normalizeModel()
          ai = scope.ai
          if scope.hasIngredientTitle() && ai.unit? && ((ai.display_quantity? ) || (ai.unit == "a/n"))
            scope.addIngredient()
            scope.$apply()
          return false

      return true

  templateUrl: '_ingredient_edit_pair.html'
