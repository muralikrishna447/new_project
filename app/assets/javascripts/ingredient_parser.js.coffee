window.ChefSteps = window.ChefSteps || {}

capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

window.ChefSteps.splitIngredient = (term, parse_unitless_number) ->
  result = {}
  parse_unitless_number = true if ! parse_unitless_number?

  # a/n Tofu Eyeballs [or an Tofu Eyeballs]
  if s = term.match(/^(an|a\/n)+\s+(.*)/)
    result = {"unit": "a/n", "ingredient": s[2]}

  # Tofu Eyeballs a/n
  else if s = term.match(/(.+)\s+(an|a\/n)$\s*/)
    result = {"unit": "a/n", "ingredient": s[1]}

  # 10 g Tofu Eyeballs (or kg, ea, each, r, recipe)
  else if s = term.match(/^([\d.]+)\s*(g|kg|ea|each|r|recipe)+\s+(.*)/)
    unit = if s[2] then s[2] else "g"
    result = {"quantity": s[1], "unit": unit, "ingredient": s[3]}

  # Tofu eyeballs 10 g
  else if s = term.match(/(.+)\s+([\d.]+)\s*(g|kg|ea|each|r|recipe)+\s*$/)
    unit = if s[3] then s[3] else "g"
    result = {"quantity": s[2], "unit": unit, "ingredient": s[1]}

  # Any number at the beginning, even before there is a space. Use it as a quantity
  # but it also might be an ingredient name.
  else if  parse_unitless_number && (s = term.match(/^([\d.]+)/))
    result = {quantity: s[1], ingredient: s[1]}

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

