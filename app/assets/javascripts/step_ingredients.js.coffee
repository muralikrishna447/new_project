adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').height(height)

clearHighlights = () ->
  $('.prependable').text('')
  $('.ingredient-item').removeClass('ingredient-highlighted')
  $('.ingredient-item').removeClass('ingredient-unhighlighted')

highlight = (item,prepend_qty) ->
  prependable = item.find('.prependable')
  prependable.html(prepend_qty)
  item.addClass('ingredient-highlighted')

setTargetStep = (target) ->
  $('#full-ingredients-list').attr('data-target', target)

window.showStepIngredients = (step_ingredients) ->
  ingredients = $(step_ingredients).find('.ingredient-item')
  ingredients.each ->
    ingredient_id = $(this).data('ingredient-id')
    # Sets lbs quantity to nothing if it says Click to Edit
    if $(this).find('.lbs-qty').text() != 'Click to edit' && $(this).find('.lbs-qty').css('display') !='none'
      lbs_quantity = $(this).find('.lbs-qty').text() + ' ' + $(this).find('.lbs-label').text()
    else
      lbs_quantity = ''

    # Sets main quantity to nothing if it says Click to Edit
    if $(this).find('.main-qty').text() != 'Click to edit'
      quantity = $(this).find('.main-qty').text()
    else
      quantity = ''

    # Sets unit to nothing if it says a/n
    if $(this).find('.unit').text() != 'a/n'
      unit = $(this).find('.unit').text()
    else
      unit = ''
    item = $('#full-ingredients-list').find("*[data-ingredient-id='" + ingredient_id + "']")

    # If the prependable text is nothing, it won't add the word of
    prependable_text = lbs_quantity + " " + quantity + " " + unit
    if prependable_text.replace(/\s+/g, '').length > 0
      prepend_qty = prependable_text + " <span style='opacity: .3; font-weight: 400;'>of</span>"
    else
      prepend_qty = ''
    highlight(item,prepend_qty)
    
  if ingredients.length > 0
    $('.ingredient-item').not($('.ingredient-highlighted')).each ->
      $(this).addClass('ingredient-unhighlighted')

$ ->
  adjustStepHeight()

  # When a user hover overs a step, the ingredients used in the step are highlighted in the full ingredients list
  $('.step-ingredients').click ->
    clearHighlights()
    window.showStepIngredients($(this))
    step_id = $(this).closest('.ordered-step-item').attr('id')
    setTargetStep(step_id)
    # ingredients = $(this).find('.ingredient-item')
    # ingredients.each ->
    #   ingredient_id = $(this).data('ingredient-id')

    #   # Sets lbs quantity to nothing if it says Click to Edit
    #   if $(this).find('.lbs-qty').text() != 'Click to edit'
    #     lbs_quantity = $(this).find('.lbs-qty').text() + ' ' + $(this).find('.lbs-label').text()
    #   else
    #     lbs_quantity = ''

    #   # Sets main quantity to nothing if it says Click to Edit
    #   if $(this).find('.main-qty').text() != 'Click to edit'
    #     quantity = $(this).find('.main-qty').text()
    #   else
    #     quantity = ''

    #   # Sets unit to nothing if it says a/n
    #   if $(this).find('.unit').text() != 'a/n'
    #     unit = $(this).find('.unit').text()
    #   else
    #     unit = ''
    #   item = $('#full-ingredients-list').find("*[data-ingredient-id='" + ingredient_id + "']")

    #   # If the prependable text is nothing, it won't add the word of
    #   prependable_text = lbs_quantity + " " + quantity + " " + unit
    #   if prependable_text.replace(/\s+/g, '').length > 0
    #     prepend_qty = prependable_text + " <span style='opacity: .3; font-weight: 400;'>of</span>"
    #   else
    #     prepend_qty = ''
    #   highlight(item,prepend_qty)
      
    # if ingredients.length > 0
    #   $('.ingredient-item').not($('.ingredient-highlighted')).each ->
    #     $(this).addClass('ingredient-unhighlighted')

  $('.step-image-btn').click ->
    image = $(this).closest('.step-content').find('.step-image')
    image.toggle('blind', 300)