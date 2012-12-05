csUnits = "grams"
csUnitsCookieName = "chefsteps_units"
csScaling = 1.0

# On page load, store off the initial amounts of each ingredient and
# setup click handlers.
$ ->
  # Store off base value into an attribute for use in future calcs
  # Weights are normally in grams; if we see kg just convert it - will redisplay as kg if above 5 later.
  $('.quantity').each (i, element) =>
    origValue = Number($(element).text())
    if $(element).siblings(".unit").text() == "kg"
      origValue *= 1000
      $(element).siblings(".unit").text("g")
    $(element).attr("origValue", origValue)

  # Update to preferred units stored in the cookie
  # This cookie code works but we decided that we want to encourage metric, so not using now,
  # forces user to click to ounces every time if they are that stubborn.
  # csUnits = $.cookie csUnitsCookieName
  updateUnits()

  # Setup click handler for units toggle
  $(".change_units").click ->
    csUnits = if csUnits == "ounces" then "grams" else "ounces"
    # $.cookie(csUnitsCookieName, csUnits, { expires: 1000,  path: '/' })
    updateUnits()


# Replace the ingredient quantities and units for a row
setRow = (cell, qtyLbs, qty, units) ->
  cell.siblings(".unit").text(units)

  # Round to a sensible number of digits after the decimal
  decDigits = 2
  decDigits = 1 if qty > 1
  decDigits = 0 if qty > 50
  mult = Math.pow(10, decDigits)
  qty = Math.round(qty * mult) / mult

  # Special formatting for pounds. Tried having an extra set of columns
  # for pounds but that creates spacing problems.
  if qtyLbs != "" and units == "oz"
    cell.text qtyLbs + " lbs, " + qty
  else
    cell.text qty


# Compute the new ingredient quantities and units for a row
updateOneRowUnits = ->
  origValue = Number($(this).attr("origValue")) * csScaling
  existingUnits = $(this).next().text()

  # "a/n" means as needed, don't do anything
  if existingUnits == "a/n"
    # ok

  # "ea" means each, just round up to nearest integer
  else if existingUnits == "ea"
    setRow $(this), "", Math.ceil(origValue), "ea"

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
updateUnits = ->
  # animate all the values and units down ...
  $('.qtyfade').fadeOut "fast", ->
    # This test needed so callback only runs once when all of first animations are done
    if $(".qtyfade:animated").length == 0

      # when that is done, switch the values and animate back up
      $('.quantity').each(updateOneRowUnits)
      $('.qtyfade').fadeIn "fast"