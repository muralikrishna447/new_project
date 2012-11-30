Handlebars.registerHelper 'each_with_index', (array, context) ->
  buffer = ''
  for i in array
    item = i
    item.index = _i
    buffer += context.fn(item)
  buffer
