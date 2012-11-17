$ ->
  options =
    types: ['(cities)']

  _.each $('input.autocomplete'), (input)->
    autocomplete = new google.maps.places.Autocomplete(input, options)
