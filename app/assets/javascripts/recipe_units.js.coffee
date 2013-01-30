csUnits = "grams"
csUnitsCookieName = "chefsteps_units"
csScaling = 1.0

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
  $(".main-qty, .lbs-qty").editable ((value, settings) ->
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
        # Grams, kilograms, or ounces with no pounts
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

  # "a/n" means as needed, don't do anything. ditto if blank - used
  # in cases where we mean "all of a subrecipe from above"
  if existingUnits == "a/n" || existingUnits == ""
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
updateUnits = (animate) ->
  if (animate)
    # animate all the values and units down ...
    $('.qtyfade').fadeOut "fast"
    $('.qtyfade').promise().done ->
      $('.quantity-group').closest('tr').each(updateOneRowUnits)
      $('.qtyfade').fadeIn "fast"
  else
    $('.quantity-group').closest('tr').each(updateOneRowUnits)

