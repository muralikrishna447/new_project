adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').height(height)

clearHighlights = () ->
  $('.prependable').text('')
  $('.ingredient-item').removeClass('ingredient-highlighted')
  $('.ingredient-item').removeClass('ingredient-unhighlighted')

highlight = (item,prepend_qty) ->
  prependable = item.find('.prependable')
  prependable.text(prepend_qty)
  item.addClass('ingredient-highlighted')

$ ->
  adjustStepHeight()

  # When a user hover overs a step, the ingredients used in the step are highlighted in the full ingredients list
  $('.ordered-step-item').hover ->
    clearHighlights()
    ingredients = $(this).find('.ingredient-item')
    ingredients.each ->
      ingredient_id = $(this).data('ingredient-id')
      quantity = $(this).find('.main-qty').text()
      unit = $(this).find('.unit').text()
      item = $('#full-ingredients-list').find("*[data-ingredient-id='" + ingredient_id + "']")
      prepend_qty = quantity + " " + unit
      highlight(item,prepend_qty)
    if ingredients.length > 0
      $('.ingredient-item').not($('.ingredient-highlighted')).each ->
        $(this).addClass('ingredient-unhighlighted')