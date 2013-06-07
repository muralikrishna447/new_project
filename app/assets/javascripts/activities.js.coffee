adjustStepHeight = () ->
  window_width = $(window).width()
  unless window_width <= 767
    height = $('#video-ingredient-unit').height()
    $('.ordered-steps').css 'height', height

expandSteps = ->
  $('#show-all-icon').attr 'class', 'icon-resize-small'
  $('.ordered-steps').height 'inherit'
  $('.step-image').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
  # $('.step-ingredients-source').each ->
  #   $(this).show 'blind', {direction: 'vertical'}, 500
  $('.step-video').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
  $('.step-actions').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.scroll-overlay-top').hide()
  $('.scroll-overlay-bottom').hide()

collapseSteps = (height) ->
  $('#show-all-icon').attr 'class', 'icon-resize-full'
  $('.ordered-steps').height height
  $('.step-image').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  # $('.step-ingredients-source').each ->
  #   $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-video').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-actions').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
  # $('.scroll-overlay-bottom').show()

window.adjustActivityLayout = ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()


$ ->
  adjustActivityLayout()

  i = 0
  $('#show-all').click ->
    height = $('#video-ingredient-unit').height()
    if ++i % 2
      expandSteps()
    else
      collapseSteps(height)
      if $('.ordered-steps').height() >= height
        $('.scroll-overlay-bottom').show()

  $('.social-action').each ->
    $(this).popover()

  $('.syllabus-popover').each ->
    $(this).popover()

  $(document).on 'click', '#activity-description-maximize', ->
    overlay = $(this).closest('.activity-description-wrapper').find('.activity-description-overlay')
    $('.activity-description').toggleClass 'maximize-description', 300, 'easeInCubic'
    if ($(this).text() == 'more')
      $(this).text 'less'
    else
      $(this).text 'more'

window.expandSteps = expandSteps

# This clearly needs some refactoring out to a separate file!
window.wysiwygActivatedCallback = (elem) ->
  setupFilepickerDropPanes()
  filepickerPreviewUpdateAll()

  $(elem).find('form').enableClientSideValidations();


###$ ->
  $(document).on 'click', ".edit-pair textarea:not(.nohtml)", (event) ->

    $(this).wysihtml5
      image: false,
      html: true
      customTemplates:
        emphasis: (locale, options) ->
          size = " btn-small"
          "<li>" + "<div class='btn-group'>" +
            "<a class='btn" + size + "' data-wysihtml5-command='bold' title='CTRL+B' tabindex='-1'>" + "B" + "</a>" +
            "<a class='btn" + size + "' data-wysihtml5-command='italic' title='CTRL+I' tabindex='-1'>" + "I" + "</a>" +
            "<a class='btn" + size + "' data-wysihtml5-command='underline' title='CTRL+U' tabindex='-1'>" + "U" + "</a>" +
          "</div>" + "</li>"

        "font-styles": (locale, options) ->
          size = " btn-small"
          "<li class='dropdown'>" +
            "<a class='btn dropdown-toggle" + size + "' data-toggle='dropdown' href='#'>" + "<i class='icon-font'></i>&nbsp;<span class='current-font'>" + "Normal" + "</span>&nbsp;<b class='caret'></b>" + "</a>" +
            "<ul class='dropdown-menu'>" +
              "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='div' tabindex='-1'>" + "Normal" + "</a></li>" +
              "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h4' tabindex='-1'>" + "H4" + "</a></li>" +
              "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h5' tabindex='-1'>" + "H5" + "</a></li>" +
              "<li><a data-wysihtml5-command='formatBlock' data-wysihtml5-command-value='h6' tabindex='-1'>" + "H6" + "</a></li>" +
            "</ul>" +
          "</li>"###

window.wysiwygDeactivatedCallback = (elem) ->
  adjustActivityLayout()

$ ->
  # User Registration popup shows up after viewing 2 activities
  popup_bottom = $('.popup-bottom')
  if popup_bottom.is('*')
    popup_bottom.delay(5000).addClass 'popup-bottom-show', 1000

    $('.popup-bottom-close').click ->
      popup_bottom.removeClass 'popup-bottom-show', 500

