clearHighlights = (num_ingredients) ->
  # $('.ingredient-title').css 'font-weight', 'normal'
  # if num_ingredients > 0
  #   $('.ingredient-item').css 'opacity', '.2'
  # else
  #   $('.ingredient-item').css 'opacity', '1'
  $('.prependable').text('')
  $('.ingredient-item').removeClass('ingredient-highlighted')

highlight = (item,prepend_qty) ->
  # item.css 'opacity', '1'
  # item.find('.ingredient-title').css 'font-weight', 'bold'
  prependable = item.find('.prependable')
  prependable.text(prepend_qty)
  # prependable.css 'font-weight', 'bold'
  item.addClass('ingredient-highlighted')

adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').height(height)

$ ->
  adjustStepHeight()

  $('.ordered-step-item').hover ->
    ingredients = $(this).find('.ingredient-item')
    clearHighlights(ingredients.length)
    ingredients.each ->
      ingredient_id = $(this).data('ingredient-id')
      quantity = $(this).find('.main-qty').text()
      unit = $(this).find('.unit').text()
      item = $('#full-ingredients-list').find("*[data-ingredient-id='" + ingredient_id + "']")
      prepend_qty = quantity + " " + unit + " of "
      highlight(item,prepend_qty)