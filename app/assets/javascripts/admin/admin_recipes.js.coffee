closeEditorWarning = () ->
  "Make sure you press 'Update Activity' to save any changes."

$ ->
  if $('.update-warning').is('*')
    $('input, textarea').change ->
      window.onbeforeunload = closeEditorWarning
    $('.btn-warning').click ->
      window.onbeforeunload = closeEditorWarning
    $('#activity_submit_action').click ->
      window.onbeforeunload = null

scrollIntoView = (elem) ->
  if elem.position()
    if elem.position().top < $(window).scrollTop()
  
      #scroll up
      jQuery("html,body").animate
        scrollTop: elem.position().top
      , 500
    else if elem.position().top + elem.height() > $(window).scrollTop() + (window.innerHeight or document.documentElement.clientHeight)
  
      #scroll down
      $("html,body").animate
        scrollTop: elem.position().top - (window.innerHeight or document.documentElement.clientHeight) + elem.height() + 15
      , 500

$ ->
  $('tr').not('.template-row').find('select.unit').select2()

  $(document).on('click', 'button', ( ->
    $('tr').not('.template-row').find('select.unit').select2()
  ));

matchIngredient = (term) ->
  return term.toUpperCase().indexOf(window.ChefSteps.splitIngredient(this.query)["ingredient"].toUpperCase()) >= 0;

updateRow = (row, data) ->
  # Special to force 1 recipe only if the user hasn't specified a quantity for a recipe
  if (data["quantity"] == -1)
    existing_quantity = row.find(".quantity").val()
    if (! existing_quantity)
      data["quantity"] = 1
    else
      data["quantity"] = existing_quantity

  # Update the quantity and unit
  row.find(".quantity").val(data["quantity"]) if data["quantity"]
  row.find(".unit").val(data["unit"]).trigger("change") if data["unit"]

updateIngredient = (item) ->
  row = this.$element.parents("tr")
  updateRow(row, window.ChefSteps.splitIngredient(this.query))
  return item

finalizeIngredient = (inp) ->
  s = window.ChefSteps.splitIngredient($(inp).val())
  row = $(inp).parents("tr")
  updateRow(row, s)
  $(inp).val(s["ingredient"])

sortIngredients = (items) ->
  beginswith = []
  caseSensitive = []
  caseInsensitive = []

  q = window.ChefSteps.splitIngredient(this.query)["ingredient"]
  while item = items.shift()
    unless item.toLowerCase().indexOf(q.toLowerCase())
      beginswith.push item
    else if ~item.indexOf(q)
      caseSensitive.push item
    else
      caseInsensitive.push item

  return beginswith.concat(caseSensitive, caseInsensitive)

setupIngredientTypeahead = () ->
  allingredients = $('#allingredients').data('allingredients')

  # Convert new rows that get added into select2, but don't double convert old ones
  $('tr').not('.template-row').find('input.ingredient').not(".converted").each (index, cell) =>
    $(cell).addClass("converted").typeahead(
      {
        source: allingredients
        sorter: sortIngredients
        matcher: matchIngredient
        updater: updateIngredient
      }

    ).on('keypress', (event) ->
      # Side benefit of this behavior - without it, a keypress triggers the delete row button
      # On the topmost ingredient. Not sure why.
      if event.keyCode == 13 # return
        # If we just filled in the last row, add a new row
        if ($(this).parents("tr").is(":last-child"))
          $('#copy-ingredient-button button').click()

        # Focus next row
        $(this).parents("tr").next().find(".ingredient").focus()
        scrollIntoView($('#copy-ingredient-button'))

        return false

    ).on('blur', (event) ->
      finalizeIngredient($(this))
    )

$ ->
  setupIngredientTypeahead()
  $(document).on('click', 'button', ( -> setupIngredientTypeahead()));

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
      $copy.find('.note').val($(this).data('note'))
      $copy.find('.quantity').val($(this).data('quantity'))
      $copy.find('.unit').val($(this).data('unit'))
      $copy_destination.show()
      $copy_destination.append($copy)

    $('tr').not('.template-row').find('select.unit').select2()
    $(this).select2("val", [])
    return true

updateMediaPills = () ->
  $('.media .nav-pills li a').each ->
    content = $($(this).data('target'))
    has_data = false
    $(content).find('input, textarea').each ->
      has_data = true if $(this).val()
    if has_data
      $(this).addClass("has-data")
    else
      $(this).removeClass("has-data")

activateContentfulPills = () ->
  $('.media .nav-pills').each ->
    $(this).find('.has-data:first').tab('show')


$ ->
  updateMediaPills()
  activateContentfulPills()
  $(document).on 'keydown click', (event) ->
    updateMediaPills()

window.stepCopied = (newStep) ->
  new_tabs_id = "media-tabs-" + (100000 + (Date.now() % 100000)).toString()
  media_tabs = $(newStep).find('.media-tabs')
  media_tabs.attr('id', new_tabs_id)
  $(newStep).find('[data-target*=media-tabs]').each ->
    newTarget = $(this).data('target').replace('media-tabs-', new_tabs_id)
    $(this).attr('data-target', newTarget)