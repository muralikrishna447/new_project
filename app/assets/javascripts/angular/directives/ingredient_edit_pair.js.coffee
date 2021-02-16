# Originally this just used a ui bootstrap typeahead, but trying to have an autocomplete
# for the ingredient name in the middle of something like "20 g banana, diced" was becoming too
# problematic. So I compromised by reusing some of their internal components like typeahead-popup, butgoop
# managing all of the input myself.

@app.directive 'csNewIngredient', [ "$timeout", "$q", ($timeout, $q) ->
  restrict: 'A',

  link: (scope, element, attrs) ->
    scope.includeRecipes = false
    scope.loading = false
    scope.inputText = ""
    scope.matches = []
    scope.activeIdx = -1

    input = $(element).find('input')

    resetMatches = ->
      scope.matches = []
      scope.activeIdx = -1

    currentAI = ->
      ai = {unit: "a/n", display_quantity: "1", note: "", ingredient: {title: ""}}

      s = window.ChefSteps.splitIngredient(scope.inputText)
      ai.unit = s.unit if s.unit?
      # Holdover from sharing code with the old admin method
      s.quantity = 1 if s.quantity == -1
      ai.display_quantity = s.quantity if s.quantity?
      ai.display_quantity = null if ai.unit == "a/n"
      ai.note = s.note if s.note?
      ai.ingredient.title = s.ingredient if s.ingredient?
      ai.unit = "recipe" if ai.ingredient.sub_activity_id?

      ai

    maybeCommitIngredient = ->
      console.log "Maybe Commit"

      ai = currentAI()

      if ai.ingredient.title && ai.unit? && ((ai.display_quantity? ) || (ai.unit == "a/n"))
        console.log "Commit!"
        scope.getIngredientsList().push(window.deepCopy(ai))
        scope.inputText = ''
        resetMatches()

    scope.select = (idx) ->
      ai = currentAI()
      ai.ingredient.title = scope.matches[idx].title
      if scope.matches[idx].sub_activity_id
        ai.unit = 'recipe' 
        ai.display_quantity = '1'
      scope.inputText = "#{ai.display_quantity || ''} #{ai.unit} #{ai.ingredient.title}, #{ai.note}"
      input.focus()

    element.on 'keydown', (event) ->
      if event.which == 13 || event.which == 9
        if (scope.activeIdx == 0) || (scope.matches.length == 0)
          maybeCommitIngredient()
        else
          scope.select(scope.activeIdx)

      else if event.which is 40
        scope.activeIdx = (scope.activeIdx + 1) % scope.matches.length

      else if event.which is 38
        scope.activeIdx = ((if scope.activeIdx then scope.activeIdx else scope.matches.length)) - 1

      else if event.which is 27
        event.stopPropagation()
        resetMatches()

      scope.$digest()      
      true

    scope.$watch 'inputText', (val) ->
      if (val.length == 0) || (val.indexOf(',') >= 0)
        resetMatches()
      else 
        scope.matches[0] = {title: window.ChefSteps.splitIngredient(val).ingredient}
        scope.activeIdx = 0
        $q.when(scope.all_ingredients(val, scope.includeRecipes)).then (matches) ->
          # Ignore any queries that come back late after the query no longer matches the control
          if val == scope.inputText
            # all_ingredients returns the original, so skip it
            scope.matches[1..] = matches[1..]

      true


  # <pre>{{matches | json}}</pre>

  template: '''
    <div class='new-ingredient-input'>
      <div typeahead-popup matches='matches' active='activeIdx' select='select(activeIdx)'></div>
      <div class="btn btn-secondary btn-small include-recipes" ng-model="$parent.includeRecipes" btn-checkbox btn-checkbox-true="true" btn-checkbox-false="false" tooltip="Include sub-recipes in autocomplete" tooltip-placement="bottom")><span class="icon-filter"/></div>
      <input autocomplete="off" placeholder="Add ingredient, e.g. 20 g onion, minced" type="text" ng-model="inputText" aria-label="Add ingredient">
    </div>
  '''
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
