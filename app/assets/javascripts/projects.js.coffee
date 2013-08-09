window.jumpToProjectTab = (index) ->
  $('#project-tabs li:eq(' + index + ') a').tab('show')

$ ->
  $('#start-project').click (e) ->
    e.preventDefault()
    $('#project-tabs li:eq(1) a').tab('show')