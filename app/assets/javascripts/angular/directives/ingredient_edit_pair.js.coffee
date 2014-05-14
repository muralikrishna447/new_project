@app.directive 'csNewIngredient', [ "$timeout", ($timeout) ->
  restrict: 'A',

  link: (scope, element, attrs) ->

    ###################################################################
    #
    # NOTE THIS IS SOME CRAZY TOUCHY SHIZNITZ. BE VERY AFRAID.
    #
    ###################################################################
    scope.ai = {unit: "g", quantity: "0", note: null}

    scope.onSelect = (item, model, label) ->
      # Get the ingredient selection, and reset the input to 
      # what the user had originally typed (typeahead is going to trash it
      # with just the selected ingredient name)
      scope.ai.ingredient = window.deepCopy(item)
      console.log "Select"

      if ! scope.ai.note
        $timeout ->
          console.log "Select post timeout"
          $(element[0]).val("#{scope.ai.display_quantity} #{scope.ai.unit} #{scope.ai.ingredient.title}, ")
          # Note how this is used as a signaling mechanism that keydown
          # is allowed to commit the ingredient
          scope.ai.note = ""

      else
        commitIngredient()

    scope.hasIngredientTitle = ->
      scope.ai.ingredient? && scope.ai.ingredient.title? && (scope.ai.ingredient.title.length > 0)

    commitIngredient = ->
      console.log "Commit"
      # Double check title, in case it has [RECIPE] still in it, or a note
      if scope.hasIngredientTitle()
        s = window.ChefSteps.splitIngredient(scope.ai.ingredient.title, false)
        scope.ai.ingredient.title = s.ingredient

      scope.ai.unit = "recipe" if scope.ai.ingredient? && scope.ai.ingredient.sub_activity_id?

      if scope.hasIngredientTitle() && scope.ai.unit? && ((scope.ai.display_quantity? ) || (scope.ai.unit == "a/n"))
        scope.getIngredientsList().push(window.deepCopy(scope.ai))
        scope.ai = {unit: "g", quantity: "0", note: null}
        scope.$apply() if ! scope.$$phase

    element.on 'keyup', (event) ->
      console.log "Keyup #{JSON.stringify(scope.ai)}"
      # Gotta grab the unit & quantity on each key b/c on selection
      # it is too late to see the contents
      s = window.ChefSteps.splitIngredient($(event.target).val())
      scope.ai.unit = s.unit if s.unit?
      # Holdover from sharing code with the old admin method
      s.quantity = 1 if s.quantity == -1
      scope.ai.display_quantity = s.quantity if s.quantity?
      scope.ai.note = s.note if s.note?

    # This is handling the case where the user hasn't typed
    # a note, just pressed return, which won't trigger onSelect()
    element.on 'keydown', (event) ->
      if scope.ai.note == "" && event.which == 13
        commitIngredient()

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
