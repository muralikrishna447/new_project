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
  $('.step-ingredients-source').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
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
  $('.step-ingredients-source').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-video').each ->
    $(this).hide 'blind', {direction: 'vertical'}, 500
  $('.step-actions').each ->
    $(this).show 'blind', {direction: 'vertical'}, 500
  # $('.scroll-overlay-bottom').show()

$ ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()

  i = 0
  $('#show-all').click ->
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

  activity_description = $('#activity-description')
  if activity_description.text().length > 455
    $('#activity-description-maximize').show()
  else
    activity_description.find('.activity-description-overlay').hide()

  $('#activity-description-maximize').click ->
    overlay = $(this).closest('.activity-description-wrapper').find('.activity-description-overlay')
    $('.activity-description').toggleClass 'maximize-description', 300, 'easeInCubic'
    if ($(this).text() == 'more')
      $(this).text 'less'
    else
      $(this).text 'more'

# Wysiwyg mode stuff

$ ->
  $('#edit-mode').click ->
    $('#edit-mode').toggleClass('active')

  $(document).on 'mouseenter', '*[data-wysiwyg]:not(.wysiwyg-active)', ->
    if $('#edit-mode').hasClass('active')
      $(this).addClass('wysiwyg-available')

  $(document).on 'mouseleave', '*[data-wysiwyg]', ->
    $(this).removeClass('wysiwyg-available')

  $(document).on 'click', '.wysiwyg-available', ->
    $.ajax($('#wysiwyg-link').attr('href'), {
      data: {partialname: $(this).data("wysiwyg") }
    })

  $(document).on 'click', '*', (event) ->
    active_form_group = $('.wysiwyg-active')
    if $(active_form_group).length == 1
      if ! $(event.target).closest($(active_form_group)).is($(active_form_group))
        form = $(active_form_group).find('form')
        hidden_input_str = "<input type='hidden' name='partialname' value='";
        hidden_input_str += $(active_form_group).data("wysiwyg")
        hidden_input_str += "'>"
        form.append(hidden_input_str)
        form.submit()

# Filepicker (for wysiwyg). This is duplicated in admin, should remove from there or share.


filepickerPreviewUpdateOne = (preview, fpfile) ->
  if fpfile
    admin_width = 200
    if fpfile[0] == '{'
      url = JSON.parse(fpfile).url
      preview.attr('src', [url , "/convert?fit=max&w=", admin_width, "&h=", Math.floor(admin_width * 16.0 / 9.0)].join(""))
    else
      # Legacy, this can go as soon as rake task is run
      url = "http://d2eud0b65jr0pw.cloudfront.net/" + fpfile
      preview.attr('src', url)
    preview.parent().show()
  else
    preview.parent().hide()
    preview.attr('src', '')


filepickerPreviewUpdateAll = ->
  $('.filepicker-real-file').each ->
    preview = $(this).parent().find('.filepicker-preview')
    val = $(this).attr('value')
    filepickerPreviewUpdateOne(preview, val)

$ ->
  filepickerPreviewUpdateAll()

$ ->
  $(document).on "click", ".filepicker-pick-button", (event) ->
    event.preventDefault()
    filepicker.pickAndStore {mimetype:"image/*"}, {location:"S3"}, (fpfiles) =>
      $(_this).parents('.filepicker-group').find('.filepicker-real-file').val(JSON.stringify(fpfiles[0]))
      filepickerPreviewUpdateAll()

  $(document).on "click", ".remove-filepicker-image", (event) ->
    $(this).parents('.filepicker-group').find('.filepicker-real-file').val('')
    filepickerPreviewUpdateAll()

setupFilepickerDropPanes = ->
  $('.filepicker-drop-pane').each ->
    filepicker.makeDropPane $(this),
      dragEnter: =>
        $(this).html("Drop to upload").css("border-style", "inset")
      dragLeave: =>
        $(this).html("Or drop file here").css("border-style", "outset")
      onSuccess: (fpfiles) =>
        $(_this).parents('.filepicker-group').find('.filepicker-real-file').val(JSON.stringify(fpfiles[0]))
        filepickerPreviewUpdateAll()
        $(this).html("Or drop file here").css("border-style", "outset")
      onProgress: (percentage) =>
        $(this).text("Uploading ("+percentage+"%)")

$ ->
  setupFilepickerDropPanes()
  $(document).on "click", (event) ->
    setupFilepickerDropPanes()

window.setupFilepickerDropPanes = setupFilepickerDropPanes