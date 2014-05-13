angular.module('ChefStepsApp').directive 'csNewIngredient', ->
  restrict: 'A',

  link: (scope, element, attrs) ->

    scope.ai = {unit: "g", quantity: "0"}

    scope.hasIngredientTitle = ->
      scope.ai.ingredient? && scope.ai.ingredient.title? && (scope.ai.ingredient.title.length > 0)

    commitIngredient = ->
      # any final cleanup if they typed too fast, or if [RECIPE] is left
      s = window.ChefSteps.splitIngredient(scope.ai.ingredient.title, false)
      scope.ai.ingredient = {title: s.ingredient}

      if scope.hasIngredientTitle() && scope.ai.unit? && ((scope.ai.display_quantity? ) || (scope.ai.unit == "a/n"))
        scope.getIngredientsList().push(window.deepCopy(scope.ai))
        scope.ai = {unit: "g", quantity: "0"}

    element.bind 'blur', ->
      commitIngredient()

    element.bind 'keydown', (event) ->
      if event.which == 13
        commitIngredient()
        return false

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

angular.module('ChefStepsApp').directive 'csingredienteditpair', [ "$rootScope", ($rootScope) ->
  restrict: 'E',

  link: (scope, element, attrs) ->

    element.bind 'keydown', (event) ->
      if scope.editMode

        if event.which == 13
          scope.normalizeModel()
          ai = scope.ai
          return false

      return true

  templateUrl: '_ingredient_edit_pair.html'
]
