cs_units = "grams"
cs_units_cookie_name = "chefsteps_units"
cs_scaling = 1.0

# On page load, store off the initial amounts of each ingredient and
# setup click handlers.
$ ->
  # Store off base value into an attribute for use in future calcs
  # Weights are normally in grams; if we see kg just convert it - will redisplay as kg if above 5 later.
  $('.quantity').each (i, element) =>
    orig_value = Number($(element).text())
    if $(element).siblings(".unit").text() == "kg"
      orig_value *= 1000
      $(element).siblings(".unit").text("g")
    $(element).attr("orig_value", orig_value)

  # Update to preferred units stored in the cookie
  debugger
  cs_units = $.cookie cs_units_cookie_name
  updateUnits()

  # Setup click handler for units toggle
  $("#change_units").click ->
    cs_units = if cs_units == "ounces" then "grams" else cs_units = "ounces"
    #$.cookie(cs_units_cookie_name, cs_units, { expires: 1000,  path: '/' })
    updateUnits()


# Replace the ingredient quantities and units for a row
setRow = (cell, qty_lbs, qty, units) ->
  cell.siblings(".unit").text(units)

  # Round to a sensible number of digits after the decimal
  dec_digits = 2
  dec_digits = 1 if qty > 1
  dec_digits = 0 if qty > 50
  mult = Math.pow(10, dec_digits)
  qty = Math.round(qty * mult) / mult

  # Special formatting for pounds. Tried having an extra set of columns
  # for pounds but that creates spacing problems.
  if qty_lbs != "" and units == "oz"
    cell.text qty_lbs + " lbs, " + qty
  else
    cell.text qty


# Compute the new ingredient quantities and units for a row
updateOneRowUnits = ->
  orig_value = Number($(this).attr("orig_value")) * cs_scaling
  existing_units = $(this).next().text()

  # "a/n" means as needed, don't do anything
  if existing_units == "a/n"
    # ok

  # "ea" means each, just round up to nearest integer
  else if existing_units == "ea"
    setRow $(this), "", Math.ceil(orig_value), "ea"

  # grams or kilograms
  else if cs_units == "grams"
    if orig_value < 5000
      setRow $(this), "", orig_value, "g"

    else
      setRow $(this), "", orig_value / 1000, "kg"

  # ounces or pounds and ounces
  else if cs_units == "ounces"
    ounces = orig_value * 0.035274
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
  alert("hi")
  # animate all the values and units down ...
  $('.qtyfade').animate {
  opacity: 0.0
  }, "fast", ->
    # This test needed so callback only runs once when all of first animations are done
    if $(".qtyfade:animated").length == 0

      # when that is done, switch the values and animate back up
      $('.quantity').each(updateOneRowUnits)
      $('.qtyfade').animate({opacity: 1}, "fast")