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

window.adjustActivityLayout = ->
  height = $('#video-ingredient-unit').height()
  adjustStepHeight()

  activity_description = $('#activity-description')
  if activity_description.text().length > 455
    $('#activity-description-maximize').show()
  else
    activity_description.find('.activity-description-overlay').hide()

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


findOrCreateHiddenInput = (parent, name, value) ->
  inp = parent.find("input[name='" + name + "']")
  if inp.length == 0
    inp = $("<input type='hidden'>").appendTo(parent)
    inp.attr("name", name)
  inp.attr("value", value)


# Wysiwyg mode stuff

$ ->

  # Don't show edit switch until page is fully loaded
  $('#edit-group').show('fast')

  # See https://github.com/twitter/bootstrap/issues/2380 for reason why this exists
  $('body').on 'click', '#edit-group .btn', (event) ->
    event.stopPropagation()
    $('#edit-group .btn').toggleClass('active')
    if $('#edit-mode').hasClass('active')
      $('.hide-when-editing').hide('fast')
    else
      $('.hide-when-editing').show('fast')


  $(document).on 'mouseenter', '*[data-wysiwyg]:not(.wysiwyg-active)', ->
    if $('#edit-mode').hasClass('active')
      $(this).addClass('wysiwyg-available')
      et = $('#edit-target')
      $(this).prepend(et)
      et.show()

  $(document).on 'mouseleave', '*[data-wysiwyg]', ->
    $(this).removeClass('wysiwyg-available')
    $('#edit-target').hide()

  $(document).on 'click', '.wysiwyg-available', ->
    $('#edit-target').hide().appendTo('body')
    edit_id = "edit_" + new Date().getTime().toString()
    # This makes sure our whole round trip happens on the right div with no race conditions.
    # Don't use data(), it won't be findable later b/c not stored in dom.
    $('.wysiwyg-available').attr("data-edit_id", edit_id)
    $.ajax($('#wysiwyg-link').attr('href'), {
      data:
        partial_name: $(this).data("wysiwyg")
        edit_id: edit_id
    })

  $(document).on 'click', '*', (event) ->
    active_form_group = $('.wysiwyg-active')
    if $(active_form_group).length == 1
      if ! $(event.target).closest($(active_form_group)).is($(active_form_group))
        form = $(active_form_group).find('form')
        findOrCreateHiddenInput(form, "partial_name", $(active_form_group).data("wysiwyg"))
        findOrCreateHiddenInput(form, "edit_id", $(active_form_group).attr("data-edit_id"))
        form.submit()
        event.stopPropagation()

# Filepicker (for wysiwyg). This is duplicated in admin, should remove from there or share.


filepickerPreviewUpdateOne = (preview, fpfile) ->
  if fpfile
    admin_width = 200
    url = JSON.parse(fpfile).url
    preview.attr('src', [url , "/convert?fit=max&w=", admin_width, "&h=", Math.floor(admin_width * 9.0 / 16.0)].join(""))
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
window.expandSteps = expandSteps

# This clearly needs some refactoring out to a separate file!
window.wysiwygActivatedCallback = (elem) ->
  setupFilepickerDropPanes()
  adjustActivityLayout()
  filepickerPreviewUpdateAll()

  $(elem).find('form').enableClientSideValidations();

  $(elem).find("textarea:not(.nohtml)").wysihtml5
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
        "</li>"

window.wysiwygDeactivatedCallback = (elem) ->
  prepareForScaling()
  adjustActivityLayout()
  $(elem).removeClass('wysiwyg-active')
  $('.hide-when-editing').hide()


$ ->
  # User Registration popup shows up after viewing 3 activities
  popup_bottom = $('.popup-bottom')
  if popup_bottom.is('*')
    popup_bottom.addClass 'popup-bottom-show', 1000

    $('.popup-bottom-close').click ->
      popup_bottom.removeClass 'popup-bottom-show', 500

