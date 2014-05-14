@app.directive 'csNewIngredient', [ "$timeout", ($timeout) ->
  restrict: 'A',

  link: (scope, element, attrs) ->

    maybeCommitIngredient = ->
      console.log "Maybe Commit"

      ai = {unit: "a/n", display_quantity: "1", note: null, ingredient: {title: null}}

      s = window.ChefSteps.splitIngredient($(element).val())
      ai.unit = s.unit if s.unit?
      # Holdover from sharing code with the old admin method
      s.quantity = 1 if s.quantity == -1
      ai.display_quantity = s.quantity if s.quantity?
      ai.display_quantity = null if ai.unit == "a/n"
      ai.note = s.note if s.note?
      ai.ingredient.title = s.ingredient if s.ingredient?
      ai.unit = "recipe" if ai.ingredient.sub_activity_id?

      if ai.ingredient.title && ai.unit? && ((ai.display_quantity? ) || (ai.unit == "a/n"))
        console.log "Commit!"
        scope.getIngredientsList().push(window.deepCopy(ai))
        $(element).val('')
        scope.$apply() if ! scope.$$phase

    element.on 'keydown', (event) ->
      if event.which == 13
        maybeCommitIngredient()

      return true   
]   
       
@app.directive 'cslimitquantity', ->
  restrict: 'A',
  link: (scope, element, attrs) ->

    element.bind 'blur', (event) ->
      if scope.editMode
        scope.ai.display_quantity = window.roundSensible(scope.ai.display_quantity)
      return true

@app.directive 'csingredienteditpair', [ "$rootScope", ($rootScope) ->
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
