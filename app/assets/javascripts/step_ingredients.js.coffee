clearHighlights = () ->
  $('.ingredient-item').css 'background', 'inherit'
  $('.ingredient-item').css 'color', 'inherit'
  $('.prependable').text('')


highlight = (item,prepend_qty) ->
  item.css 'background', '#DB7354'
  item.css 'color', 'white'
  item.find('.prependable').text(prepend_qty)

adjustStepHeight = () ->
  height = $('#video-ingredient-unit').height()
  $('.ordered-steps').height(height)

$ ->
  adjustStepHeight()

  $('.ordered-step-item').hover ->
    $('.ordered-step-item').css 'color', '#D8D8D8'
    $(this).css 'color', 'inherit'
    clearHighlights()
    ingredients = $(this).find('.ingredient-item')
    ingredients.each ->
      ingredient_id = $(this).data('ingredient-id')
      quantity = $(this).find('.main-qty').text()
      unit = $(this).find('.unit').text()
      item = $('#full-ingredients-list').find("*[data-ingredient-id='" + ingredient_id + "']")
      prepend_qty = quantity + " " + unit + " of"
      highlight(item,prepend_qty)