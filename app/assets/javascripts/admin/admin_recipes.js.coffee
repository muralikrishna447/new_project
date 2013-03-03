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
  # a/n Tofu Eyeballs [or an Tofu Eyeballs]
  if s = term.match(/\b(an|a\/n)+\s+(.*)/)
    return {"unit": "a/n", "ingredient": s[2]}

  # 10 g Tofu Eyeballs (or kg, ea, each, r, recipe)
  if s = term.match(/([\d]+)\s*(g|kg|ea|each|r|recipe)+\s+(.*)/)
    quantity = s[1]
    unit = if s[2] then s[2] else "g"
    unit = "ea" if unit == "each"
    unit = "a/n" if unit == "an"
    unit = "recipe" if unit == "r"
    ingredient = s[3]
    return {"quantity": quantity, "unit": unit, "ingredient": ingredient}

  # None of the above, assumed to be a nekkid ingredient
  return {"ingredient" : term}


capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

createSearchChoice = (term, cell) ->
  return {id: new Date().getTime(), title: capitalizeFirstLetter(s["ingredient"])}

matchIngredient = (term) ->
  return term.toUpperCase().indexOf(splitIngredient(this.query)["ingredient"].toUpperCase()) >= 0;

updateIngredient = (item) ->
  s = splitIngredient(this.query)
  row = this.$element.parents("tr")
  row.find(".quantity").val(s["quantity"]) if s["quantity"]
  row.find(".unit").val(s["unit"]).trigger("change") if s["unit"]
  return capitalizeFirstLetter(item)

finalizeIngredient = (inp) ->
  s = splitIngredient($(inp).val())
  row = $(inp).parents("tr")
  row.find(".quantity").val(s["quantity"]) if s["quantity"]
  row.find(".unit").val(s["unit"]).trigger("change") if s["unit"]
  $(inp).val(capitalizeFirstLetter($.trim(s["ingredient"]).replace(/\[RECIPE\]/,'')))


setupIngredientTypeahead = () ->
  allingredients = $('#allingredients').data('allingredients')

  # Convert new rows that get added into select2, but don't double convert old ones
  $('tr').not('.template-row').find('input.ingredient').not(".converted").each (index, cell) =>
    $(cell).typeahead(
      {
        source: allingredients
        matcher: matchIngredient
        updater: updateIngredient
      }

    ).addClass("converted").on('change', (event) ->

      # For recipes, make sure the quantity is set to "recipe"
      #id = inp.select2('data')["id"]
      #if id < 0
        #$(this).parents("tr").find(".unit").val("recipe").trigger("change")
        #qty = $(this).parents("tr").find(".quantity")
        #qty.val("1") if ! qty.val()

      return true

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
