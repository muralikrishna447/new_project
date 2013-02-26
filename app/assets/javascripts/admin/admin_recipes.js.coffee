closeEditorWarning = () ->
  "Make sure you press 'Update Recipe' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $('input').keyup ->
      window.onbeforeunload = closeEditorWarning

$ ->
  $('tr').not('.template-row').find('select.unit').select2()

  $(document).on('click', 'button', ( ->
    $('tr').not('.template-row').find('select.unit').select2()
  ));

formatIngredient = (item) ->
  if item.id < 0
    return "Recipe: " + item.title
  else
    return item.title

setupIngredientSelect = () ->
  allingredients = $('#allingredients').data('allingredients')
  allingredients.unshift({id: 0, title: ""})
  $('tr').not('.template-row').find('input.ingredient').not(".converted").select2(
    {
      placeholder: "Ingredient or Sub-Recipe"
      data: { results: allingredients, text: "title"}
      initSelection: (element, callback) ->
        callback({id: element.data("ingredient-id"), title: element.val()})
      formatSelection: formatIngredient
      formatResult: formatIngredient
      escapeMarkup: (x) ->
        return x
      createSearchChoice: (term) ->
        return {id: new Date().getTime(), title: term}
    }
  ).addClass("converted").on 'change', (event) ->
    inp = $(event.target)
    inp.val(inp.select2('data')["title"])
    return true


$ ->
  setupIngredientSelect()
  $(document).on('click', 'button', ( -> setupIngredientSelect()));

$ ->
  $('.multi-ingredients').select2(
    {
      closeOnSelect: false,
      placeholder: "Select from recipe ingredients"
    }
  )

$ ->
  $('.multi-ingredients').on 'close', (event) ->

    copy_target = $(this).data('copy-target')
    copy_destination = $(this).data('copy-destination')
    $copy_target = $(copy_target)
    $copy_destination = $(copy_destination)

    $(this).find('option:selected').each ->
      $copy = $copy_target.clone()
      $copy.removeClass('template-row')
      $('input', $copy).val($(this).html())
      $copy.find('.quantity').val($(this).data('quantity'))
      $copy.find('.unit').val($(this).data('unit'))
      $copy_destination.show()
      $copy_destination.append($copy)

    $('tr').not('.template-row').find('select.unit').select2()
    $(this).select2("val", [])
    return true
