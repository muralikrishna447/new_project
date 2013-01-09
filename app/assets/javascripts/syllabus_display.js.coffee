$ ->
  return if ! course_title?

  $('#syllabus-body-inner h3').html(course_title)

  htmlNarrow = $('#syllabus-body').html()

  # Restyle the syllabus to a 2 column format if on a wide device and
  # needed to fit. Could be done on the server side, but this keeps it responsive.
  $('#syllabus-body-inner').append('<div class="col col1"><ol></ol></div>')
  $('#syllabus-body-inner').append('<div class="col col2"><ol></ol></div>')
  num_modules = $('#syllabus-body-inner .module').length
  $('#syllabus-body-inner .module').slice(0, num_modules / 2).appendTo($('#syllabus-body-inner .col1 ol'))
  $('#syllabus-body-inner .module').appendTo($('#syllabus-body-inner .col2 ol'))

  $('#syllabus-flyout').click ->
    narrow = ($(window).width() <= 500) ||   (num_modules < 2)
    hr = if narrow then htmlNarrow else "#syllabus-body-inner"
    wid = if narrow then "80%" else "60%"

    $.colorbox {
      title: course_title,
      inline: true,
      href: hr,
      width: wid,
      opacity: "0.5"
    }