closeEditorWarning = () ->
  "Make sure you press 'Update Recipe' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $('input').keyup ->
      window.onbeforeunload = closeEditorWarning

$ ->
  $('tr').not('.template-row').find('select.unit').select2()

  $(document).on('click', 'button', ( ->
    $('tr').not('.template-row').find('select.unit').select2()
  ));

formatIngredient = (item) ->
  if item.id < 0
    return item.title + " <b>[RECIPE]</b>"
  else
    return item.title

splitIngredient = (term) ->
  # a/n Tofu Eyeballs [or an Tofu Eyeballs]
  if s = term.match(/(an|a\/n)+\s*(.*)/)
    return {"unit": "a/n", "ingredient": s[2]}

  # 10 g Tofu Eyeballs (or kg, ea, each, r, recipe)
  if s = term.match(/([\d]+)\s+(g|kg|ea|each|r|recipe)+\s+(.*)/)
    quantity = s[1]
    unit = if s[2] then s[2] else "g"
    unit = "ea" if unit == "each"
    unit = "a/n" if unit == "an"
    unit = "recipe" if unit == "r"
    ingredient = s[3]
    return {"quantity": quantity, "unit": unit, "ingredient": ingredient}

  # None of the above, assumed to be a nekkid ingredient
  return {"ingredient" : term}


matchIngredient = (term, text, options) ->
  return text.toUpperCase().indexOf(splitIngredient(term)["ingredient"].toUpperCase()) >= 0;

capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

createSearchChoice = (term, cell) ->
  s = splitIngredient(term)
  row = $(cell).parents("tr")
  row.find(".quantity").val(s["quantity"]) if s["quantity"]
  row.find(".unit").val(s["unit"]).trigger("change") if s["unit"]
  return {id: new Date().getTime(), title: capitalizeFirstLetter(s["ingredient"])}

setupIngredientSelect = () ->
  allingredients = $('#allingredients').data('allingredients')

  # Convert new rows that get added into select2, but don't double convert old ones
  $('tr').not('.template-row').find('input.ingredient').not(".converted").each (index, cell) =>
    $(cell).select2(
      {
        placeholder:        "Ingredient or Sub-Recipe"
        data:               { results: allingredients, text: "title" }
        createSearchChoice: (term) -> createSearchChoice(term, $(cell))
        initSelection:      (element, callback) -> callback({id: element.data("ingredient-id"), title: element.val()})
        formatSelection:    formatIngredient
        formatResult:       formatIngredient
        matcher:            matchIngredient
        escapeMarkup:       (x) -> return x
      }

    ).addClass("converted").on 'change', (event) ->
      # Make the hidden input value equal to the ingredient title b/c that is
      # what the receiving controller is expecting
      inp = $(event.target)
      inp.val(inp.select2('data')["title"])

      # For recipes, make sure the quantity is set to "recipe"
      id = inp.select2('data')["id"]
      if id < 0
        $(this).parents("tr").find(".unit").val("recipe").trigger("change")
        qty = $(this).parents("tr").find(".quantity")
        qty.val("1") if ! qty.val()

      # If we just filled in the last row, add a new row
      if ($(this).parents("tr").is(":last-child"))
        $('html, body').scrollTop($('#copy-ingredient-button').offset().top)
        $('#copy-ingredient-button button').click()
        $(this).parents("tbody").find("tr:last-child .ingredient").select2("open")

      return true


$ ->
  setupIngredientSelect()
  $(document).on('click', 'button', ( -> setupIngredientSelect()));

$ ->
  $('.multi-ingredients').select2(
    {
      closeOnSelect: false,
      placeholder: "Select from recipe ingredients"
    }
  )

$ ->
  $('.multi-ingredients').on 'close', (event) ->

    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $(this).find('option:selected').each ->
      $copy = $copy_target.clone()
      $copy.removeClass('template-row')
      $('input', $copy).val($(this).html())
      $copy.find('.quantity').val($(this).data('quantity'))
      $copy.find('.unit').val($(this).data('unit'))
      $copy_destination.show()
      $copy_destination.append($copy)

    $('tr').not('.template-row').find('select.unit').select2()
    $(this).select2("val", [])
    return true
