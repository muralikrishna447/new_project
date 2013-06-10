# TODO some of this can be dried up wrt ingredient_edit_pair
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


angular.module('ChefStepsApp').directive 'csingredienteditpair', ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    if scope.editMode
      scope.active = true

    scope.hasIngredientTitle = ->
      scope.ai.ingredient? && scope.ai.ingredient.title? && (scope.ai.ingredient.title.length > 0)

    element.bind 'keydown', (event) ->
      if scope.editMode
        scope.normalizeModel()

        ai = scope.ai

        # On return (in input, not the popup), commit this ingredient and start a new one - iff
        # the ingredient is satisfactorily filled out
        if event.which == 13
          if scope.hasIngredientTitle() && ai.unit? && ((ai.display_quantity? ) || (ai.unit? == "a/n"))
            scope.addIngredient()
            scope.$apply()
          return false

      return true

    element.bind 'xkeyup', (event) ->
      s = window.ChefSteps.splitIngredient($(event.target).val())
      console.log($(event.target).val())
      scope.ai.unit = s.unit if s.unit?
      scope.ai.display_quantity = s.quantity if s.quantity?
      return true

  templateUrl: '/client_views/_ingredient_edit_pair'
