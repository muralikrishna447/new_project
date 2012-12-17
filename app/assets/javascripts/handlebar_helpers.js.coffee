Handlebars.registerHelper 'each_with_index', (array, block) ->
  buffer = ''
  return buffer unless array and block
  for i in array
    item = i
    item.index = _i
    item.count = array.length
    buffer += block.fn(item)
  buffer

Handlebars.registerHelper 'option_width', (count, index)->
  if count % 3 == 0
    'span3'
  else
    offset = if index == 0 then 2 else 1
    "span3 offset#{offset}"

Handlebars.registerHelper 'upload_image_button', (id = '') ->
  uploadButton =
  "<button type='button' class='admin-button upload-image' id='#{id}'>
    <i class='icon-picture'></i>
  </button>"
  new Handlebars.SafeString(uploadButton)

Handlebars.registerHelper 'default_value', (value, defaultValue) ->
  if value
    new Handlebars.SafeString(value)
  else
    new Handlebars.SafeString(defaultValue)

Handlebars.registerHelper 'first_caption', (array, block) ->
  if array && array.length > 0
    array[0].caption
  else
    ''

