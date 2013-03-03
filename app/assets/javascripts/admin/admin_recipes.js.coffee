closeEditorWarning = () ->
  "Make sure you press 'Update Recipe' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $('input').keyup ->
      window.onbeforeunload = closeEditorWarning

scrollIntoView = (elem) ->
  if elem.position()
    if elem.position().top < $(window).scrollTop()
  
      #scroll up
      jQuery("html,body").animate
        scrollTop: elem.position().top
      , 500
    else if elem.position().top + elem.height() > $(window).scrollTop() + (window.innerHeight or document.documentElement.clientHeight)
  
      #scroll down
      $("html,body").animate
        scrollTop: elem.position().top - (window.innerHeight or document.documentElement.clientHeight) + elem.height() + 15
      , 500

$ ->
  $('tr').not('.template-row').find('select.unit').select2()

  $(document).on('click', 'button', ( ->
    $('tr').not('.template-row').find('select.unit').select2()
  ));

splitIngredient = (term) ->
  result = {}

  # a/n Tofu Eyeballs [or an Tofu Eyeballs]
  if s = term.match(/\b(an|a\/n)+\s*(.*)/)
    result = {"unit": "a/n", "ingredient": s[2]}

  # Tofu Eyeballs a/n
  else if s = term.match(/(.+)\s*(an|a\/n)/)
    result = {"unit": "a/n", "ingredient": s[1]}

  # 10 g Tofu Eyeballs (or kg, ea, each, r, recipe)
  else if s = term.match(/([\d]+)\s*(g|kg|ea|each|r|recipe)+\s+(.*)/)
    unit = if s[2] then s[2] else "g"
    result = {"quantity": s[1], "unit": unit, "ingredient": s[3]}

  else if s = term.match(/(.+)\s+([\d]+)\s*(g|kg|ea|each|r|recipe)+/)
    unit = if s[3] then s[3] else "g"
    result = {"quantity": s[2], "unit": unit, "ingredient": s[1]}

  # None of the above, assumed to be a nekkid ingredient
  else
    result = {"ingredient" : term}
    if result["ingredient"].match(/\[RECIPE\]/)
      result["quantity"] = -1
      result["unit"] = "recipe"

  # Normalize the results
  result["unit"] = "ea" if result["unit"] == "each"
  result["unit"] = "a/n" if result["unit"] == "an"
  result["unit"] = "recipe" if result["unit"] == "r"

  result["ingredient"] = capitalizeFirstLetter($.trim(result["ingredient"]).replace(/\[RECIPE\]/,''))

  return result


capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

matchIngredient = (term) ->
  return term.toUpperCase().indexOf(splitIngredient(this.query)["ingredient"].toUpperCase()) >= 0;

updateRow = (row, data) ->
  # Special to force 1 recipe only if the user hasn't specified a quantity for a recipe
  if (data["quantity"] == -1)
    existing_quantity = row.find(".quantity").val()
    if (! existing_quantity)
      data["quantity"] = 1
    else
      data["quantity"] = existing_quantity

  # Update the quantity and unit
  row.find(".quantity").val(data["quantity"]) if data["quantity"]
  row.find(".unit").val(data["unit"]).trigger("change") if data["unit"]

updateIngredient = (item) ->
  row = this.$element.parents("tr")
  updateRow(row, splitIngredient(this.query))
  return item

finalizeIngredient = (inp) ->
  s = splitIngredient($(inp).val())
  row = $(inp).parents("tr")
  updateRow(row, s)
  $(inp).val(s["ingredient"])

sortIngredients = (items) ->
  beginswith = []
  caseSensitive = []
  caseInsensitive = []

  q = splitIngredient(this.query)["ingredient"]
  while item = items.shift()
    unless item.toLowerCase().indexOf(q.toLowerCase())
      beginswith.push item
    else if ~item.indexOf(q)
      caseSensitive.push item
    else
      caseInsensitive.push item

  return beginswith.concat(caseSensitive, caseInsensitive)



setupIngredientTypeahead = () ->
  allingredients = $('#allingredients').data('allingredients')

  # Convert new rows that get added into select2, but don't double convert old ones
  $('tr').not('.template-row').find('input.ingredient').not(".converted").each (index, cell) =>
    $(cell).addClass("converted").typeahead(
      {
        source: allingredients
        sorter: sortIngredients
        matcher: matchIngredient
        updater: updateIngredient
      }

    ).on('keypress', (event) ->
      # Side benefit of this behavior - without it, a keypress triggers the delete row button
      # On the topmost ingredient. Not sure why.
      if event.keyCode == 13 # return
        # If we just filled in the last row, add a new row
        if ($(this).parents("tr").is(":last-child"))
          $('#copy-ingredient-button button').click()

        # Focus next row
        $(this).parents("tr").next().find(".ingredient").focus()
        scrollIntoView($('#copy-ingredient-button'))

        return false

    ).on('blur', (event) ->
      finalizeIngredient($(this))
    )

$ ->
  setupIngredientTypeahead()
  $(document).on('click', 'button', ( -> setupIngredientTypeahead()));

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
