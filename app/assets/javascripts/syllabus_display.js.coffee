$ ->
  return if ! course_title?

  $('#syllabus-body-inner h3').html(course_title)

  htmlNarrow = $('#syllabus-body').html()

  # Restyle the syllabus to a 2 column format if on a wide device and
  # needed to fit. Could be done on the server side, but this keeps it responsive.
  col1 = $('<div class="col col1 nested-activity-list-shared nested-activity-list-pretty"><ol></ol></div>');
  col2 = $('<div class="col col2 nested-activity-list-shared nested-activity-list-pretty"><ol></ol></div>');

  num_modules = $('#syllabus-body-inner .module').length
  $('#syllabus-body-inner .module').slice(0, num_modules / 2).appendTo(col1)
  $('#syllabus-body-inner .module').appendTo($(col2))
  $('#syllabus-body-inner').append(col1).append(col2)

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