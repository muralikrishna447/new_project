toggleBeta = (language) ->
  pattern = /English/g
  if pattern.test(language)
    $('#beta-notification').hide()
  else
    $('#beta-notification').show()

# Removes Extra iFrames
removeExtra = () ->
  $('.goog-te-menu-frame').last().remove()

$ ->
  translation_selector = $("#google_translate_element")
  if translation_selector.length > 0
    translation_selector.on 'DOMNodeInserted', '.goog-te-gadget-simple', ->
      if $('.goog-te-menu-frame').length > 1
        removeExtra()

      unless $('.goog-te-gadget').find('span#beta-notification').length > 0
        $('.goog-te-gadget').append("<span id='beta-notification' style='color:white'>Beta</span>")
      toggleBeta $('.goog-te-menu-value').find('span').first().text()

      # Hides and restyles the standard Google Translate Select field
      translation_selector.css 'padding', '9px'
      gadget = $('.goog-te-gadget-simple')
      gadget.find('img').hide()
      gadget.css 'background':'none', 'border':'none', 'padding':'0px'

      menu = $('.goog-te-menu-value')
      menu.css 'color', 'white'
      menu.find('span').css 'border':'none', 'color':'white'
      menu.find('span').click (e) ->
        menu_frame = $('.goog-te-menu-frame')
        menu_frame.css 'box-shadow', '0px 0px 6px 0px black'

        # Translate menu opens in the correct location depending on the sticky navbar
        nav_class = $('.sticky-navbar').attr 'class'
        frame_margin = if /stuck-to-top/g.test(nav_class) then '60px' else '20px'
        menu_frame.css('margin-top', frame_margin )

        menu_box = menu_frame.contents().find('div.goog-te-menu2')

        menu_box.css 'border':'none'

        # Controls the color and hover for translate menu
        menu_box.contents().find('span.text').css 'color', '#d15129'
        menu_box.contents().find('a.goog-te-menu2-item').hover( 
          ->
            $(this).find('div').css 'background':'#d15129'
            $(this).find('span.text').css 'color':'white', 
          ->
            $(this).find('div').css 'background':'none'
            $(this).find('span.text').css 'color':'#d15129')

        # Turns on BETA when language is not english
        $('.goog-te-menu-frame').contents().find('a.goog-te-menu2-item').click ->
          toggleBeta($(this).text())
