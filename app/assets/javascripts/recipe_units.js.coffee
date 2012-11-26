# refactor code
# units tests
# different UI for switching
# make the test recipe more suitable for testing

cs_units = "grams"
cs_units_cookie_name = "chefsteps_units"
cs_scaling = 1.0

$ ->
  # Store off base grams into an attribute for use in future calcs
	$('.quantity').each (i, element) =>
	  $(element).attr("grams", Number($(element).text()))

  # Update to preferred units stored in the cookie
  # cs_units = $.cookie cs_units_cookie_name
  updateUnits()

  # Setup click handlers
  $("#change_units").click ->
    cs_units = if cs_units == "ounces" then "grams" else cs_units = "ounces"
    updateUnits()

setWeight = (obj, weight) -> obj.text(weight)

updateUnitsGuts = (x) ->

	grams = Number($(this).attr("grams")) * cs_scaling
	existing_units = $(this).next().text()
	if existing_units == "a/n"
		# "as needed", just leave alone

	else if existing_units == "ea"
		# each, just round up to nearest
		setWeight $(this), Math.ceil(grams)

	else if cs_units == "grams"
		if grams < 5000
			if grams > 100
				# No decimal places
				grams = Math.round(grams)
			else if grams > 1
				# One decimal place
				grams = Math.round(grams * 10) / 10
			else
				# Two decimal places
				grams = Math.round(grams * 100) / 100

			setWeight $(this), grams
			$(this).next().text "g"

		else
			kg = Math.round(g * 1000 * 100) / 100
			setWeight $(this), kg
			$(this).next().text "kg"


	else if cs_units == "ounces"
		ounces = grams * 0.035274
		pounds = Math.floor(ounces / 16)
		ounces = ounces - (pounds * 16)
		ounces = Math.round(ounces * 10) / 10

		if (pounds > 0)
			setWeight $(this), pounds.toString() + " lbs, " + ounces.toString()
			$(this).next().text("oz")

		else
			setWeight $(this), ounces.toString()
			$(this).next().text("oz")

updateUnits = ->
  #$.cookie(cs_units_cookie_name, cs_units, { expires: 1000,  path: '/' })

  # animate all the values and units down to black
  $('.quantity, .unit').animate {
    opacity: 0.0
  }, 300, ->

    # now switch the values and animate back up
    $('.quantity').each(updateUnitsGuts)
    $('.quantity, .unit').animate({opacity: 1}, 300)