window.ChefSteps = window.ChefSteps || {}

capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

window.ChefSteps.splitIngredient = (term) ->
  result = {}
  parse_unitless_number = parse_unitless_number || true

  # a/n Tofu Eyeballs, diced [or an Tofu Eyeballs]
  if s = term.match(/\s*(an|a\/n)+\s+([^,]*),?\s*(.*)?/)
    result = {unit: "a/n", ingredient: s[2], note: s[3]}

  # 10 g Tofu Eyeballs, diced (or kg, ea, each, r, recipe)
  # 10 Tofu Eyeballs (unit will be treated as 'ea')
  else if s = term.match(/\s*([\d.]+)\s*(g|kg|ea|each|r|recipe)?\s?([^,]*),?\s*(.*)?/)
    unit = if s[2] then s[2] else "ea"
    result = {quantity: s[1], unit: unit, ingredient: s[3], note: s[4]}

  # None of the above, assumed to be a nekkid ingredient
  else
    result = {ingredient: term, unit: "a/n"}
    if result["ingredient"].match(/\[RECIPE\]/)
      result["quantity"] = -1
      result["unit"] = "recipe"

  # Normalize the results
  result["unit"] = "ea" if result["unit"] == "each"
  result["unit"] = "a/n" if result["unit"] == "an"
  result["unit"] = "recipe" if result["unit"] == "r"

  result["ingredient"] = capitalizeFirstLetter($.trim(result["ingredient"]).replace(/\[RECIPE\]/,''))

  console.log "Parser result: #{JSON.stringify(result)}"
  return result

