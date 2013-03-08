csUnits = "grams"
csTempUnits = "c"
csLengthUnits = "cm"
csUnitsCookieName = "chefsteps_units"


unless paramScaling?
  csScaling = 1.0
else
  csScaling = paramScaling

# Set up bootstrap tooltips (should be moved to a more general place)
$ ->
  $('.recipetip').tooltip({trigger: "hover"}).click ->
    return false

# On page load, store off the initial amounts of each ingredient and
# setup click handlers.
$ ->
  # Store off base value into an attribute for use in future calcs
  # Weights are normally in grams; if we see kg just convert it - will redisplay as kg if above 5 later.
  $('.main-qty').each (i, element) =>
    origValue = Number($(element).text())
    cell = $(element).parent()
    row = cell.parent()
    unit_cell = row.find('.unit')

    if unit_cell.text() == "kg"
      origValue *= 1000
      unit_cell.text("g")
    if unit_cell.text() == "a/n" || unit_cell.text() == ""
      $(element).parent().children().hide()

    $(element).data("origValue", origValue)

  $('.yield').each (i, element) =>
    origValue = Number($(element).text())
    $(element).data("origValue", origValue)

  # Update to preferred units stored in the cookie
  # This cookie code works but we decided that we want to encourage metric, so not using now,
  # forces user to click to ounces every time if they are that stubborn.
  # csUnits = $.cookie csUnitsCookieName
  updateUnits(false)

# Setup click handler for units toggle
$ ->
  $(".change_units").click ->
    csUnits = if csUnits == "ounces" then "grams" else "ounces"
    # $.cookie(csUnitsCookieName, csUnits, { expires: 1000,  path: '/' })
    updateUnits(true)

# make all the ingredient amounts editable
$ ->
  $(".ingredients .main-qty, .ingredients .lbs-qty").editable ((value, settings) ->
    item = $(this)
    old_val = Number(@revert)
    new_val = Number(value)

    unless isNaN(value)
      cell = item.parent()

      if cell.find('.lbs-qty').is(":visible")

        # pounds and ounces
        if item.hasClass('lbs-qty')
          # editing pounds
          old_lbs = old_val
          old_ozs = Number(cell.find('.main-qty').text())
          new_total = (new_val * 16) + old_ozs
        else
          # editing ounces
          old_lbs = Number(cell.find('.lbs-qty').text())
          old_ozs = old_val
          new_total = (old_lbs * 16) + new_val

        old_total = (old_lbs * 16) + old_ozs
        csScaling = csScaling * new_total / old_total

      else
        # Any other unit (including ounces with no pounds)
        csScaling = csScaling * new_val / old_val
    else
      value = old_val

    value

  ), {
    width: "10px"
    onblur: "cancel"
    cssclass: 'quantity-edit'
    #onedit: (settings, inp) ->
      #settings.width = $(inp).width() + 20
      #true
    callback: ->
      updateUnits(false)
  }

# Make the unit labels edit the units
$ ->
  $('.lbs-label').click ->
    $(this).prev().click()
  $('.unit').click ->
    $(this).parent().find('.main-qty').click()

# Replace the ingredient quantities and units for a row
setRow = (row, qtyLbs, qty, units) ->
  cell = row.find('.main-qty')
  row.find('.unit').text(units)

  # Round to a sensible number of digits after the decimal
  decDigits = 2
  decDigits = 1 if qty > 1
  decDigits = 0 if qty > 50
  mult = Math.pow(10, decDigits)
  qty = Math.round(qty * mult) / mult

  # Special formatting for pounds. Tried having an extra set of columns
  # for pounds but that creates spacing problems.
  cell.text qty
  if qtyLbs != "" and units == "oz"
    row.find(".lbs-qty, .lbs-label").show()
    row.find(".lbs-label").text(if qtyLbs == 1 then "lb, " else "lbs, ")
    row.find(".lbs-qty").text(qtyLbs)
  else
    row.find(".lbs-qty, .lbs-label").hide()


