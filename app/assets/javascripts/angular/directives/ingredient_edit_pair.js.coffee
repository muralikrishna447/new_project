angular.module('ChefStepsApp').directive 'csNewIngredient', ->
  restrict: 'A',

  link: (scope, element, attrs) ->

    scope.ai = {unit: "g", quantity: "0"}

    scope.formatInput = ($model) ->
      "#{scope.ai.quantity} #{scope.ai.unit} #{scope.ai.ingredient.title}"

    scope.hasIngredientTitle = ->
      scope.ai.ingredient? && scope.ai.ingredient.title? && (scope.ai.ingredient.title.length > 0)

    commitIngredient = ->
      # Double check title, in case it has [RECIPE] still in it, or a note
      if scope.hasIngredientTitle()
        s = window.ChefSteps.splitIngredient(scope.ai.ingredient.title, false)
        scope.ai.ingredient = {title: s.ingredient}

      if scope.hasIngredientTitle() && scope.ai.unit? && ((scope.ai.display_quantity? ) || (scope.ai.unit == "a/n"))
        scope.getIngredientsList().push(window.deepCopy(scope.ai))
        scope.ai = {unit: "g", quantity: "0"}

    element.bind 'blur', ->
      commitIngredient()

    element.on 'keydown', (event) ->
      if event.target == element[0] && event.which == 13
        commitIngredient()
        return true

      s = window.ChefSteps.splitIngredient($(event.target).val())
      scope.ai.unit = s.unit if s.unit?
      scope.ai.unit = "recipe" if scope.ai.ingredient? && scope.ai.ingredient.sub_activity_id?
      # Holdover from sharing code with the old admin method
      s.quantity = 1 if s.quantity == -1
      scope.ai.display_quantity = s.quantity if s.quantity?
      console.log scope.ai

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
