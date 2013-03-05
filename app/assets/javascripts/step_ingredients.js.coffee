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

showImage = (image) ->
  viewer = $('#image-viewer')
  viewer.find('#image-viewer-container').html(image)
  viewer.show()

hideViewer = () ->
  viewer = $('#image-viewer')
  viewer.fadeOut 500

$ ->
  adjustStepHeight()

  # When a user hover overs a step, the ingredients used in the step are highlighted in the full ingredients list
  $('.ordered-step-item').hover ->
    clearHighlights()
    ingredients = $(this).find('.ingredient-item')
    ingredients.each ->
      ingredient_id = $(this).data('ingredient-id')

      # Sets lbs quantity to nothing if it says Click to Edit
      if $(this).find('.lbs-qty').text() != 'Click to edit'
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
    image = $(this).find('.step-image').html()
    showImage(image)

  $('#image-viewer').click ->
    hideViewer()