# Compute the new ingredient quantities and units for a row
updateOneRowUnits = ->
  origValue = Number($(this).find('.main-qty').data("origValue")) * csScaling
  existingUnits = $(this).find('.unit').text()

  # "a/n" means as needed, don't do anything. ditto if blank - formerly used
  # in cases where we mean "all of a subrecipe from above"
  if existingUnits == "a/n" || existingUnits == ""
    # ok

  # "ea" means each, just round up to nearest integer
  else if existingUnits == "ea"
    setRow $(this), "", Math.ceil(origValue), "ea"

  else if existingUnits == "recipe" || existingUnits == "recipes"
    setRow $(this), "", origValue, if origValue <= 1 then "recipe" else "recipes"

  # grams or kilograms
  else if csUnits == "grams"
    if origValue < 5000
      setRow $(this), "", origValue, "g"

    else
      setRow $(this), "", origValue / 1000, "kg"

  # ounces or pounds and ounces
  else if csUnits == "ounces"
    ounces = origValue * 0.035274
    pounds = Math.floor(ounces / 16)
    ounces = ounces - (pounds * 16)

    if pounds > 0
      ounces = Math.round(ounces)
      setRow $(this), pounds, ounces, "oz"

    else
      ounces = 0.01 if ounces < 0.01
      setRow $(this), "", ounces.toString(), "oz"


# Update all rows
updateUnits = (animate) ->
  if (animate)
    # animate all the values and units down ...
    $('.qtyfade').fadeOut "fast"
    $('.qtyfade').promise().done ->
      $('.quantity-group').closest('tr').each(updateOneRowUnits)
      $('.text-quantity-group').each(updateOneRowUnits)
      $('.qtyfade').fadeIn "fast"
  else
    $('.quantity-group').closest('tr').each(updateOneRowUnits)
    $('.text-quantity-group').each(updateOneRowUnits)

addScalingToLink = (anchor) ->
  window.open($(anchor).attr("href") + '?scaling=' + $(anchor).parents('tr').find('.main-qty').text());
  return false;

# make globally available
window.addScalingToLink = addScalingToLink

############### TEMPERATURE

updateOneTemp = ->
  v = $(this).find('.temperature').data("orig-value")
  v = Math.round(Number(v) * 1.8 + 32) if csTempUnits == "f"
  $(this).find('.temperature').text(v)
  $(this).find('.temperature-unit').html(if csTempUnits == 'c' then '&deg;C' else '&deg;F')

# Update all temps
updateTempUnits =  ->
    # animate all the values and units down ...
    $('.temperature-group').fadeOut "fast"
    $('.temperature-group').promise().done ->
      $('.temperature-group').each(updateOneTemp)
      $('.temperature-group').fadeIn "fast"

# Setup click handler for temp toggles
$ ->
  $(".temperature-group").click ->
    csTempUnits = if csTempUnits == "c" then "f" else "c"
    # $.cookie(csUnitsCookieName, csUnits, { expires: 1000,  path: '/' })
    updateTempUnits(true)

# On page load, store off the initial temps
$ ->
  # Store off base value into an attribute for use in future calcs
  # Weights are normally in grams; if we see kg just convert it - will redisplay as kg if above 5 later.
  $('.temperature').each (i, element) =>
    origValue = Number($(element).text())
    $(element).data("origValue", origValue)

############### LENGTH


# Use html entity when available, otherwise sup/subscript
fractionForSixteenths = (numerator) ->
  sixteenths = ["",
    "<sup>1</sup>&frasl;<sub>16</sub>",
    "&#x215B;",
    "<sup>3</sup>&frasl;<sub>16</sub>",
    "&frac14;",
    "<sup>5</sup>&frasl;<sub>16</sub>",
    "&#x215C;",
    "<sup>7</sup>&frasl;<sub>16</sub>",
    "&frac12;",
    "<sup>9</sup>&frasl;<sub>16</sub>",
    "&#x215D;",
    "<sup>11</sup>&frasl;<sub>16</sub>",
    "&frac34;",
    "<sup>13</sup>&frasl;<sub>16</sub>",
    "&#x215E;",
    "<sup>15</sup>&frasl;<sub>16</sub>"
  ]

  sixteenths[numerator]


updateOneLength = ->
  v = Number($(this).find('.length').attr("data-orig-value"))
  #debugger if v == 11
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
  $(".length-group").click ->
    csLengthUnits = if csLengthUnits == "cm" then "in" else "cm"
    # $.cookie(csUnitsCookieName, csUnits, { expires: 1000,  path: '/' })
    updateLengthUnits(true)



