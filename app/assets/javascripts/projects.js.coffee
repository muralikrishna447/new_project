$ ->
  $('#start-project').click (e) ->
    e.preventDefault()
    $('#project-tabs li:eq(1) a').tab('show')