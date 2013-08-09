window.jumpToProjectTab = (index) ->
  $('#project-tabs li:eq(' + index + ') a').tab('show')
  window.scrollTo(0, 0)

$ ->
  $('#start-project').click (e) ->
    e.preventDefault()
    $('#project-tabs li:eq(1) a').tab('show')