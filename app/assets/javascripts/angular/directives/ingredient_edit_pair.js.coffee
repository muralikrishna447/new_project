# Originally this just used a ui bootstrap typeahead, but trying to have an autocomplete
# for the ingredient name in the middle of something like "20 g banana, diced" was becoming too
# problematic. So I compromised by reusing some of their internal components like typeahead-popup, but
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

    maybeCommitIngredient = ->
      console.log "Maybe Commit"

      ai = {unit: "a/n", display_quantity: "1", note: null, ingredient: {title: null}}

      s = window.ChefSteps.splitIngredient(input.val())
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
        scope.inputText = ''
        scope.$apply() if ! scope.$$phase

    element.on 'keydown', (event) ->
      if event.which == 13
        maybeCommitIngredient()
      true

    scope.$watch 'inputText', (val) ->
      scope.matches = []
      scope.activeIdx = -1

      if val.length > 0
        scope.matches = [{label: val}]
        scope.activeIdx = 0
        $q.when(scope.all_ingredients(val, scope.includeRecipes)).then (matches) ->
          scope.matches = _.extend(scope.matches, matches)
      true


  # <pre>{{matches | json}}</pre>

  template: '''
    <div class='new-ingredient-input'>
      <div typeahead-popup matches='matches' active='activeIdx'></div>
      <div class="btn btn-secondary btn-small include-recipes" ng-model="includeRecipes" btn-checkbox btn-checkbox-true="true" btn-checkbox-false="false" tooltip="Include sub-recipes in autocomplete" tooltip-placement="bottom")><i class="icon-filter"/></div>
      <input autocomplete="off" placeholder="Add ingredient, e.g. 20 g onion, minced" type="text" ng-model="inputText">
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
