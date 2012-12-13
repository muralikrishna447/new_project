Array.prototype.remove = (element) ->
  index = @indexOf(element)
  return if index < 0
  @splice(index, 1)[0]
