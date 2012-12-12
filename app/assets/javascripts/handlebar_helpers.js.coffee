Handlebars.registerHelper 'each_with_index', (array, block) ->
  buffer = ''
  for i in array
    item = i
    item.index = _i
    item.count = array.length
    buffer += block.fn(item)
  buffer

Handlebars.registerHelper 'question_width', (count)->
  if count % 3 == 0
    'span9'
  else
    'span10'

Handlebars.registerHelper 'option_width', (count)->
  if count % 3 == 0
    'span3'
  else
    'span5'

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

