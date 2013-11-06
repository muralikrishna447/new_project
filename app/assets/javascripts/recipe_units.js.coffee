csTempUnits = "c"
csLengthUnits = "cm"
window.csUnitsCookieName = "chefsteps_units"

# Temporary way of dealing with stuff til this is all angularized

rootScope = ->
  angular.element('body').scope()

getScaling = ->
  rootScope()?.csScaling || 1.0

setScaling = (newScale) ->
  rootScope()?.csScaling = newScale
  rootScope()?.$apply()

getUnits = ->
  rootScope()?.csUnits || "grams"

setUnits = (newUnits) ->
  rootScope()?.csUnits = newUnits
  rootScope()?.$apply()

window.allUnits = [
  {measures: "Weight", name: "g", menuName: "gram"},
  {measures: "Weight", name: "kg", menuName: "kilogram"},
  {measures: "Weight", name: "lb", plural: "lbs", menuName: "pound"},
  {measures: "Weight", name: "oz", plural: "ozs", menuName: "ounce"},

  {measures: "Volume", name: "ml", menuName: "milliliter"},
  {measures: "Volume", name: "l", menuName: "liter"}
  {measures: "Volume", name: "drop", plural: "drops"},
  {measures: "Volume", name: "fl. oz.", plural: "fl. ozs.", menuName: "fluid ounce"},
  {measures: "Volume", name: "tsp.", menuName: "teaspoon", plural: "tsps."},
  {measures: "Volume", name: "Tbsp.", menuName: "tablespoon", plural: "Tbsps."},
  {measures: "Volume", name: "cup", plural: "cups"},
  {measures: "Volume", name: "pint", plural: "pints"},
  {measures: "Volume", name: "quart", plural: "quarts"},
  {measures: "Volume", name: "gallon", plural: "gallons"},

  {measures: "Miscellanea", name: "ea", menuName: "each"},
  {measures: "Miscellanea", name: "recipe", plural: "recipes"},
  {measures: "Miscellanea", name: "a/n", menuName: "as needed"},
  {measures: "Miscellanea", name: "piece", plural: "pieces"}
]

# Normalize unit names
_.each(window.allUnits, ((u) ->
  u.plural = u.plural || u.name
  u.menuName = u.menuName || u.name
))

unitByName = (unitName) ->
  _.find(window.allUnits, (u) -> (u.name == unitName) || (u.plural == unitName))

isWeightUnit = (unitName) ->
  unitByName(unitName)?.measures == "Weight"


# NOTE WELL there are some places where we are using children(), not find() here very on purpose, because it is
# possible to have a quantity row nested in a quantity row, specifically when shortcodes like [ea 5] are used
# in the ingredient notes field.

if paramScaling?
  setScaling(paramScaling)

# Set up bootstrap tooltips (should be moved to a more general place)
$ ->
  $('.recipetip').tooltip({trigger: "hover"}).click ->
    return false

# Delay here for angular to render; this can go away once scaling is all angular
$ ->
  setTimeout ( ->
    updateUnits(false)
  ), 1000


# Setup click handler for units toggle
$ ->
  $(".change_units").click ->
    setUnits(if getUnits() == "ounces" then "grams" else "ounces")
    # $.cookie(window.csUnitsCookieName, window.csUnits, { expires: 1000,  path: '/' })
    updateUnits(true)


window.makeEditable = (elements) ->
  elements.not(["data-marked-editable"]).editable ((value, settings) ->
    item = $(this)
    old_val = Number(@revert)
    new_val = Number(value)

    unless isNaN(value)
      cell = item.parent()

      if cell.find('.lbs-qty').is(":visible")

        # pounds and coun
        if item.hasClass('lbs-qty')
          # editing pounds
          old_lbs = old_val
          old_ozs = Number(cell.children('.main-qty').text())
          new_total = (new_val * 16) + old_ozs
        else
          # editing ounces
          old_lbs = Number(cell.children('.lbs-qty').text())
          old_ozs = old_val
          new_total = (old_lbs * 16) + new_val

        old_total = (old_lbs * 16) + old_ozs
        setScaling(getScaling() * new_total / old_total)

      else
        # Any other unit (including ounces with no pounds)
        setScaling(getScaling() * new_val / old_val)
    else
      value = old_val

  ), {
    width: "10px"
    onblur: "cancel"
    cssclass: 'quantity-edit'
    callback: ->
      updateUnits(false)
  }
  # Editable freaks if called twice on same element
  elements.attr("data-marked-editable", "true")


# Make the unit labels edit the units
$ ->
  $('.lbs-label').click ->
    $(this).prev().click()
  $('.unit').click ->
    $(this).parent().children('.main-qty').click()

window.roundSensible = (qty) ->
  if qty
    # Round to a sensible number of digits after the decimal
    decDigits = 2
    decDigits = 1 if qty > 1
    decDigits = 0 if qty > 50
    mult = Math.pow(10, decDigits)
    qty = Math.round(qty * mult) / mult
  qty

# Replace the ingredient quantities and units for a row
setRow = (row, qtyLbs, qty, units) ->
  cell = row.children('.quantity-group').find('.main-qty')
  row.children('.unit').text(units)

  qty = window.roundSensible(qty)

  # Special formatting for pounds. Tried having an extra set of columns
  # for pounds but that creates spacing problems.
  cell.text qty
  if qtyLbs != "" and units == "oz"
    row.children('.quantity-group').children(".lbs-qty, .lbs-label").show()
    row.children('.quantity-group').children(".lbs-label").text(if qtyLbs == 1 then "lb, " else "lbs, ")
    row.children('.quantity-group').children(".lbs-qty").text(qtyLbs)
  else
    row.children('.quantity-group').children(".lbs-qty, .lbs-label").hide()


