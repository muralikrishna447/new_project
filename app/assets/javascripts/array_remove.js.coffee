# Array Remove - By John Resig (MIT Licensed)
Array.prototype.remove = (from, to) ->
  rest = @slice((to || from) + 1 || @length)
  @length = from < 0 ? @length + from : from
  return @push.apply(@, rest)

