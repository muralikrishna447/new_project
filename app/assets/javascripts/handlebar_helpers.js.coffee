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