# Compute the new ingredient quantities and units for a row
updateOneRowUnits = ->
  main_qty = $(this).children('.quantity-group').find('.main-qty')
  base_orig_value = main_qty.attr("data-orig-value")
  existingUnits = $(this).children('.unit').text()

  # Lazily store off the original value in grams
  if ! base_orig_value || base_orig_value == "null"
    base_orig_value = Number($(main_qty[0]).text())
    main_qty.attr("data-orig-value", base_orig_value)
    if existingUnits == "kg"
      base_orig_value = base_orig_value * 1000
      
  origValue = Number(base_orig_value) * getScaling()

  # "ea" means each, just round up to nearest integer
  if existingUnits == "ea"
    setRow $(this), "", Math.ceil(origValue), existingUnits

  # a/n means "as needed" - quantity always blank
  else if existingUnits == "a/n"
    setRow $(this), "", "", existingUnits

  else if isWeightUnit(existingUnits)

    # grams or kilograms
    if getUnits() == "grams"
      if origValue < 5000
        setRow $(this), "", origValue, "g"

      else
        setRow $(this), "", origValue / 1000, "kg"

    # ounces or pounds and ounces
    else if getUnits() == "ounces"
      ounces = origValue * 0.035274
      pounds = Math.floor(ounces / 16)
      ounces = ounces - (pounds * 16)

      if pounds > 0
        ounces = Math.round(ounces)
        setRow $(this), pounds, ounces, "oz"

      else
        ounces = 0.01 if ounces < 0.01
        setRow $(this), "", ounces.toString(), "oz"

  # Any other unit, we just want to leave alone except for pluralization
  else
    unitText = existingUnits
    unitText = unitByName(existingUnits).plural if origValue > 1.001
    setRow $(this), "", origValue, unitText



# Update all rows
window.updateUnits = (animate) ->
  if (animate)
    # animate all the values and units down ...
    $('.qtyfade').fadeOut "fast"
    $('.qtyfade').promise().done ->
      $('.quantity-group').parent().each(updateOneRowUnits)
      $('.text-quantity-group').each(updateOneRowUnits)
      $('.qtyfade').fadeIn "fast"
  else
    $('.quantity-group').parent().each(updateOneRowUnits)
    $('.text-quantity-group').each(updateOneRowUnits)

addScalingToLink = (anchor) ->
  window.open($(anchor).attr("href") + '?scaling=' + $(anchor).parents('tr').children('.quantity-group').find('.main-qty').text());
  return false;

# make globally available
window.addScalingToLink = addScalingToLink

############### LENGTH


# Use html entity when available, otherwise sup/subscript
fractionForSixteenths = (numerator) ->
  sixteenths = ["",
    "<sup>1</sup>&frasl;<sub>16</sub>",
    "<sup>1</sup>&frasl;<sub>8</sub>",
    "<sup>3</sup>&frasl;<sub>16</sub>",
    "<sup>1</sup>&frasl;<sub>4</sub>",
    "<sup>5</sup>&frasl;<sub>16</sub>",
    "<sup>3</sup>&frasl;<sub>8</sub>",
    "<sup>7</sup>&frasl;<sub>16</sub>",
    "<sup>1</sup>&frasl;<sub>2</sub>",
    "<sup>9</sup>&frasl;<sub>16</sub>",
    "<sup>5</sup>&frasl;<sub>8</sub>",
    "<sup>11</sup>&frasl;<sub>16</sub>",
    "<sup>3</sup>&frasl;<sub>4</sub>",
    "<sup>13</sup>&frasl;<sub>16</sub>",
    "<sup>7</sup>&frasl;<sub>8</sub>",
    "<sup>15</sup>&frasl;<sub>16</sub>"
  ]

  sixteenths[numerator]


updateOneLength = ->
  v = Number($(this).find('.length').attr("data-orig-value"))
  if csLengthUnits == "in"

    # Convert to feet, inches, and 16ths of an inch
    result = ""
    inches = v * 0.393701
    feet = Math.floor(inches / 12)
    result += "#{feet} ft " if feet != 0

    inches = inches - (feet * 12)
    frac = inches - Math.floor(inches)
    inches = Math.floor(inches)
    den = 16
    num = Math.round(frac * den)

    # Don't go all the way down to 16ths for larger lengths, unnecessary precision
    if feet > 0
      num = Math.round(num / 4) * 4   # limit to 1/4 inch increments
    if inches > 2
      num = Math.round(num / 2) * 2   # limit to 1/8 inch increments

    # Rounding may have pushed us up to next inch
    if num == den
      num = 0
      inches += 1

    # Format the inches and fractions
    if (inches != 0) || (num != 0)
      result += "#{inches} " if inches != 0
      result += "#{fractionForSixteenths(num)}" if num != 0
      result += " in"

    $(this).find('.length').html(result)

  else if v < 1
    $(this).find('.length').html("#{Math.round(v * 10)} mm")

  else
    $(this).find('.length').html("#{v} cm")

# Update all length
updateLengthUnits =  ->
  # animate all the values and units down ...
  $('.length-group').fadeOut "fast"
  $('.length-group').promise().done ->
    $('.length-group').each(updateOneLength)
    $('.length-group').fadeIn "fast"

# Setup click handler for length toggles
$ ->
  $(document).on 'click', ".length-group", ->
    csLengthUnits = if csLengthUnits == "cm" then "in" else "cm"
    # $.cookie(window.csUnitsCookieName, window.csUnits, { expires: 1000,  path: '/' })
    updateLengthUnits(true)



