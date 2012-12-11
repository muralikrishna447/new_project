$ ->
  $('#syllabus-flyout h3').remove()

  $('#syllabus-body').prepend('<div class="col col2"><ul></ul></div>')
  $('#syllabus-body').prepend('<div class="col col1"><ul></ul></div>')

  $('#syllabus-body > ul .module').slice(0, 4).appendTo($('#syllabus-body .col1 ul'))
  $('#syllabus-body > ul .module').appendTo($('#syllabus-body .col2 ul'))

  $('#syllabus-flyout').click ->
    $('#syllabus-body').slideToggle()
