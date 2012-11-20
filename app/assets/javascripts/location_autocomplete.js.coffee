$ ->
  options =
    types: ['(cities)']

  _.each $('[data-behavior~=autocomplete]'), (input)->
    autocomplete = new google.maps.places.Autocomplete(input, options)
