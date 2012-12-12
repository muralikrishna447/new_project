$ ->

  $('#syllabus-body-inner h3').html("Accelerated Sous Vide Cooking Course")

  htmlNarrow = $('#syllabus-body').html()

  # This is a hack to create a two column layout from the same copy used for the
  # course syllabus on the main course page. It can go away once courses are
  # a first class object that we can render as needed.
  $('#syllabus-body-inner').append('<div class="col col1"><ul></ul></div>')
  $('#syllabus-body-inner').append('<div class="col col2"><ul></ul></div>')
  $('#syllabus-body-inner > ul .module').slice(0, 4).appendTo($('#syllabus-body-inner .col1 ul'))
  $('#syllabus-body-inner > ul .module').appendTo($('#syllabus-body-inner .col2 ul'))

  $('#syllabus-flyout').click ->
    if $(window).width() >= 500
      $.colorbox {
        title: "Accelerated Sous Vide Cooking Course",
        inline: true,
        href:   '#syllabus-body-inner',
        fixed:  true,
        opacity: "0.5"
      }
    else
      $.colorbox {
        title: "Accelerated Sous Vide Cooking Course",
        inline: true,
        href:   htmlNarrow,
        width:  "80%",
        opacity: "0.5"
      }
