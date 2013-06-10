window.ChefSteps = window.ChefSteps || {}

capitalizeFirstLetter = (string) ->
  return string.charAt(0).toUpperCase() + string.slice(1)

window.ChefSteps.splitIngredient = (term) ->
  result = {}

  # a/n Tofu Eyeballs [or an Tofu Eyeballs]
  if s = term.match(/\b(an|a\/n)+\s+(.*)/)
    result = {"unit": "a/n", "ingredient": s[2]}

    # Tofu Eyeballs a/n
  else if s = term.match(/(.+)\s+(an|a\/n)\b/)
    result = {"unit": "a/n", "ingredient": s[1]}

    # 10 g Tofu Eyeballs (or kg, ea, each, r, recipe)
  else if s = term.match(/([\d.]+)\s*(g|kg|ea|each|r|recipe)+\s+(.*)/)
    unit = if s[2] then s[2] else "g"
    result = {"quantity": s[1], "unit": unit, "ingredient": s[3]}

  else if s = term.match(/(.+)\s+([\d.]+)\s*(g|kg|ea|each|r|recipe)+/)
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

